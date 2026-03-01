# MAPBITS macro

Mapping macro for bit equates

Corrected bit defintitions from IEZBITS are used.

Additionally defined are:

| Symbol      | Value         |
|-------------|---------------|
| NOBITS      | X'00'         |
| ALLBITS     | X'FF'         |
| NOT_BIT0    | ALLBITS-BIT0  |
| NOT_BIT1    | ALLBITS-BIT1  |
| NOT_BIT2    | ALLBITS-BIT2  |
| NOT_BIT3    | ALLBITS-BIT3  |
| NOT_BIT4    | ALLBITS-BIT4  |
| NOT_BIT5    | ALLBITS-BIT5  |
| NOT_BIT6    | ALLBITS-BIT6  |
| NOT_BIT7    | ALLBITS-BIT7  |
| LISTEND     | BIT0          |
| NOT_LISTEND | X'FF'-LISTEND |
| AMODE31     | BIT0          |
| AMODE24     | X'FF'-AMODE31 |

## Syntax

``` hlasm
         MAPBITS ,
```

## Macro code

The [MAPBITS macro](../bxamac/MAPBITS.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.