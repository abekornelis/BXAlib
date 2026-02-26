# ENDSR macro

This macro generates code to end a subroutine

## Syntax

``` hlasm
&LABEL   ENDSR &RC=0,                  * Returncode, (reg) or *        *
               &KEEPREG=               * Registers NOT to be restored
```

## RC

Specifies the returncode. If not specified, defaults to 0.

If specified as `*`, the value in R15 will be used.

## KEEPREG

specifies a register or a list of registers that are not
to be restored upon return. The values of these registers
will be passed back to the caller.

## Macro code

The [ENDSR macro](../bxamac/ENDSR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.