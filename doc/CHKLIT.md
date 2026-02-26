# CHKLIT macro

Macro for testing whether an argument contains a valid numeric literal value.

Returns the value of the specified literal in &BXA_NUMVAL
And a returncode in &BXA_RC as follows:
- 0 valid literal, value is in &BXA_NUMVAL
- 4 empty literal, value 0 in &BXA_NUMVAL
-   or valid alternate form literal, value is in &BXA_NUMVAL
- 8 invalid literal, value 0 in &BXA_NUMVAL

## Syntax

``` hlasm
         CHKLIT &VAL,                  * Value to be tested            *
               &HEX=OK,                * Any other value disallows HEX *
               &BIN=OK,                * Any other value disallows Bin *
               &ALT=NOK,               * Alternate form not allowed    *
               &MSG=NO                 * Suppress message for oversized
```

## VAL

Specifies the value to be tested.


## HEX

Specifies whether or not the supplied value may be specified
as a hexadecimal literal. Defaults to OK.

## BIN

Specifies whether or not the supplied value may be specified
as a binary literal. Defaults to OK.

## ALT

Specifies whether of not alternate form literals
may be specified. Defaults to NOK.
Allows the following literals:
- =X'....' if HEX=OK
- =B'....' if BIN=OK
- =F'...' or F'...'
- =H'...' or H'...'

## MSG

YES/NO display message if literal is valid, but too large
to be used.

## Macro code

The [CHKLIT macro](../bxamac/CHKLIT.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.