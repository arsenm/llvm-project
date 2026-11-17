; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s --check-prefix=ASM

; A sparse switch lowers to a comparison chain (switch cases) rather than a
; jump table. Under -sdag-use-block-args each case block emits a SUCC_ARGS for
; the merge block's argument, standing in for the edge from the original block
; before switch expansion.

; MIR-LABEL: name: sw
; MIR: SUCC_ARGS %bb.[[M:[0-9]+]], %{{[0-9]+}}
; MIR: bb.[[M]].m:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: sw:
define i32 @sw(i32 %x) {
entry:
  switch i32 %x, label %def [
    i32 100, label %c0
    i32 2000, label %c1
    i32 30000, label %c2
  ]
c0:
  br label %m
c1:
  br label %m
c2:
  br label %m
def:
  br label %m
m:
  %p = phi i32 [ 99, %def ], [ 10, %c0 ], [ 11, %c1 ], [ 12, %c2 ]
  ret i32 %p
}
