; RUN: opt -passes=iroutliner -ir-outlining-no-cost -disable-output < %s

target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7"

define i32 @__ockl_wfred_add_i32(i32 %arg) {
bb:
  %i = tail call i32 @llvm.amdgcn.ds.swizzle(i32 0, i32 1)
  %i1 = or i32 0, %arg
  %i2 = tail call i32 @llvm.amdgcn.ds.swizzle(i32 1, i32 0)
  %i3 = or i32 1, %arg
  ret i32 0
}

declare i32 @llvm.amdgcn.ds.swizzle(i32, i32 immarg) #0

attributes #0 = { convergent nocallback nofree nounwind willreturn memory(none) }
