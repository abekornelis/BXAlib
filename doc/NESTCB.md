# NESTCB macro

This macro creates a nested control block within another one

## Syntax

``` hlasm
&LABEL   NESTCB &CB,                   * Nested control block id       *
               &TYPE,                  * Type - defaults to hex        *
               &PRFX,                  * Prefix to use if label blank  *
               &INIT=,                 * Initialization value          *
               &LEN=                   * Length in parentheses
```

## CB

Name of the control block to embed.
Available Control blocks for embedding are documented in [Control blocks available for DCL]($DOC.md/#Control-blocks-available-for-DCL)

## LABEL

Label to assign to the reserved area for the embedded control block.

## TYPE

Type to use for defining the area. Supported values are standard assembler types: X, C, F, H, D, B

## PRFX

When LABEL is omitted, the label assigned to the area being reserved defaults to
the control block name specified on the CB parameter, prefixed with the PRFX parameter, if that is specified.

## INIT

Initialization value for the embedded control block.

Defaults to space when TYPE is C, zero otherwise.

## LEN

Optional parameter to override the length of the control block as defined in its mapping macro.

## Macro code

The [NESTCB macro](../bxamac/NESTCB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.