; RUN: opt -S -passes=iroutliner -ir-outlining-no-cost < %s

; Make sure the outliner doesn't produce invalid IR with immarg
; arguments.

define i32 @immarg_user_same_values(i32 %arg0) {
bb:
  %i = tail call i32 @llvm.uses.immarg(i32 0, i32 2)
  %i1 = or i32 %arg0, %i
  %i2 = tail call i32 @llvm.uses.immarg(i32 1, i32 2)
  %i3 = or i32 %arg0, %i2
  ret i32 %i3
}

declare i32 @llvm.uses.immarg(i32, i32 immarg)
