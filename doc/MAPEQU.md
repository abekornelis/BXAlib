# MAPEQU macro

Mapping macro for standard equates

- See the [GENREGS macro](GENREGS.md) for the register equates.
- See the [GENBITS macro](GENBITS.md) for the bit equates.

Additionally defined are:

| Symbol      | Value   |
|-------------|---------|
| NNNN        | B'0000' |
| NNNY        | B'0001' |
| NNYN        | B'0010' |
| NNYY        | B'0011' |
| NYNN        | B'0100' |
| NYNY        | B'0101' |
| NYYN        | B'0110' |
| NYYY        | B'0111' |
| YNNN        | B'1000' |
| YNNY        | B'1001' |
| YNYN        | B'1010' |
| YNYY        | B'1011' |
| YYNN        | B'1100' |
| YYNY        | B'1101' |
| YYYN        | B'1110' |
| YYYY        | B'1111' |
| NOBYTE      | NNNN    |
| ALLBYTES    | YYYY    |
| ALET_PRIM   | 0       |
| ALET_SEC    | 1       |
| ALET_HOME   | 2       |

## Syntax

``` hlasm
         MAPEQU
```

## Macro code

The [MAPEQU macro](../bxamac/MAPEQU.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.