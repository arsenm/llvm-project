; RUN: opt -passes=gvn-hoist -S < %s | FileCheck %s

; Check that convergent calls are not hoisted.
;
; CHECK-LABEL: @no_convergent_func_hoisting(
; CHECK: if.then:
; CHECK: call float @convergent_func(

; CHECK: if.else:
; CHECK: call float @convergent_func(
define float @no_convergent_func_hoisting(float %d, float %min, float %max, float %a) {
entry:
  %div = fdiv float 1.000000e+00, %d
  %cmp = fcmp oge float %div, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.else

if.then:
  %sub1 = fsub float %max, %a
  %mul2 = call float @convergent_func(float %sub1, float %div)
  br label %if.end

if.else:
  %sub5 = fsub float %max, %a
  %mul6 = call float @convergent_func(float %sub5, float %div)
  br label %if.end

if.end:
  %tmax.0 = phi float [ %mul2, %if.then ], [ %mul6, %if.else ]
  %add = fadd float %tmax.0, 10.0
  ret float %add
}

; The call site is noconvergent but the declaration is not.
; CHECK-LABEL: @noconvergent_callsite_hoisting(
; CHECK: call float @convergent_func(
; CHECK-NOT: call float @convergent_func(
define float @noconvergent_callsite_hoisting(float %d, float %min, float %max, float %a) {
entry:
  %div = fdiv float 1.000000e+00, %d
  %cmp = fcmp oge float %div, 0.000000e+00
  br i1 %cmp, label %if.then, label %if.else

if.then:
  %sub1 = fsub float %max, %a
  %mul2 = call float @convergent_func(float %sub1, float %div) noconvergent
  br label %if.end

if.else:
  %sub5 = fsub float %max, %a
  %mul6 = call float @convergent_func(float %sub5, float %div) noconvergent
  br label %if.end

if.end:
  %tmax.0 = phi float [ %mul2, %if.then ], [ %mul6, %if.else ]
  %add = fadd float %tmax.0, 10.0
  ret float %add
}

declare float @convergent_func(float, float) #0

attributes #0 = { nounwind readnone willreturn }
attributes #1 = { noconvergent nounwind readnone willreturn }
