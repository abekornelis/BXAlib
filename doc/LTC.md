# LTC macro

Load and Test Characters into a register

## Syntax

``` hlasm
&LABEL   LTC   &REG,                   * Register to load              *
               &LOC,                   * Location of character         *
               &MASK                   * Mask for ICM (default=NNNY)
```


## REG

specifies the register to load

## LOC

specifies the location of the character(s) to be loaded

## MASK

specifies which bytes of the register are to be loaded

## Macro code

The [LTC macro](../bxamac/LTC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.