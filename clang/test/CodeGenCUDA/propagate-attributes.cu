// Check that when we link a bitcode module into a file using
// -mlink-builtin-bitcode, we apply the same attributes to the functions in that
// bitcode module as we apply to functions we generate.
//
// In particular, we check that ftz and unsafe-math are propagated into the
// bitcode library as appropriate.

// Build the bitcode library.  This is not built in CUDA mode, otherwise it
// might have incompatible attributes.  This mirrors how libdevice is built.
// RUN: %clang_cc1 -x c++ -fconvergent-functions -emit-llvm-bc -DLIB \
// RUN:   %s -o %t.bc -triple nvptx-unknown-unknown

// RUN: %clang_cc1 -x cuda %s -emit-llvm -mlink-builtin-bitcode %t.bc -o - \
// RUN:   -fcuda-is-device -triple nvptx-unknown-unknown \
// RUN: | FileCheck %s --check-prefix=CHECK --check-prefix=NOFTZ

// RUN: %clang_cc1 -x cuda %s -emit-llvm -mlink-builtin-bitcode %t.bc \
// RUN:   -fdenormal-fp-math-f32=preserve-sign -o - \
// RUN:   -fcuda-is-device -triple nvptx-unknown-unknown \
// RUN: | FileCheck %s --check-prefix=CHECK --check-prefix=FTZ

// RUN: %clang_cc1 -x cuda %s -emit-llvm -mlink-builtin-bitcode %t.bc \
// RUN:   -fdenormal-fp-math-f32=preserve-sign -o - \
// RUN:   -fcuda-is-device -funsafe-math-optimizations -triple nvptx-unknown-unknown \
// RUN: | FileCheck %s --check-prefix=CHECK

// Wrap everything in extern "C" so we don't have to worry about name mangling
// in the IR.
extern "C" {
#ifdef LIB

// This function is defined in the library and only declared in the main
// compilation.
void lib_fn() {}

#else

#include "Inputs/cuda.h"
__device__ void lib_fn();
__global__ void kernel() { lib_fn(); }

#endif
}

// CHECK-NOT: convergent
// The kernel and lib function should have the same attributes.
// CHECK: define{{.*}} void @kernel() [[kattr:#[0-9]+]]
// CHECK: define internal void @lib_fn() [[fattr:#[0-9]+]]


// NOFTZ: attributes [[kattr]] = { mustprogress noinline norecurse nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+ptx32,+sm_20" }
// NOFTZ: attributes [[fattr]] = { mustprogress noinline nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+ptx32,+sm_20" }


// FTZ: attributes [[kattr]] = { mustprogress noinline norecurse nounwind optnone "denormal-fp-math-f32"="preserve-sign,preserve-sign" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+ptx32,+sm_20" }
// FTZ: attributes [[fattr]] = { mustprogress noinline nounwind optnone "denormal-fp-math-f32"="preserve-sign,preserve-sign" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-features"="+ptx32,+sm_20" }

