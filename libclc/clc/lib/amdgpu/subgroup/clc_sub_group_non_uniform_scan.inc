//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#if defined(__CLC_SCALAR)

#include "clc/shared/gentype_limits.h"

_CLC_DEF
_CLC_OVERLOAD __CLC_GENTYPE __CLC_FUNCTION_INCLUSIVE(__CLC_GENTYPE value) {
  uint l = __clc_get_sub_group_local_id();
  __CLC_GENTYPE ret = value;

  uint wavesize = __builtin_amdgcn_wavefrontsize();
  ulong smask = __builtin_amdgcn_read_exec() & ~((0x2UL << l) - 1UL);
  uint smask_lo = (uint)smask;

  // Number of steps is log2(wavesize)
  if (wavesize == 64) {
    for (int step = 0; step < 6; ++step) {
      // Find next active lane.
      uint slid = __clc_ctz(smask);
      __CLC_GENTYPE t = __clc_amdgpu_ds_bpermute(slid, ret);

      __CLC_GENTYPE op_val = slid < wavesize ? t : __CLC_SUBGROUP_SCAN_ID_VAL;

      ret = __CLC_FUNCTION_IMPL(ret, op_val);

      // Clear (1 << step) bits from smask
      int clears = 1 << step;
      for (int i = 0; i < clears; ++i) {
        smask &= smask - 1UL;
      }
    }
  } else {
    for (int step = 0; step < 5; ++step) {
      // Find next active lane.
      uint slid = __clc_ctz(smask_lo);
      __CLC_GENTYPE t = __clc_amdgpu_ds_bpermute(slid, ret);
      __CLC_GENTYPE op_val = slid < wavesize ? t : __CLC_SUBGROUP_SCAN_ID_VAL;

      ret = __CLC_FUNCTION_IMPL(ret, op_val);

      // Clear (1 << step) bits from smask
      int clears = 1 << step;
      for (int i = 0; i < clears; ++i) {
        smask_lo &= smask_lo - 1;
      }
    }
  }

  return ret;
}

_CLC_DEF _CLC_OVERLOAD __CLC_GENTYPE
__CLC_FUNCTION_EXCLUSIVE(__CLC_GENTYPE value) {
  (void)value;
  // TODO: Implement exclusive scan
  __builtin_trap();
}

#undef __CLC_GEN_MIN
#undef __CLC_GEN_MAX

#endif
