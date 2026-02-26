# CLEAR macro

Clear an area of storage or a register

- For TYPE=LONG, registers R0, R1, and R15 will be used
- For TYPE=SHORT, all registers retain their values

## Syntax

``` hlasm
&LABEL   CLEAR &AREA,                  * Area to be cleared            *
               &FILL,                  * Filler to use for clearing    *
               &TYPE                   * LONG, SHORT, XC
```

## AREA

- specifies the area of storage to be cleared
- can be specified as a label, or as (label,length).
- label and/or length may be specified as (reg)
- May also be specified as (gpr,`*ADDR`) to clear high-order bit
  in specified general purpose register.
- If area specifies R0-R15 or AR0-AR15 and &FILL and &TYPE are
  both omitted, then the designated register will be cleared
  to hex zeroes.


## FILL

specifies the filler value to use, defaults to blanks for
character fields, otherwise to binary zeros.

## TYPE

- `SHORT` for areas up to 257 bytes in length, `LONG` for all other.
- defaults to `SHORT`. XC for short areas to be cleared using XC.

## Macro code

The [CLEAR macro](../bxamac/CLEAR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.