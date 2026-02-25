# EQU macro

This macro replaces the assembler's EQU statement.
It is implements the overrides, as specified by preceding invocations
of the [EQUOVR macro](EQUOVR.md).

## Syntax

``` hlasm
&LABEL   EQU   &VALUE,                 * Value to be assigned          *
               &LEN,                   * Length attribute              *
               &TYPE                   * Type attribute
```

The syntax for the EQU macro is identical to that of the EQU instruction.

## LABEL

mandatory

## VALUE

specifies the value to be assigned to &LABEL

## LEN

specifies an explicit length attribute

## TYPE

specifies an explicit type attribute
- IBM-assigned types are:
  - $ = WXTRN symbol
  - @ = Graphics field
  - A = A-type address field
  - B = Binary field
  - C = Character field
  - D = Long floating point field
  - E = Short floating point field
  - F = Fullword fixed-point field
  - G = Fixed-point field, explicit length
  - H = Halfword fixed-point field
  - I = Machine instruction
  - J = Control section name
  - K = Floating point field, explicit length
  - L = Extended floating point field
  - M = Macro instruction
  - N = Self-defining term
  - O = Omitted operand
  - P = Packed decimal field
  - Q = Q-type address field
  - R = Address field of type A, S, Q, V, Y, with explicit length
  - S = S-type address field
  - T = EXTRN symbol
  - U = Undefined
  - V = V-type address field
  - W = CCW or CCWn instruction
  - X = Hexadecimal field
  - Y = Y-type address field
  - Z = Zoned decimal field
- Bixoft-assigned types are:
  - a = Access register
  - b = Bit field
  - c = Control register
  - f = Floating point register
  - g = General purpose register
  - j = Embedded control block (DCL-declared)
  - p = Pointer register
  - v = Value assigned to a code field
  - 0 = Literal decimal number of unspecified type and length

## Macro code

The [EQU macro](../bxamac/EQU.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.