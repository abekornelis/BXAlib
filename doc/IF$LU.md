# IF$LU macro

Load an unsigned field or literal into a register

This is a sub-macro for use by the [IF$ macro](IF$.md) only

## Syntax

``` hlasm
&LABEL   IF$LU &REG,                   * Register to load              *
               &FLD,                   * Field or literal with value   *
               &LITLEN,                * Length of literal or 0 for fld*
               &TYPE
```

## Macro code

The [IF$LU macro](../bxamac/IF$LU.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.