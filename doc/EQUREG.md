# EQUREG macro

This macro allocates an available register or register pair,
then generates an EQU so the register can be referenced by name.

Upon return from this macro:
- &BXA_RC will contain
  - 0 if successful
  - 4 if successful with warnings
  - 8 if unsuccessful
- &BXA_NUMVAL will contain assigned register number

## Syntax

``` hlasm
&LABEL   EQUREG &SEARCH=HIGH,          * HIGH, LOW, or (reg,reg,...)   *
               &R0=NO,                 * R0 allowed YES/NO             *
               &TEMP=NO,               * R1, R14, R15 allowed YES/NO   *
               &PAIR=NO,               * Allocate 1 or 2 registers     *
               &AR=,                   * Name of access register       *
               &ODD=,                  * Name of odd reg, or (reg,areg)*
               &WARN=YES               * YES/NO issue messages
```

## LABEL

If specified, an EQU for this label will be generated

## SEARCH

Specifies the search sequence. If none of the specified
registers is available, registers 2-15 and 1 will be tried
in sequence. If R0=YES was specified registers 2-15 and 0-1
will be used in stead.

## R0

YES indicates that R0 may be used in the default search

## TEMP

YES indicates that R1, R14, and R15 may be used in the
default search

## PAIR

YES indicates that a pair of registers is to be allocated.
For a pair the even register will be assigned to the name
specified in LABEL, and &BXA_NUMVAL will also contain the
number of the even register.

## ODD

Specifies, for a register pair, the name to assign to the
odd register. If specified as a pair of names in parentheses
the first name will be equated to the odd register, the
second name will be equated to the odd access register.

## WARN

Specifies whether or not messages are to be issued when
allocation fails

## Macro code

The [EQUREG macro](../bxamac/EQUREG.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.