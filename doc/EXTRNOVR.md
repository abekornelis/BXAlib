# EXTRNOVR macro

This macro fills the stack of EXTRN modifications for use by the
[EXTRN macro](EXTRN.md), which replaces the assembler's EXTRN instruction

## Syntax

``` hlasm
&LABEL   EXTRNOVR &OPT,                * See below for valid keywords  *
               &NEWNAM                 * New name for *NEWNAME option
```

## LABEL

mandatory, except when &OPT=`*END`
The specified EXTRN name will be overridden.

## OPT

specifies one of the following:
- `*END` cancels all outstanding EXTRNOVR requests
- `*SUPPRESS` suppresses the definition of &LABEL
- `*WXTRN`   changes the EXTRN name to a WXTRN name
- `*NEWNAME` changes the EXTRN for &LABEL into one for &NEWNAM, i.e. Specify `*NEWNAME`,newname

## NEWNAM

Specifies the new name, if &OPT=`*NEWNAME`

## Macro code

The [EXTRNOVR macro](../bxamac/EXTRNOVR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.