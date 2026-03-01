# SAVE_PSWKEY macro

Helper macro for [SETMODE macro](SETMODE.md) to extract copy current PSW key to a register

## Syntax

``` hlasm
         SAVE_PSWKEY &REG              * Register (no parentheses)
```

## REG

Register to receive current PSW key value. The default is R2.

## Macro code

The [SAVE_PSWKEY macro](../bxamac/SETMODE0.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.