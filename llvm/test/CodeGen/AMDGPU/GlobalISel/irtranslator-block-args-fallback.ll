; RUN: llc -mtriple=amdgpu9.42 -global-isel -gisel-use-block-args -global-isel-abort=2 < %s 2> %t.err | FileCheck %s
; RUN: FileCheck -check-prefix=ERR %s < %t.err

; The IRTranslator gives up on the inline asm after it has created the block
; arguments for the loop's PHIs, but before it emitted any G_SUCC_ARGS. The
; uniformity analysis still runs on the partially translated function before
; it falls back to SelectionDAG.

; ERR: warning: Instruction selection used fallback path for fallback_after_block_args

; CHECK-LABEL: fallback_after_block_args:
; CHECK: global_store_dwordx4
define amdgpu_kernel void @fallback_after_block_args(i32 %n) {
entry:
  br label %loop

loop:
  %id = call i32 @llvm.amdgcn.workitem.id.x()
  %min = call i32 @llvm.smin.i32(i32 %n, i32 %id)
  %cmp = icmp slt i32 %min, 0
  br i1 %cmp, label %loop, label %exit

exit:
  call void asm sideeffect "global_store_dwordx4 $0, $1 off", "v,v,~{memory}"(ptr addrspace(1) null, i128 0)
  ret void
}
