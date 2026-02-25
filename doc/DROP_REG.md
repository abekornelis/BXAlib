# DROP_REG macro

Removes a single entry from the &BXA_USELBL, &BXA_USEREG, and &BXA_USEFLD tables.

Returncode will be set as follows:
- 0 = all information removed, no register USE
- 4 = information removed for a register USE
- 8 = no found: no information removed

## Syntax

``` hlasm
         DROP_REG &LAB,&NDX,&I=0
```

## LAB

is label to search/remove

## NDX

is register index to search/remove

## I

is index in BXA_USE... tables

## Macro code

The [DROP_REG macro](../bxamac/DROP0.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.