# BALC macro

Branch and Link on condition

## Syntax

``` hlasm
&LABEL   BALC  &COND,                  * Condition                     *
               &REG,                   * Register for return address   *
               &DEST,                  * Destination address or (reg)  *
               &TYPE=LOCAL             * BAL/BALR
```

## COND

specifies on which condition the BAL is to be executed

valid values are:
- E,  H,  L,  M,  O,  P,  Z
- NE, NH, NL, NM, NO, NP, NZ

## REG

Specifies the register to contain the return address

## DEST

Specifies the address to branch to. If specified as a
(register) a BALR will be generated in stead of a BAL.

## TYPE

Specifies whether the designated routine is reached thru
a local (BAL) branch or a remote (BALR) branch

## Macro code

The [BALC macro](../bxamac/BALC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.