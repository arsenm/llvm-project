//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__CLC_GEN_S)
#define __CLC_GEN_MAX (__CLC_GENTYPE)((1LL << (__CLC_GENSIZE - 1)) - 1LL)
#define __CLC_GEN_MIN (__CLC_GENTYPE)(-(1LL << (__CLC_GENSIZE - 1)))
#elif defined(__CLC_GEN_U)
#define __CLC_GEN_MAX (__CLC_GENTYPE)((1ull << __CLC_GENSIZE) - 1ull)
#define __CLC_GEN_MIN (__CLC_GENTYPE)0
#elif defined(__CLC_FPSIZE)
#define __CLC_GEN_MIN (__CLC_GENTYPE)-INFINITY
#define __CLC_GEN_MAX (__CLC_GENTYPE)INFINITY
#endif
