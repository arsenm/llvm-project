; RUN: llc -mtriple=arc -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s

; Exercise the block-arguments lowering path (PHIs represented as block
; arguments fed by SUCC_ARGS) through ARC's control-flow lowering, and via the
; loop-carried pointer induction variable through ARCOptAddrMode, which runs
; before PHI elimination and walks the def chains of load/store base registers
; that now cross block arguments.

define i32 @postinc_loop(ptr %p, i32 %n) {
; CHECK-LABEL: postinc_loop:
entry:
  br label %loop

loop:
  %ptr = phi ptr [ %p, %entry ], [ %ptr.next, %loop ]
  %acc = phi i32 [ 0, %entry ], [ %acc.next, %loop ]
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %v = load i32, ptr %ptr
  %acc.next = add i32 %acc, %v
  %ptr.next = getelementptr i32, ptr %ptr, i32 1
  %i.next = add i32 %i, 1
  %done = icmp slt i32 %i.next, %n
  br i1 %done, label %loop, label %exit

exit:
  ret i32 %acc.next
}

define i32 @loop_diamond(i32 %n, i32 %x) {
; CHECK-LABEL: loop_diamond:
entry:
  br label %loop

loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
  %acc = phi i32 [ 0, %entry ], [ %acc.next, %latch ]
  %cmp = icmp eq i32 %i, %x
  br i1 %cmp, label %then, label %latch

then:
  %scaled = mul i32 %acc, 3
  br label %latch

latch:
  %merged = phi i32 [ %scaled, %then ], [ %acc, %loop ]
  %acc.next = add i32 %merged, %i
  %i.next = add i32 %i, 1
  %done = icmp slt i32 %i.next, %n
  br i1 %done, label %loop, label %exit

exit:
  ret i32 %acc.next
}
