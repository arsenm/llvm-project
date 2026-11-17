; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -stop-after=finalize-isel -verify-machineinstrs < %s | FileCheck %s --check-prefix=MIR
; RUN: llc -mtriple=x86_64-- -sdag-use-block-args -verify-machineinstrs < %s | FileCheck %s --check-prefix=ASM
; RUN: llc -mtriple=x86_64-- < %s | FileCheck %s --check-prefix=ASM

; A switch that lowers to a jump table forwards PHI values across the
; jump-table edges. Under -sdag-use-block-args each jump-table target emits a
; SUCC_ARGS for the merge block's argument, and the merge block owns the
; argument list. The default edge is handled by the range-check header.

; MIR-LABEL: name: jt
; MIR: jumpTable:
; The merge block owns a block argument fed by the table targets.
; MIR: bb.{{[0-9]+}}.c0:
; MIR: SUCC_ARGS %bb.[[M:[0-9]+]], %{{[0-9]+}}
; MIR: bb.{{[0-9]+}}.c4:
; MIR: SUCC_ARGS %bb.[[M]], %{{[0-9]+}}
; MIR: bb.[[M]].m:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: jt:
define i32 @jt(i32 %x) {
entry:
  switch i32 %x, label %m [
    i32 10, label %c0
    i32 11, label %c1
    i32 12, label %c2
    i32 13, label %c3
    i32 14, label %c4
  ]
c0:
  br label %m
c1:
  br label %m
c2:
  br label %m
c3:
  br label %m
c4:
  br label %m
m:
  %p = phi i32 [ 99, %entry ], [ 10, %c0 ], [ 11, %c1 ], [ 12, %c2 ], [ 13, %c3 ], [ 14, %c4 ]
  ret i32 %p
}

; A switch whose values need a range check before the jump table, so the
; range-check header is a block materialized during jump-table lowering rather
; than the entry block. Its edge to the default block (which owns block
; arguments) must still emit a SUCC_ARGS.

; MIR-LABEL: name: jt_split_header
; MIR: jumpTable:
; MIR: SUCC_ARGS %bb.[[D:[0-9]+]]
; MIR: bb.[[D]].return:
; MIR-NEXT: arguments: %{{[0-9]+}}

; ASM-LABEL: jt_split_header:
define i64 @jt_split_header(i32 %tag, i64 %p) {
entry:
  switch i32 %tag, label %return [
    i32 45056, label %common.ret
    i32 40992, label %common.ret
    i32 16896, label %common.ret
    i32 16650, label %common.ret
    i32 16649, label %sw.a
    i32 16648, label %common.ret
    i32 16647, label %sw.a
    i32 16646, label %common.ret
    i32 11, label %common.ret
    i32 16645, label %sw.a
    i32 16644, label %sw.b
    i32 16643, label %common.ret
    i32 16642, label %sw.c
    i32 16641, label %common.ret
    i32 16513, label %common.ret
    i32 75, label %common.ret
  ]

common.ret:
  ret i64 0

sw.a:
  br label %return

sw.b:
  br label %return

sw.c:
  br label %return

return:
  %v = phi i64 [ 24, %sw.c ], [ 0, %entry ], [ %p, %sw.b ], [ 1, %sw.a ]
  ret i64 %v
}
