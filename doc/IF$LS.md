# IF$LS macro

Load a signed field or literal into a register

This is a sub-macro for use by the [IF$ macro](IF$.md) only.

## Syntax

``` hlasm
&LABEL   IF$LS &REG,                   * Register to load              *
               &FLD,                   * Field or literal with value   *
               &LITLEN,                * Length of literal or 0 for fld*
               &TYPE                   * Type of field
```

## Macro code

The [IF$LS macro](../bxamac/IF$LS.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.