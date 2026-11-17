; RUN: llc -mtriple=x86_64-- -fast-isel -fast-isel-abort=1 -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=x86_64-- -fast-isel -fast-isel-abort=1 -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=x86_64-- -fast-isel -fast-isel-abort=1 < %s | FileCheck %s --check-prefix=ASM

; FastISel lowers PHI nodes to block arguments under -sdag-use-block-args: each
; predecessor forwards its value with a SUCC_ARGS and the successor owns the
; argument list. The final assembly matches the default PHI-based lowering.

; MIR-LABEL: name: diamond
; MIR: bb.0.entry:
; MIR: SUCC_ARGS %bb.[[M:[0-9]+]], %{{[0-9]+}}
; MIR: SUCC_ARGS %bb.[[M]], %{{[0-9]+}}
; MIR: bb.[[M]].m:
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

; Constants forwarded to a block argument must still be materialized in the
; predecessor and not deleted as dead local values.

; MIR-LABEL: name: constphi
; MIR: MOV32ri 42
; MIR: MOV32ri 7
; MIR: arguments: %{{[0-9]+}}

; ASM-LABEL: constphi:
define i32 @constphi(i1 %c) {
entry:
  br i1 %c, label %t, label %e
t:
  br label %m
e:
  br label %m
m:
  %p = phi i32 [ 42, %t ], [ 7, %e ]
  ret i32 %p
}
