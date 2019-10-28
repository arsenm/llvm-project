; RUN: llvm-dis < %s.bc | FileCheck %s
; RUN: verify-uselistorder < %s.bc

; Make sure the convergent attribute is dropped.

; convergent-upgrade.ll.bc was produced by running a version of llvm-as from just
; before the IR change on this file.

; No attributes
; CHECK: define void @test_convergent_fn() {
define void @test_convergent_fn() #0 {
  ret void
}

; CHECK: declare void @test_convergent_extern(){{$}}
declare void @test_convergent_extern() #0

; CHECK: declare void @extern(){{$}}
declare void @extern()

define void @test_convergent_callsize() {
  ; CHECK: call void @extern(){{$}}
  call void @extern() #0
  ret void
}

; CHECK-NOT: attributes

attributes #0 = { convergent }
