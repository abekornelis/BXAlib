# EXXC macro

Execute an eXclusive-or-Characters instruction with variable length

## Syntax

``` hlasm
&LABEL   EXXC  &TO,                    * Xor destination               *
               &FROM,                  * Xor source                    *
               &DECR                   * Decrement indicator
```

## TO

specifies the destination field for the Xor. In stead of a
length, a register containing the length must be specified.

## FROM

specifies the second operand for the Xor.

## DECR

a value of `NODEC` indicates that the length in the register
specified in the TO length field, contains the length of
the move minus 1 for the EX instruction.

## Macro code

The [EXXC macro](../bxamac/EXXC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.