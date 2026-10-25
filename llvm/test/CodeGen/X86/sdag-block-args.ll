; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s --check-prefix=ASM

; With -sdag-use-block-args, SelectionDAG lowers PHI nodes to MLIR-style block
; arguments: the successor block owns an argument list and each predecessor
; forwards its value with a SUCC_ARGS. The final assembly matches the default
; PHI-based lowering.

; MIR-LABEL: name: diamond
; MIR: bb.0.entry:
; MIR: SUCC_ARGS %bb.2, %{{[0-9]+}}
; MIR: bb.1.e:
; MIR: SUCC_ARGS %bb.2, %{{[0-9]+}}
; MIR: bb.2.m:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: diamond:
define i32 @diamond(i1 %c, i32 %a, i32 %b) {
entry:
  br i1 %c, label %t, label %e
t:
  br label %m
e:
  br label %m
m:
  %p = phi i32 [ %a, %t ], [ %b, %e ]
  ret i32 %p
}

; A loop-carried PHI becomes a block argument on the loop header.

; MIR-LABEL: name: loop
; MIR: arguments: %{{[0-9]+}}
; MIR: SUCC_ARGS %bb.{{[0-9]+}}, %{{[0-9]+}}

; ASM-LABEL: loop:
define i32 @loop(i32 %n) {
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %loop ]
  %acc = phi i32 [ 0, %entry ], [ %acc.next, %loop ]
  %acc.next = add i32 %acc, %i
  %i.next = add i32 %i, 1
  %c = icmp slt i32 %i.next, %n
  br i1 %c, label %loop, label %exit
exit:
  ret i32 %acc
}
