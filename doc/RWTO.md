# RWTO macro

WTO with remote text

## Syntax

``` hlasm
&LABEL   RWTO  &TEXT                   * Text for WTO
```

## LABEL

specifies an optional label

## TEXT

specifies the text for the WTO. Must specify one of the following:
- Literal text, enclosed in apostrophes
- Fieldname of the field containing the parmlist - see [MAPWTOPL macro](MAPWTOPL.md)
- (reg) pointing to the parmlist - see [MAPWTOPL macro](MAPWTOPL.md)

## Macro code

The [RWTO macro](../bxamac/RWTO.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.