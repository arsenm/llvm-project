; RUN: opt < %s -S -passes=licm | FileCheck %s

; Check that we do not hoist convergent functions out of loop
; CHECK: define i32 @test
; CHECK: loop:
; CHECK: call i32 @convergent.f

define i32 @test(ptr nocapture noalias %x, ptr nocapture %y) {
entry:
  br label %loop

loop:
  %a = call i32 @convergent.f()
  %exitcond = icmp ne i32 %a, 0
  br i1 %exitcond, label %end, label %loop

end:
  ret i32 %a
}

declare i32 @convergent.f() nounwind readnone
