; RUN: llc -mtriple=amdgcn-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s

; A uniform (scalar) value forwarded through block arguments must not be dragged
; to the VGPR class by SIFixSGPRCopies. The branch is uniform (on an inreg
; value) and every incoming value is scalar, so the join stays in SGPRs just as
; it does with machine PHIs. Previously the SUCC_ARGS bridge in
; analyzeVGPRToSGPRCopy followed every operand of a SUCC_ARGS rather than only
; the one fed by the analyzed value, coupling all the independent join lanes into
; one sibling set. That inflated the copy score's penalty above its profit, so
; the whole join was moved to VGPR, which later produced a partially-undef wide
; VGPR-tuple spill and a "Using an undefined physical register" verifier error.

; CHECK-LABEL: bitcast_v128i8_to_v64f16_scalar:
; CHECK-NOT: v_lshrrev_b64
; CHECK-NOT: v_lshlrev_b64
define inreg <64 x half> @bitcast_v128i8_to_v64f16_scalar(<128 x i8> inreg %a, i32 inreg %b) #0 {
  %cmp = icmp eq i32 %b, 0
  br i1 %cmp, label %cmp.true, label %cmp.false

cmp.true:
  %a1 = add <128 x i8> %a, splat (i8 3)
  %a2 = bitcast <128 x i8> %a1 to <64 x half>
  br label %end

cmp.false:
  %a3 = bitcast <128 x i8> %a to <64 x half>
  br label %end

end:
  %phi = phi <64 x half> [ %a2, %cmp.true ], [ %a3, %cmp.false ]
  ret <64 x half> %phi
}

attributes #0 = { nounwind }
