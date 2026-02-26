# GOTO macro

- Structured programming macro: GOTO
- Conditionally branches to a target

## Syntax

``` hlasm
&LABEL   GOTO  ,                       * SYSLIST contains condition
```

There are 5 syntax variations:

1. GOTO label
2. GOTO label,condition
3. GOTO label,UNLESS,condition
4. GOTO label,(condition)
5. GOTO label,(UNLESS,condition)

condition: as in IF macro

## Macro code

The [GOTO macro](../bxamac/GOTO.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.