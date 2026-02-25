# BASNL macro

Branch and Save on Not-Low condition

## Syntax

``` hlasm
&LABEL   BASNL &REG,                   * Register for return address   *00200000
               &LOC,                   * Branch target or (reg)        *00210000
               &TYPE=LOCAL             *                                00220000
```

## Macro code

The [BASNL macro](../bxamac/BASNL.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.