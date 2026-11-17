; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-- -verify-machineinstrs < %s | FileCheck %s

; An undef PHI incoming value is forwarded as an undef SUCC_ARGS operand with no
; defining instruction. Lowering block arguments for that edge must produce the
; same correct code as ordinary PHI lowering (both RUN lines share the checks).

; CHECK-LABEL: f:
; CHECK:         movl %esi, %eax
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    retq
define i32 @f(i1 %c, i32 %a) {
entry:
  br i1 %c, label %t, label %m
t:
  br label %m
m:
  %p = phi i32 [ poison, %entry ], [ %a, %t ]
  ret i32 %p
}
