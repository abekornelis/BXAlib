# TRT macro

This macro replaces the TRT instruction

The macro guards against clobbering registers R1 and R2 when they're in use.

## Syntax

``` hlams
&LABEL   TRT   ,                       * Parameters in SYSLIST
```

The syntax for the TRT macro is identical to that of the TRT instruction.

## Macro code

The [TRT macro](../bxamac/TRT.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.