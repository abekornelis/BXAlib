# LTA24 macro

Load and Test 24-bit address into a register

## Syntax

```hlasm
&LABEL   LTA24 &REG,                   * Register to load              *
               &LOC,                   * Location of address           *
               &MASK,                  * Mask for ICM (default=NYYY)   *
               &RELOAD=                * YES, NO, QUICK
```

## REG

specifies the register to load

## LOC

specifies the location of the address to be loaded

## MASK

specifies which bytes of the register are to be loaded

## RELOAD

if YES, specifies that the register to be loaded is also
used as a base register to address the field.
if NO, specifies that the register to be loaded will not be
used as a base register to address the field.
if QUICK, specifies that the register to be loaded is also
used as a 24-bit base register to address the field.

## Macro code

The [LTA24 macro](../bxamac/LTA24.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.