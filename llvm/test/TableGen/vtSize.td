// RUN: llvm-tblgen -gen-dag-isel -I %p/../../include -I %p/Common %s -o - | FileCheck -check-prefix=SDAG %s
// XUN: llvm-tblgen -gen-global-isel -I %p/../../include -I %p/Common %s -o - | FileCheck -check-prefix=GISEL %s


// Boilerplate code.
include "llvm/Target/Target.td"
include "GlobalISelEmitterCommon.td"


def ANYLOAD : I<(outs GPR32:$dst), (ins GPR32:$src1), []>;

def : Pat<(vtAny32 (load GPR32:$src)),
       (ANYLOAD GPR32:$src)>;


//def ANYLOAD2 : I<(outs GPR32:$dst), (ins GPR32:$src1),
//              [(set GPR32:$dst, (load GPR32:$src1))]>;


