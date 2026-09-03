; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s

; LiveVariables runs before block arguments are lowered, so it sees a use of a
; block-argument register, which is defined by its block rather than by an
; instruction. Its liveness bookkeeping must find that defining block instead
; of assuming an instruction def.

; CHECK-LABEL: f:
define i32 @f(i1 %c, i32 %a, i32 %b) {
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
