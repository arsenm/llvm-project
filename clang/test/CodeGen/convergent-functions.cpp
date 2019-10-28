// RUN: %clang_cc1 -triple i386-pc-win32 -emit-llvm -fconvergent-functions -o - < %s | FileCheck -check-prefix=CONVFUNC %s
// RUN: %clang_cc1 -triple i386-pc-win32 -emit-llvm -o - < %s | FileCheck -check-prefix=NOCONVFUNC %s

// Test that the -fconvergent-functions flag works

// Everything may be convergent
// CONVFUNC-NOT: noconvergent
void func() { }

void extern_func();

void call_extern() {
  extern_func();
}

void asm_func() {
  __asm volatile(";foo");
}

void asm_decl(void) __asm("llvm.maybe.convergent");
void call_asm_decl() {
  asm_decl();
}

// All attribute contexts should have noconvergent here
// NOCONVFUNC: attributes #0 = { noconvergent
// NOCONVFUNC: attributes #1 = { noconvergent
// NOCONVFUNC: attributes #2 = { noconvergent
// NOCONVFUNC: attributes #3 = { noconvergent
// NOCONVFUNC-NOT: attributes
