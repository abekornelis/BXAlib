# DCL macro

This macro expands 1 mapping macro to reserve storage

## Syntax

``` hlasm
&LABEL   DCL   &CB,                    * Control block name            *
               &LBL                    * Label for dependent using
```

The following syntaxes have been defined:
1. Embedded control block
   - &LABEL is the label for the embedded control block
     if omitted, dependent USINGs will not be generated
     automatically.
   - &CB    is name (acronym) of control block to embed
   - &LBL   is label for automatic dependent usings. If omitted
     unlabeled dependent usings will be generated. If
     specified as `*NOUSE`, no USING will be generated
     automatically.
2. Define bit names
   - &LABEL is the label of the field containing the bits. Must not be omitted.
   - &CB=`*BITS`
   - &SYSLIST(2) ff are names of bits to be allocated to consecutive
     bit positions. More than 8 may be specified.
     To define a name for more than bit at a time,
     EQUOVR and EQU must be used.
3. Define code field and code values
   - &LABEL is the label of the field containing the bits. Must not be omitted.
   - &CB=`*CODE`
   - &LBL   is field type designation. E.g. XL1 or H.
   - &SYSLIST(3) ff are names of codes to be assigned to the code
     field. Each may be specified as a name or as a
     pair (name,value). Omitted values are assigned in
     ascending order from the last value specified, or
     (by default) from 0 upward.

## Macro code

The [DCL macro](../bxamac/DCL.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.