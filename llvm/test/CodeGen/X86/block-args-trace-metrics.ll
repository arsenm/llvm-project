; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s

; MachineTraceMetrics (used by MachineCombiner) collects the data dependencies
; of each instruction. A block-argument register has no defining instruction,
; so getOneDef returns null; such a read must be skipped (it behaves like a
; live-in with no in-trace dependency) rather than asserting on a unique def.
; The reassociating fadd chain in the loop drives MachineCombiner over a loop
; block that carries a block argument, and the block-argument lowering must
; produce the same code as the default PHI lowering.

; CHECK-LABEL: f:
; CHECK:       xorl %eax, %eax
; MachineCombiner reassociated the fadd chain: y + x is computed once before
; the loop, and the loop body adds acc + x independently before combining.
; CHECK:       addss %xmm1, %xmm2
; CHECK:     [[LOOP:\.LBB[0-9]+_[0-9]+]]:
; CHECK:       movaps %xmm0, %xmm3
; CHECK-NEXT:  addss %xmm1, %xmm0
; CHECK-NEXT:  addss %xmm2, %xmm0
; CHECK-NEXT:  incl %eax
; CHECK-NEXT:  cmpl %edi, %eax
; CHECK-NEXT:  jl [[LOOP]]
; CHECK:       movaps %xmm3, %xmm0
; CHECK-NEXT:  retq
define float @f(float %init, i32 %n, float %x, float %y) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %acc = phi float [ %init, %entry ], [ %r, %loop ]
  %a = fadd reassoc nsz float %acc, %x
  %b = fadd reassoc nsz float %a, %y
  %r = fadd reassoc nsz float %b, %x
  %i.next = add i32 %i, 1
  %c = icmp slt i32 %i.next, %n
  br i1 %c, label %loop, label %exit
exit:
  ret float %acc
}
