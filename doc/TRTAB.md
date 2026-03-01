# TRTAB macro

This macro generates tables for use wit TR and/or TRT instructions

## Syntax

``` hlasm
&LABEL   TRTAB &TYPE,                  * Base type of table            *
               &CHARS=                 * Other valid characters
```

## TYPE

- UC       for uppercase characters (A-Z)
- LC       for lowercase characters (a-z)
- ALPHA    for lower and/or uppercase characters (A-Z, a-z)
- DIGITS   for decimal digits (0-9)
- HEX      for hex digits (0-9, A-F)
- NOT      for anything except specified `&CHARS`
- NOTUC    for anything except uppercase
- NOTLC    for anything except lowercase
- NOTALPHA for anything except upper and/or lowercase chars
- NOTDIGIT for anything except decimal digits
- NOTHEX   for anything except hex digits
- TOHEX    for translation from X'00'-X'0F' to readable hex
- TOLOWER  for translation from uppercase to lowercase
- TOUPPER  for translation from lowercase to uppercase

## CHARS

a sublist of allowable characters, decimal codes, or hex
codes in the range 0-255 (X'00'-X'FF'). In singles or in
pairs for translation.


## Macro code

The [TRTAB macro](../bxamac/TRTAB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.