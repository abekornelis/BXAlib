# EXMVC macro

Execute an MVC-instruction with variable length

## Syntax

``` hlasm
&LABEL   EXMVC &TO,                    * Move destination              *
               &FROM,                  * Move source                   *
               &DECR                   * Decrement indicator
```

## TO

specifies the destination field for the move. In stead of a
length, a register containing the length must be specified.

## FROM

specifies the source of the move

## DECR

a value of NODEC indicates that the length in the register
specified in the TO length field, contains the length of
the move minus 1 for the EX instruction.

## Macro code

The [EXMVC macro](../bxamac/EXMVC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.