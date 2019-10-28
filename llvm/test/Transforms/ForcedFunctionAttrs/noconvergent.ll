; RUN: opt < %s -S -passes=forceattrs | FileCheck %s --check-prefix=CHECK-CONTROL
; RUN: opt < %s -S -passes=forceattrs -force-attribute foo:noconvergent | FileCheck %s --check-prefix=CHECK-FOO
; RUN: opt < %s -S -passes=forceattrs -force-attribute foo:noconvergent | FileCheck %s --check-prefix=CHECK-FOO

; CHECK-CONTROL: define void @foo() {
; CHECK-FOO: define void @foo() #0 {
define void @foo() {
  ret void
}

; CHECK-FOO: attributes #0 = { noconvergent }
