// RUN: mlir-opt -allow-unregistered-dialect %s -verify-diagnostics -split-input-file | FileCheck %s

// CHECK: attr = dense_resource<blob1> : tensor<3xi64>
"test.user_op"() {attr = dense_resource<blob1> : tensor<3xi64> } : () -> ()

{-#
  dialect_resources: {
    builtin: {
      // CHECK: blob1: "0x08000000010000000000000002000000000000000300000000000000"
      blob1: "0x08000000010000000000000002000000000000000300000000000000"
    }
  }
#-}

// -----

// DenseResourceElementsHandle key blob\-"one" is quoted and escaped.
// CHECK: attr = dense_resource<"blob\\-\22one\22"> : tensor<2xi16>
"test.user_op"() {attr = dense_resource<"blob\\-\22one\22"> : tensor<2xi16>} : () -> ()

{-#
  dialect_resources: {
    builtin: {
      // CHECK: "blob\\-\22one\22": "0x0200000001000200"
      "blob\\-\22one\22": "0x0200000001000200"
    }
  }
#-}
