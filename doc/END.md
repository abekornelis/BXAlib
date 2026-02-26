# END macro

- Terminate assembly. This macro replaces the normal END instruction
  and generates an overview of the subroutine call tree.
- The required OPSYN is issued by the PGM macro.

## Syntax

``` hlasm
&LABEL   END   &EP                     * Entry point label
```

## EP

specifies the entry point, as in the END instruction

## Macro code

The [END macro](../bxamac/END.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.