# USING macro

This macro replaces the assembler's USING statement

## Syntax

``` hlasm
&LABEL   USING &DSECT,                 * Control block name            *
               &BASE                   * Register (or field) for using
```

The syntax for the USING macro is identical to that of the USING instruction.

## LABEL

optional USING label

## DSECT

specifies the control block to be set addressable.

## BASE

specifies either a register that points to `&DSECT` or a field
that contains a `&DSECT` as a label. If specified as a register
other registers may follow.

## Macro code

The [USING macro](../bxamac/USING.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.