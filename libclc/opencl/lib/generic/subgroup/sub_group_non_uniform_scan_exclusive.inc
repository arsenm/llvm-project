//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifdef __CLC_SCALAR

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_add(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_add(x);
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_mul(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_mul(x);
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_min(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_min(x);
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_max(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_max(x);
}

#ifndef __CLC_FPSIZE

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_and(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_and(x);
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_or(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_or(x);
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
sub_group_non_uniform_scan_exclusive_xor(__CLC_GENTYPE x) {
  return __clc_sub_group_non_uniform_scan_exclusive_xor(x);
}
#endif // __CLC_FPSIZE
#endif // __CLC_SCALAR
