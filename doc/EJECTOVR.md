# EJECTOVR macro

This macro handles the stack of EJECT modifications for use by the
[EJECT macro](EJECT.md), which replaces the assembler's EJECT instruction

## Syntax

``` hlasm
&LABEL   EJECTOVR &OPT,                * *NOERR or *END                *
               &TIMES                  * Repeat count for &OPT
```

## LABEL

should not be specified

## OPT

specifies the one of the following:
- `*END` cancels all outstanding EJECTOVR requests
- `*KEEP` allows an EJECT statement to remain unchanged
- `*SUPPRESS` suppresses the EJECT statement
- `*NOERR` suppresses any error messages

## TIMES

Specifies the number of times the specified options is to be
performed. Cannot be used with `*END`

## Macro code

The [EJECTOVR macro](../bxamac/EJECTOVR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.