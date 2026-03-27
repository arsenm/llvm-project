//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "clc/clc_convert.h"
#include "clc/integer/clc_ctz.h"
#include "clc/math/clc_fmax.h"
#include "clc/math/clc_fmin.h"
#include "clc/shared/clc_max.h"
#include "clc/shared/clc_min.h"
#include "clc/subgroup/clc_sub_group_non_uniform_scan.h"
#include "clc/subgroup/clc_subgroup.h"
#include <gpuintrin.h>

//------------------------------------------------------------------------------
//  Integer and fp add
//------------------------------------------------------------------------------

_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_add(uint value) {
  return __gpu_suffix_scan_sum_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_add(ulong value) {
  return __gpu_suffix_scan_sum_u64(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_min(uint value) {
  return __gpu_suffix_scan_min_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_min(ulong value) {
  return __gpu_suffix_scan_min_u64(__gpu_lane_mask(), value);
}


_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_max(uint value) {
  return __gpu_suffix_scan_max_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_max(ulong value) {
  return __gpu_suffix_scan_max_u64(__gpu_lane_mask(), value);
}



_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_and(uint value) {
  return __gpu_suffix_scan_and_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_and(ulong value) {
  return __gpu_suffix_scan_and_u64(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_or(uint value) {
  return __gpu_suffix_scan_or_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_or(ulong value) {
  return __gpu_suffix_scan_or_u64(__gpu_lane_mask(), value);
}


_CLC_DEF _CLC_OVERLOAD uint
__clc_sub_group_non_uniform_scan_inclusive_xor(uint value) {
  return __gpu_suffix_scan_xor_u32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD ulong
__clc_sub_group_non_uniform_scan_inclusive_xor(ulong value) {
  return __gpu_suffix_scan_xor_u64(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD float
__clc_sub_group_non_uniform_scan_inclusive_add(float value) {
  return __gpu_suffix_scan_sum_f32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD double
__clc_sub_group_non_uniform_scan_inclusive_add(double value) {
  return __gpu_suffix_scan_sum_f64(__gpu_lane_mask(), value);
}


_CLC_DEF _CLC_OVERLOAD float
__clc_sub_group_non_uniform_scan_inclusive_min(float value) {
  return __gpu_suffix_scan_minnum_f32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD double
__clc_sub_group_non_uniform_scan_inclusive_min(double value) {
  return __gpu_suffix_scan_minnum_f64(__gpu_lane_mask(), value);
}


_CLC_DEF _CLC_OVERLOAD float
__clc_sub_group_non_uniform_scan_inclusive_max(float value) {
  return __gpu_suffix_scan_maxnum_f32(__gpu_lane_mask(), value);
}

_CLC_DEF _CLC_OVERLOAD double
__clc_sub_group_non_uniform_scan_inclusive_max(double value) {
  return __gpu_suffix_scan_maxnum_f64(__gpu_lane_mask(), value);
}

