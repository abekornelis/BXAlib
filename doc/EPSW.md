# EPSW macro

Extract current PSW

## Syntax

``` hlasm
&LABEL   EPSW  &REG                    * Register set to be used
```


## REG

specifies an even register. The PSW will be placed in register
&REG and &REG+1.

## Macro code

The [EPSW macro](../bxamac/EPSW.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.