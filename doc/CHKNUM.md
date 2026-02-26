# CHKNUM macro

Macro for testing whether an argument contains a valid numeric literal value.

## Syntax

``` hlasm
&LABEL   CHKNUM &MACRO=,               * Name of invoking macro        *
               &NAME=,                 * Name of variable being tested *
               &VAL=,                  * Value of variable to be tested*
               &MSGLVL=8,              * Msglvl in case of error       *
               &HEX=OK                 * Any other value disallows HEX
```

## MACRO

specifies the name of the invoking macro. This name will
be used on any MNOTEs generated.

## NAME

Specifies the name of the variable being tested. This name
will be used on any MNOTEs generated.

## VAL

Specifies the value to be tested.

## MSGLVL

Specifies the MSGLVL to use when generating an MNOTE.
Value can be 0-255, `*` or `**`. Defaults to 8. If specified as
`**` messages will be suppressed.

## HEX

Specifies whether or not the supplied value may be specified
as a hexadecimal literal. Defaults to OK.

## Macro code

The [CHKNUM macro](../bxamac/CHKNUM.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.