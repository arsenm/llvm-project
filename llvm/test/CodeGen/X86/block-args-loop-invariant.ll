; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s

; MachineLICM checks whether a loop instruction reads a value defined inside the
; loop. When the operand is a block-argument register (no defining instruction),
; the loop-invariance check must look up the value's defining block rather than
; assuming an instruction def. The loop-invariant multiply must be hoisted out
; of the loop: imull is emitted before the loop header and not inside the body.

; CHECK-LABEL: f:
; CHECK: imull %esi, %esi
; CHECK: [[LOOP:.LBB[0-9]+_[0-9]+]]: # %loop
; CHECK-NOT: imull
; CHECK: jl {{.*}}[[LOOP]]
define i32 @f(i32 %n, i32 %x) {
entry:
  br label %loop
loop:
  %acc = phi i32 [ 0, %entry ], [ %acc.next, %loop ]
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %inv = mul i32 %x, %x
  %acc.next = add i32 %acc, %inv
  %i.next = add i32 %i, 1
  %c = icmp slt i32 %i.next, %n
  br i1 %c, label %loop, label %exit
exit:
  ret i32 %acc
}
