# LTORG macro

Create a literal pool. This macro replaces the normal LTORG
instruction. The required OPSYN is issued by the [PGM macro](PGM.md).

This macro extends the literal pool with code defined on the [EXQ macro](EXQ.md)
which is used by:
- the [EXCLC macro](EXCLC.md)
- the [EXMVC macro](EXMVC.md)
- the [EXSVC macro](EXSVC.md)
- the [EXTR macro](EXTR.md)
- the [EXTRT macro](EXTRT.md)
- the [EXXC macro](EXXC.md)

## Syntax

``` hlasm
&LABEL   LTORG ,
```

## Macro code

The [LTORG macro](../bxamac/LTORG.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.