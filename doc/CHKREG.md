# CHKREG macro

This macro checks if the argument given is a register

- &BXA_RC will contain 0 if &REG is an EQUated register
- &BXA_RC will contain 4 if &REG is a valid number 0-15
- &BXA_RC will contain 8 if &REG is not a valid register
- &BXA_NUMVAL will contain the register number if &BXA_RC is 0 or 4

## Syntax

``` hlasm
         CHKREG &REG,                  * Value to be tested            *
               &TYPE                   * Type of register required
```

## REG

Name or number to be tested for valid register number

## Macro code

The [CHKREG macro](../bxamac/CHKREG.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.