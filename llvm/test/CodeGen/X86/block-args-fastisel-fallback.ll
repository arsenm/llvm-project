; RUN: llc -mtriple=x86_64-- -fast-isel -O0 -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-- -fast-isel -O0 -verify-machineinstrs < %s | FileCheck %s

; When FastISel bails on a terminator (here the fp80 compare is not FastISel
; friendly) and falls back to SelectionDAG, any block-argument values it already
; recorded for the successor edge must be discarded, so they are not emitted a
; second time by SelectionDAG. Otherwise the SUCC_ARGS for the edge ends up with
; too many operands, referencing a register that was never defined.

; CHECK-LABEL: foo:
define zeroext i1 @foo(x86_fp80 %x, x86_fp80 %y) noinline optnone {
entry:
  %cmp = fcmp ogt x86_fp80 %x, %y
  br i1 %cmp, label %lor.end, label %lor.rhs

lor.rhs:
  %call = call zeroext i1 @bar(x86_fp80 %x)
  br label %lor.end

lor.end:
  %r = phi i1 [ true, %entry ], [ %call, %lor.rhs ]
  ret i1 %r
}

declare zeroext i1 @bar(x86_fp80)
