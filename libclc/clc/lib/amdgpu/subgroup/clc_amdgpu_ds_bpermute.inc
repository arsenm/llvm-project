//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifdef __CLC_SCALAR

#if (defined(__CLC_GENSIZE) && __CLC_GENSIZE <= 32) ||                         \
    defined(__CLC_FPSIZE) && __CLC_FPSIZE <= 32

static _CLC_OVERLOAD __CLC_GENTYPE __clc_amdgpu_ds_bpermute(uint l,
                                                            __CLC_GENTYPE v) {
  uint v_u32 = __clc_convert_uint(__CLC_AS_U_GENTYPE(v));
  uint permute = __builtin_amdgcn_ds_bpermute(l << 2, v_u32);
  return __CLC_AS_GENTYPE(__CLC_CONVERT_U_GENTYPE(permute));
}

#elif defined(__CLC_GENSIZE) && __CLC_GENSIZE == 64 ||                         \
    defined(__CLC_FPSIZE) && __CLC_FPSIZE == 64

static _CLC_OVERLOAD __CLC_GENTYPE __clc_amdgpu_ds_bpermute(uint l,
                                                            __CLC_GENTYPE v) {
  uint2 v_v2u32 = __clc_as_uint2(v);
  uint2 result = {__clc_amdgpu_ds_bpermute(l, v_v2u32.lo),
                  __clc_amdgpu_ds_bpermute(l, v_v2u32.hi)};
  return __CLC_AS_GENTYPE(result);
}

#endif

#endif // __CLC_SCALAR
