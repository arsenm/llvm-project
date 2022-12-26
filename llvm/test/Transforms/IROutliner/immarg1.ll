; RUN: opt -S -passes=iroutliner -ir-outlining-no-cost < %s

define i32 @immarg_user_different_values(i32 %arg0) {
bb:
  %i = tail call i32 @llvm.uses.immarg(i32 0, i32 0)
  %i1 = or i32 %arg0, %i
  %i2 = tail call i32 @llvm.uses.immarg(i32 1, i32 1)
  %i3 = or i32 %arg0, %i2
  ret i32 %i3
}

declare i32 @llvm.uses.immarg(i32, i32 immarg)

