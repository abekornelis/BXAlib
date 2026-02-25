# EQUOVR macro

This macro handles the stack of EQU modifications for use by the
[EQU macro](EQU.md), which replaces the assembler's EQU instruction

## Syntax

``` hlasm
&LABEL   EQUOVR &VALUE,                * Value to be assigned          *
               &LEN,                   * Length attribute              *
               &TYPE,                  * Type attribute                *
               &LOC                    * Location
```

## LABEL

mandatory, except when &VALUE=`*END`

## VALUE

specifies the value to be assigned to &LABEL.
- `*END` cancels all outstanding EQUOVR requests
- `*SUPPRESS` suppresses the EQU of &LABEL
- `*NEWNAME` changes the EQU for &LABEL into one for &LEN, i.e. Specify `*NEWNAME`,newname
- Other values override the EQU-value with the same label

## LEN

specifies an explicit length attribute

## TYPE

specifies an explicit type attribute.
Assigned types are documented in the [EQU macro](EQU.md)

## LOC

Valid only if &TYPE=C'b' or C'v'. Specifies a relocatable
expression, which resolves to the location of the byte for
which the override specifies a mask, bit pattern, or value.

## Macro code

The [EQUOVR macro](../bxamac/EQUOVR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.