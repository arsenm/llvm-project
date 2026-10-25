; RUN: llc -mtriple=arm64-apple-darwin -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=arm64-apple-darwin -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=arm64-apple-darwin < %s | FileCheck %s --check-prefix=ASM

; A switch over clustered case values lowers to a bit test whose range check is
; split into its own header block, distinct from the block the main
; FinishBasicBlock loop processed. That header branches to the default, so under
; -sdag-use-block-args the header -> default edge must also get a SUCC_ARGS for
; the default block's argument. Otherwise the machine verifier reports "Missing
; SUCC_ARGS for a block with arguments".

; MIR-LABEL: name: bt_split_header
; The range-check header forwards the default's block argument.
; MIR: SUCC_ARGS %bb.[[E:[0-9]+]], %{{[0-9]+}}
; MIR: Bcc
; MIR: bb.[[E]].cond.end:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: bt_split_header:
define i32 @bt_split_header(i16 %x) {
entry:
  switch i16 %x, label %cond.end [
    i16 4368, label %cond.true
    i16 4367, label %cond.true
    i16 4422, label %cond.true
    i16 4423, label %cond.true
    i16 4355, label %cond.true
    i16 4402, label %cond.true
    i16 4354, label %cond.true
    i16 4429, label %cond.true
    i16 4445, label %cond.true
  ]
cond.true:
  br label %cond.end
cond.end:
  %cond = phi i32 [ 1, %cond.true ], [ 0, %entry ]
  ret i32 %cond
}
