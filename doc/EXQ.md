# EXQ macro

Execute an instruction with variable length

## Syntax

``` hlasm
&LABEL   EXQ   &TO,                    * First operand                 *
               &FROM,                  * Second operand                *
               &OPCD,                  * Operation code to EXecute     *
               &DECR                   * Decrement indicator
```

## TO

specifies the first operand for the instruction. In the length
field, a register containing the length must be specified.
For an MVC the first operand is the destination of the move.

## FROM

specifies the second operand of the instruction to be
executed. For an MVC this is the source of the move.

## OPCD

specifies the operation code for the instruction to be executed.

## DECR

a value of `NODEC` indicates that the length in the register
specified in the TO length field, contains the length of
the move minus 1 for the EX instruction.

## Macro code

The [EXQ macro](../bxamac/EXQ.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.