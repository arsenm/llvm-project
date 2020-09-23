; RUN: opt -S -mergefunc < %s | FileCheck %s

%Empty_type = type {}
%S2i = type <{ i64, i64 }>
%D2i = type <{ i64, i64 }>
%Di = type <{ i32 }>
%Si = type <{ i32 }>

define void @B(%Empty_type* sret(%Empty_type) %a, %S2i* %b, i32* %xp, i32* %yp) {
  %x = load i32, i32* %xp
  %y = load i32, i32* %yp
  %sum = add i32 %x, %y
  %sum2 = add i32 %sum, %y
  %sum3 = add i32 %sum2, %y
  ret void
}

define void @C(%Empty_type* sret(%Empty_type) %a, %S2i* %b, i32* %xp, i32* %yp) {
  %x = load i32, i32* %xp
  %y = load i32, i32* %yp
  %sum = add i32 %x, %y
  %sum2 = add i32 %sum, %y
  %sum3 = add i32 %sum2, %y
  ret void
}

define void @A(%Empty_type* sret(%Empty_type) %a, %D2i* %b, i32* %xp, i32* %yp) {
  %x = load i32, i32* %xp
  %y = load i32, i32* %yp
  %sum = add i32 %x, %y
  %sum2 = add i32 %sum, %y
  %sum3 = add i32 %sum2, %y
  ret void
}

; Make sure we transfer the parameter attributes to the call site.
; CHECK-LABEL: define void @C(%Empty_type* sret
; CHECK:  tail call void bitcast (void (%Empty_type*, %D2i*, i32*, i32*)* @A to void (%Empty_type*, %S2i*, i32*, i32*)*)(%Empty_type* sret(%Empty_type) %0, %S2i* %1, i32* %2, i32* %3)
; CHECK:  ret void


; Make sure we transfer the parameter attributes to the call site.
; CHECK-LABEL: define void @B(%Empty_type* sret
; CHECK:  %5 = bitcast
; CHECK:  tail call void @A(%Empty_type* sret(%Empty_type) %0, %D2i* %5, i32* %2, i32* %3)
; CHECK:  ret void

