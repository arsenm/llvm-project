; RUN: llc -mtriple=xcore -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s

; The select pseudo is expanded by a custom inserter into a diamond with a value
; merge in the join block. Under -sdag-use-block-args that merge must be a block
; argument fed by SUCC_ARGS, not a machine PHI.
define i32 @select_custom_inserter(i32 %c, i32 %a, i32 %b) {
; CHECK-LABEL: select_custom_inserter:
; CHECK:       bt r0, .LBB0_2
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    mov r1, r2
; CHECK-NEXT:  .LBB0_2:
; CHECK-NEXT:    mov r0, r1
; CHECK-NEXT:    retsp 0
  %cmp = icmp ne i32 %c, 0
  %r = select i1 %cmp, i32 %a, i32 %b
  ret i32 %r
}
