// RUN: %clang_cc1 -debug-info-kind=limited -verify -fopenmp -x c++ -triple nvptx64-unknown-unknown -fopenmp-targets=nvptx64-nvidia-cuda -emit-llvm %s -fopenmp-is-device -fvisibility=protected -o - | FileCheck %s
// RUN: %clang_cc1 -debug-info-kind=limited -verify -fopenmp -x c++ -triple nvptx-unknown-unknown -fopenmp-targets=nvptx-nvidia-cuda -emit-llvm %s -fopenmp-is-device -fvisibility=protected -o - | FileCheck %s
// expected-no-diagnostics

#pragma omp declare target

void foo() {}

#pragma omp end declare target

// Make sure noconvergent doesn't appear
// CHECK: define hidden void @_Z3foov() [[ATTRIBUTE_NUMBER:#[0-9]+]]
// CHECK: attributes [[ATTRIBUTE_NUMBER]] = { mustprogress noinline nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+ptx32,+sm_20" }
