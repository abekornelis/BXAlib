# EXTR macro

Execute an TRanslate-instruction with variable length

## Syntax

``` hlasm
&LABEL   EXTR  &SRC,                   * Source for TRanslate          *
               &TABLE,                 * Translate table               *
               &DECR                   * Decrement indicator
```

## SRC

specifies the source field for the translate. In stead of a
length, a register containing the length must be specified.

## TABLE

specifies the translate table to be used.

## DECR

a value of `NODEC` indicates that the length in the register
specified in the TO length field, contains the length of
the translate minus 1 for the EX instruction.

## Macro code

The [EXTR macro](../bxamac/EXTR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.