# ABND macro

This macro forces an abend by branching to the predetermined entry point of an Abend-routine.

## Syntax

``` hlasm
&LABEL   ABND  &COND,                  * Condition for abending        *
               &ABEND,                 * Label of BXABEND routine      *
               &FAIL=R14,              * Reg for failed address        *
               &TSTREG=,               * Registers for LTR-instruction *
               &RCD=                   * 1 or 2 registers or IGNORE
```

## COND

can be one of the following:
- SETDFT: specifies abend entry point, generates no code
- TSTRC : abend-routine will be taken if R15<>0
- E     : abend-routine will be taken on cond.code = E
- H     : abend-routine will be taken on cond.code = H
- L     : abend-routine will be taken on cond.code = L
- M     : abend-routine will be taken on cond.code = M
- O     : abend-routine will be taken on cond.code = O
- P     : abend-routine will be taken on cond.code = P
- Z     : abend-routine will be taken on cond.code = Z
- NE    : abend-routine will be taken on cond.code = NE
- NH    : abend-routine will be taken on cond.code = NH
- NL    : abend-routine will be taken on cond.code = NL
- NM    : abend-routine will be taken on cond.code = NM
- NO    : abend-routine will be taken on cond.code = NO
- NP    : abend-routine will be taken on cond.code = NP
- NZ    : abend-routine will be taken on cond.code = NZ

## LABEL

specifies label of abend routine. If not specified the
default supplied with TYPE=SETDFT will be used.

## FAIL

specifies the register that passes the reasoncode for
the abend, usually the failing address. If not specified
defaults to R14.

## TSTREG

specifies a a register or a set of two registers,
to be used in an LTR instruction. The resulting condition
code will be tested as specified in the COND parameter.

## RCD

valid only with TSTRC. Specifies 1 or 2 registers or IGNORE.
If IGNORE is specified, the return- and reasoncodes will be
lost before the abend is issued. If 1 register is specified
it will be used to save the returncode, the reasoncode will
be lost before the abend is issued. If two registers are
specified, the first will contain the returncode, the
reasoncode will be put into the second one before the abend
is issued. Only registers 2-11 can be specified.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.