//===-- AMDGPUGlobalISelDivergenceLowering.cpp ----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
/// GlobalISel pass that selects divergent i1 phis as lane mask phis.
/// Lane mask merging uses same algorithm as SDAG in SILowerI1Copies.
/// Handles all cases of temporal divergence.
/// For divergent non-phi i1 and uniform i1 uses outside of the cycle this pass
/// currently depends on LCSSA to insert phis with one incoming.
//
//===----------------------------------------------------------------------===//

#include "AMDGPU.h"
#include "AMDGPUGlobalISelUtils.h"
#include "SILowerI1Copies.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"
#include "llvm/CodeGen/MachineFunctionAnalysisManager.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachinePassManager.h"
#include "llvm/CodeGen/MachineUniformityAnalysis.h"
#include "llvm/InitializePasses.h"

#define DEBUG_TYPE "amdgpu-global-isel-divergence-lowering"

using namespace llvm;

namespace {

class AMDGPUGlobalISelDivergenceLoweringLegacy : public MachineFunctionPass {
public:
  static char ID;

public:
  AMDGPUGlobalISelDivergenceLoweringLegacy() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override {
    return "AMDGPU GlobalISel divergence lowering";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<MachineDominatorTreeWrapperPass>();
    AU.addRequired<MachinePostDominatorTreeWrapperPass>();
    AU.addRequired<MachineUniformityAnalysisPass>();
    MachineFunctionPass::getAnalysisUsage(AU);
  }
};

class DivergenceLoweringHelper : public AMDGPU::PhiLoweringHelper {
public:
  DivergenceLoweringHelper(MachineFunction &MF, MachineDominatorTree &DT,
                           MachinePostDominatorTree &PDT,
                           MachineUniformityInfo *MUI);

private:
  MachineUniformityInfo *MUI = nullptr;
  MachineIRBuilder B;
  Register buildRegCopyToLaneMask(Register Reg);

public:
  void markAsLaneMask(Register DstReg) const override;
  void getCandidatesForLowering(
      SmallVectorImpl<MachineInstr *> &Vreg1Phis) const override;
  void collectIncomingValuesFromPhi(
      const MachineInstr *MI,
      SmallVectorImpl<AMDGPU::Incoming> &Incomings) const override;
  void replaceDstReg(Register NewReg, Register OldReg,
                     MachineBasicBlock *MBB) override;
  void buildMergeLaneMasks(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator I, const DebugLoc &DL,
                           Register DstReg, Register PrevReg,
                           Register CurReg) override;
  void constrainAsLaneMask(AMDGPU::Incoming &In) override;

  bool lowerTemporalDivergence();
  bool lowerTemporalDivergenceI1();

  // Block-argument analogues of the G_PHI lowering hooks, driven by the shared
  // PhiLoweringHelper::lowerBlockArgs. A divergent i1 block argument has no
  // defining G_PHI, so it is collected and merged into a lane mask directly
  // from its predecessors' SUCC_ARGS forwarders.
  void getBlockArgCandidatesForLowering(
      SmallVectorImpl<std::pair<MachineBasicBlock *, Register>> &Candidates)
      const override;
  void collectIncomingValuesFromBlockArg(
      MachineBasicBlock &MBB, unsigned ArgIdx,
      SmallVectorImpl<AMDGPU::Incoming> &Incomings) const override;
};

DivergenceLoweringHelper::DivergenceLoweringHelper(
    MachineFunction &MF, MachineDominatorTree &DT,
    MachinePostDominatorTree &PDT, MachineUniformityInfo *MUI)
    : PhiLoweringHelper(MF, DT, PDT), MUI(MUI), B(MF) {}

// _(s1) -> SReg_32/64(s1)
void DivergenceLoweringHelper::markAsLaneMask(Register DstReg) const {
  assert(MRI->getType(DstReg) == LLT::scalar(1));

  if (MRI->getRegClassOrNull(DstReg)) {
    if (MRI->constrainRegClass(DstReg, ST->getBoolRC()))
      return;
    llvm_unreachable("Failed to constrain register class");
  }

  MRI->setRegClass(DstReg, ST->getBoolRC());
}

void DivergenceLoweringHelper::getCandidatesForLowering(
    SmallVectorImpl<MachineInstr *> &Vreg1Phis) const {
  LLT S1 = LLT::scalar(1);

  // Add divergent i1 G_PHIs to the list. Only consider G_PHI instructions,
  // not PHI instructions that may have been created by earlier lowering stages
  // (e.g., lowerTemporalDivergenceI1).
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB.phis()) {
      if (MI.getOpcode() != TargetOpcode::G_PHI)
        continue;
      Register Dst = MI.getOperand(0).getReg();
      if (MRI->getType(Dst) == S1 && MUI->isDivergentAtDef(Dst))
        Vreg1Phis.push_back(&MI);
    }
  }
}

void DivergenceLoweringHelper::collectIncomingValuesFromPhi(
    const MachineInstr *MI,
    SmallVectorImpl<AMDGPU::Incoming> &Incomings) const {
  for (unsigned i = 1; i < MI->getNumOperands(); i += 2) {
    Incomings.emplace_back(MI->getOperand(i).getReg(),
                           MI->getOperand(i + 1).getMBB(), Register());
  }
}

void DivergenceLoweringHelper::replaceDstReg(Register NewReg, Register OldReg,
                                             MachineBasicBlock *MBB) {
  BuildMI(*MBB, MBB->getFirstNonPHI(), {}, TII->get(AMDGPU::COPY), OldReg)
      .addReg(NewReg);
}

// Copy Reg to new lane mask register, insert a copy after instruction that
// defines Reg while skipping phis if needed.
Register DivergenceLoweringHelper::buildRegCopyToLaneMask(Register Reg) {
  Register LaneMask = AMDGPU::createLaneMaskReg(MRI, LaneMaskRegAttrs);
  MachineInstr *Instr = MRI->getVRegDef(Reg);
  if (Instr) {
    MachineBasicBlock *MBB = Instr->getParent();
    B.setInsertPt(*MBB,
                  MBB->SkipPHIsAndLabels(std::next(Instr->getIterator())));
  } else {
    // A block-argument register has no defining instruction; it is available
    // at the start of the block that owns it.
    MachineBasicBlock *MBB = MRI->getDefBlock(Reg);
    B.setInsertPt(*MBB, MBB->SkipPHIsAndLabels(MBB->begin()));
  }
  B.buildCopy(LaneMask, Reg);
  return LaneMask;
}

// bb.previous
//   %PrevReg = ...
//
// bb.current
//   %CurReg = ...
//
//   %DstReg - not defined
//
// -> (wave32 example, new registers have sreg_32 reg class and S1 LLT)
//
// bb.previous
//   %PrevReg = ...
//   %PrevRegCopy:sreg_32(s1) = COPY %PrevReg
//
// bb.current
//   %CurReg = ...
//   %CurRegCopy:sreg_32(s1) = COPY %CurReg
//   ...
//   %PrevMaskedReg:sreg_32(s1) = ANDN2 %PrevRegCopy, ExecReg - active lanes 0
//   %CurMaskedReg:sreg_32(s1)  = AND %ExecReg, CurRegCopy - inactive lanes to 0
//   %DstReg:sreg_32(s1)        = OR %PrevMaskedReg, CurMaskedReg
//
// DstReg = for active lanes rewrite bit in PrevReg with bit from CurReg
void DivergenceLoweringHelper::buildMergeLaneMasks(
    MachineBasicBlock &MBB, MachineBasicBlock::iterator I, const DebugLoc &DL,
    Register DstReg, Register PrevReg, Register CurReg) {
  // DstReg = (PrevReg & !EXEC) | (CurReg & EXEC)
  // TODO: check if inputs are constants or results of a compare.

  Register PrevRegCopy = buildRegCopyToLaneMask(PrevReg);
  Register CurRegCopy = buildRegCopyToLaneMask(CurReg);
  Register PrevMaskedReg = AMDGPU::createLaneMaskReg(MRI, LaneMaskRegAttrs);
  Register CurMaskedReg = AMDGPU::createLaneMaskReg(MRI, LaneMaskRegAttrs);

  B.setInsertPt(MBB, I);
  B.buildInstr(LMC->AndN2Opc, {PrevMaskedReg}, {PrevRegCopy, LMC->ExecReg})
      .setOperandDead(3);
  B.buildInstr(LMC->AndOpc, {CurMaskedReg}, {LMC->ExecReg, CurRegCopy})
      .setOperandDead(3);
  B.buildInstr(LMC->OrOpc, {DstReg}, {PrevMaskedReg, CurMaskedReg})
      .setOperandDead(3);
}

// GlobalISel has to constrain S1 incoming taken as-is with lane mask register
// class. Insert a copy of Incoming.Reg to new lane mask inside Incoming.Block,
// Incoming.Reg becomes that new lane mask.
void DivergenceLoweringHelper::constrainAsLaneMask(AMDGPU::Incoming &In) {
  B.setInsertPt(*In.Block, In.Block->getBlockEndInsertPt());

  auto Copy = B.buildCopy(LLT::scalar(1), In.Reg);
  MRI->setRegClass(Copy.getReg(0), ST->getBoolRC());
  In.Reg = Copy.getReg(0);
}

void replaceUsesOfRegInInstWith(Register Reg, MachineInstr *Inst,
                                Register NewReg) {
  for (MachineOperand &Op : Inst->operands()) {
    if (Op.isReg() && Op.getReg() == Reg)
      Op.setReg(NewReg);
  }
}

bool DivergenceLoweringHelper::lowerTemporalDivergence() {
  AMDGPU::IntrinsicLaneMaskAnalyzer ILMA(MF);
  DenseMap<Register, Register> TDCache;

  for (auto [Reg, UseInst, _] : MUI->getTemporalDivergenceList()) {
    if (MRI->getType(Reg) == LLT::scalar(1) || MUI->isDivergentAtDef(Reg) ||
        ILMA.isS32S64LaneMask(Reg))
      continue;

    Register CachedTDCopy = TDCache.lookup(Reg);
    if (CachedTDCopy) {
      replaceUsesOfRegInInstWith(Reg, UseInst, CachedTDCopy);
      continue;
    }

    MachineInstr *Inst = MRI->getVRegDef(Reg);
    MachineBasicBlock *MBB = Inst->getParent();
    B.setInsertPt(*MBB, MBB->SkipPHIsAndLabels(std::next(Inst->getIterator())));

    Register VgprReg = MRI->createGenericVirtualRegister(MRI->getType(Reg));
    B.buildInstr(AMDGPU::COPY, {VgprReg}, {Reg})
        .addUse(LMC->ExecReg, RegState::Implicit);

    replaceUsesOfRegInInstWith(Reg, UseInst, VgprReg);
    TDCache[Reg] = VgprReg;
  }
  return false;
}

bool DivergenceLoweringHelper::lowerTemporalDivergenceI1() {
  MachineRegisterInfo::VRegAttrs BoolS1 = {ST->getBoolRC(), LLT::scalar(1)};
  initializeLaneMaskRegisterAttributes(BoolS1);
  MachineSSAUpdater SSAUpdater(MF);

  const auto &CInfo = MUI->getCycleInfo();

  // In case of use outside muliple nested cycles or muliple uses we only need
  // to merge lane mask across largest relevant cycle.
  SmallDenseMap<Register, std::pair<CycleRef, Register>> LRCCache;
  for (auto [Reg, UseInst, LRC] : MUI->getTemporalDivergenceList()) {
    if (MRI->getType(Reg) != LLT::scalar(1))
      continue;

    auto [LRCCacheIter, RegNotCached] = LRCCache.try_emplace(Reg);
    auto &CycleMergedMask = LRCCacheIter->getSecond();
    CycleRef &CachedLRC = CycleMergedMask.first;
    if (RegNotCached || CInfo.contains(LRC, CachedLRC)) {
      CachedLRC = LRC;
    }
  }

  for (auto &LRCCacheEntry : LRCCache) {
    Register Reg = LRCCacheEntry.first;
    auto &CycleMergedMask = LRCCacheEntry.getSecond();
    CycleRef Cycle = CycleMergedMask.first;

    Register MergedMask = MRI->createVirtualRegister(BoolS1);
    SSAUpdater.Initialize(MergedMask);

    MachineBasicBlock *MBB = MRI->getDefBlock(Reg);
    SSAUpdater.AddAvailableValue(MBB, MergedMask);

    for (auto Entry : CInfo.getEntries(Cycle)) {
      for (MachineBasicBlock *Pred : Entry->predecessors()) {
        if (!CInfo.contains(Cycle, Pred)) {
          B.setInsertPt(*Pred, Pred->getBlockEndInsertPt());
          auto ImplDef = B.buildInstr(AMDGPU::IMPLICIT_DEF, {BoolS1}, {});
          SSAUpdater.AddAvailableValue(Pred, ImplDef.getReg(0));
        }
      }
    }

    buildMergeLaneMasks(*MBB, MBB->getBlockEndInsertPt(), {}, MergedMask,
                        SSAUpdater.GetValueInMiddleOfBlock(MBB), Reg);

    CycleMergedMask.second = MergedMask;
  }

  for (auto [Reg, UseInst, Cycle] : MUI->getTemporalDivergenceList()) {
    if (MRI->getType(Reg) != LLT::scalar(1))
      continue;

    replaceUsesOfRegInInstWith(Reg, UseInst, LRCCache.lookup(Reg).second);
  }

  return false;
}

// Gather divergent i1 block-argument receivers. Record the owning block and the
// argument register (not the index): removing an argument shifts the indices of
// later arguments, so the index is looked up at replacement time.
void DivergenceLoweringHelper::getBlockArgCandidatesForLowering(
    SmallVectorImpl<std::pair<MachineBasicBlock *, Register>> &Candidates)
    const {
  LLT S1 = LLT::scalar(1);
  for (MachineBasicBlock &MBB : MF) {
    for (Register Arg : MBB.getBlockArgs()) {
      if (MRI->getType(Arg) == S1 && MUI->isDivergentAtDef(Arg))
        Candidates.emplace_back(&MBB, Arg);
    }
  }
}

// Collect the incoming lane-mask values for the block argument at index \p
// ArgIdx of \p MBB from each predecessor's SUCC_ARGS forwarder. The block
// argument corresponds positionally to SUCC_ARGS operand ArgIdx + 1 (operand 0
// is the successor block).
void DivergenceLoweringHelper::collectIncomingValuesFromBlockArg(
    MachineBasicBlock &MBB, unsigned ArgIdx,
    SmallVectorImpl<AMDGPU::Incoming> &Incomings) const {
  for (MachineBasicBlock *Pred : MBB.predecessors()) {
    if (MachineInstr *SA = Pred->findSuccArgs(&MBB)) {
      Register IncomingReg = SA->getOperand(ArgIdx + 1).getReg();
      Incomings.emplace_back(IncomingReg, Pred, Register());
    }
  }
}

static bool runDivergenceLowering(MachineFunction &MF, MachineDominatorTree &DT,
                                  MachinePostDominatorTree &PDT,
                                  MachineUniformityInfo &MUI) {
  DivergenceLoweringHelper Helper(MF, DT, PDT, &MUI);

  bool Changed = false;
  // Temporal divergence lowering needs to inspect list of instructions used
  // outside cycle with divergent exit provided by uniformity analysis. Uniform
  // instructions from the list require lowering, no instruction is deleted.
  // Thus it needs to be run before lowerPhis that deletes phis that require
  // lowering and replaces them with new instructions.

  // Non-i1 temporal divergence lowering.
  Changed |= Helper.lowerTemporalDivergence();
  // This covers both uniform and divergent i1s. Lane masks are in sgpr and need
  // to be updated in each iteration.
  Changed |= Helper.lowerTemporalDivergenceI1();
  // Temporal divergence lowering of divergent i1 phi used outside of the cycle
  // could also be handled by lowerPhis but we do it in lowerTempDivergenceI1
  // since in some case lowerPhis does unnecessary lane mask merging.
  Changed |= Helper.lowerPhis();
  // Divergent i1 block arguments (the block-args analogue of divergent i1 phis)
  // are lowered the same way, sourcing incoming values from SUCC_ARGS.
  Changed |= Helper.lowerBlockArgs();
  return Changed;
}

} // End anonymous namespace.

INITIALIZE_PASS_BEGIN(AMDGPUGlobalISelDivergenceLoweringLegacy, DEBUG_TYPE,
                      "AMDGPU GlobalISel divergence lowering", false, false)
INITIALIZE_PASS_DEPENDENCY(MachineDominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(MachinePostDominatorTreeWrapperPass)
INITIALIZE_PASS_DEPENDENCY(MachineUniformityAnalysisPass)
INITIALIZE_PASS_END(AMDGPUGlobalISelDivergenceLoweringLegacy, DEBUG_TYPE,
                    "AMDGPU GlobalISel divergence lowering", false, false)

char AMDGPUGlobalISelDivergenceLoweringLegacy::ID = 0;

char &llvm::AMDGPUGlobalISelDivergenceLoweringLegacyID =
    AMDGPUGlobalISelDivergenceLoweringLegacy::ID;

FunctionPass *llvm::createAMDGPUGlobalISelDivergenceLoweringPass() {
  return new AMDGPUGlobalISelDivergenceLoweringLegacy();
}

bool AMDGPUGlobalISelDivergenceLoweringLegacy::runOnMachineFunction(
    MachineFunction &MF) {
  MachineDominatorTree &DT =
      getAnalysis<MachineDominatorTreeWrapperPass>().getDomTree();
  MachinePostDominatorTree &PDT =
      getAnalysis<MachinePostDominatorTreeWrapperPass>().getPostDomTree();
  MachineUniformityInfo &MUI =
      getAnalysis<MachineUniformityAnalysisPass>().getUniformityInfo();

  return runDivergenceLowering(MF, DT, PDT, MUI);
}

PreservedAnalyses AMDGPUGlobalISelDivergenceLoweringPass::run(
    MachineFunction &MF, MachineFunctionAnalysisManager &MFAM) {
  MachineDominatorTree &DT = MFAM.getResult<MachineDominatorTreeAnalysis>(MF);
  MachinePostDominatorTree &PDT =
      MFAM.getResult<MachinePostDominatorTreeAnalysis>(MF);
  MachineUniformityInfo &MUI = MFAM.getResult<MachineUniformityAnalysis>(MF);

  if (!runDivergenceLowering(MF, DT, PDT, MUI))
    return PreservedAnalyses::all();

  return getMachineFunctionPassPreservedAnalyses().preserveSet<CFGAnalyses>();
}
