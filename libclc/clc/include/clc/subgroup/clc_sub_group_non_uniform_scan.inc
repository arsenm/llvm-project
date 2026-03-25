//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__CLC_SCALAR)
_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_add(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_mul(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_min(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_max(__CLC_GENTYPE x);

#ifndef __CLC_FPSIZE
_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_and(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_or(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_inclusive_xor(__CLC_GENTYPE x);
#endif // __CLC_FPSIZE

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_add(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_mul(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_min(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_max(__CLC_GENTYPE x);

#ifndef __CLC_FPSIZE
_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_and(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_or(__CLC_GENTYPE x);

_CLC_DECL _CLC_OVERLOAD _CLC_CONST __CLC_GENTYPE
__clc_sub_group_non_uniform_scan_exclusive_xor(__CLC_GENTYPE x);
#endif // __CLC_FPSIZE

#endif
