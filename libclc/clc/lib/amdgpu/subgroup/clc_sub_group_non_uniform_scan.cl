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


#define __CLC_BODY "clc_amdgpu_ds_bpermute.inc"
#include "clc/integer/gentype.inc"

#define __CLC_BODY "clc_amdgpu_ds_bpermute.inc"
#include "clc/math/gentype.inc"

//------------------------------------------------------------------------------
//  Integer and fp add
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_add
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_add
#define __CLC_FUNCTION_IMPL(x, y) ((x) + (y))
#define __CLC_SUBGROUP_SCAN_ID_VAL (__CLC_GENTYPE)0

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/math/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  Integer and fp mul
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_mul
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_mul
#define __CLC_FUNCTION_IMPL(x, y) ((x) * (y))
#define __CLC_SUBGROUP_SCAN_ID_VAL (__CLC_GENTYPE)1

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/math/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  Integer and fp min
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_min
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_min
#define __CLC_FUNCTION_IMPL(x, y) __clc_min(x, y)
#define __CLC_SUBGROUP_SCAN_ID_VAL __CLC_GEN_MAX

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"
#undef __CLC_FUNCTION_IMPL

#define __CLC_FUNCTION_IMPL(x, y) __clc_fmin(x, y)
#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/math/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  Integer and fp max
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_max
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_max
#define __CLC_FUNCTION_IMPL(x, y) __clc_max(x, y)
#define __CLC_SUBGROUP_SCAN_ID_VAL __CLC_GEN_MIN

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"
#undef __CLC_FUNCTION_IMPL

#define __CLC_FUNCTION_IMPL(x, y) __clc_fmax(x, y)
#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/math/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  and
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_and
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_and
#define __CLC_FUNCTION_IMPL(x, y) ((x) & (y))
#define __CLC_SUBGROUP_SCAN_ID_VAL (__CLC_GENTYPE)~0

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  or
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_or
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_or
#define __CLC_FUNCTION_IMPL(x, y) ((x) | (y))
#define __CLC_SUBGROUP_SCAN_ID_VAL (__CLC_GENTYPE)0

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL

//------------------------------------------------------------------------------
//  xor
//------------------------------------------------------------------------------

#define __CLC_FUNCTION_INCLUSIVE __clc_sub_group_non_uniform_scan_inclusive_xor
#define __CLC_FUNCTION_EXCLUSIVE __clc_sub_group_non_uniform_scan_exclusive_xor
#define __CLC_FUNCTION_IMPL(x, y) ((x) & (y))
#define __CLC_SUBGROUP_SCAN_ID_VAL (__CLC_GENTYPE)0

#define __CLC_BODY "clc_sub_group_non_uniform_scan.inc"
#include "clc/integer/gentype.inc"

#undef __CLC_FUNCTION_INCLUSIVE
#undef __CLC_FUNCTION_EXCLUSIVE
#undef __CLC_FUNCTION_IMPL
#undef __CLC_SUBGROUP_SCAN_ID_VAL
