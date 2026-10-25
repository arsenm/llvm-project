; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s --check-prefix=ASM

; A switch over clustered case values lowers to a bit test. Under
; -sdag-use-block-args each bit-test case block emits a SUCC_ARGS for the merge
; block's argument. The default edge from the range-check header is handled by
; the main FinishBasicBlock loop.

; MIR-LABEL: name: bt
; MIR: BT32rr
; MIR: SUCC_ARGS %bb.[[M:[0-9]+]], %{{[0-9]+}}
; MIR: bb.[[M]].m:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: bt:
define i32 @bt(i32 %x) {
entry:
  switch i32 %x, label %def [
    i32 0, label %hit
    i32 2, label %hit
    i32 3, label %hit
    i32 5, label %hit
    i32 7, label %hit
    i32 11, label %hit
    i32 13, label %hit
    i32 17, label %hit
    i32 19, label %hit
    i32 23, label %hit
  ]
hit:
  br label %m
def:
  br label %m
m:
  %p = phi i32 [ 1, %hit ], [ 0, %def ]
  ret i32 %p
}
