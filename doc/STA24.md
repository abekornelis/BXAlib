# STA24 macro

Store a 24-bit address from a register into memory

## Syntax

``` hlasm
&LABEL   STA24 &REG,                   * Register to store             *
               &LOC,                   * Location of address           *
               &MASK                   * Mask for STCM (default=YNNN)
```

## REG

specifies the register to load

## LOC

specifies the location of the address to be loaded

## MASK

specifies which bytes of the register are to be loaded

## Macro code

The [STA24 macro](../bxamac/STA24.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.