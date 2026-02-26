# DO macro

- Structured programming macro: DO
- Combines with LEAVE and ENDDO to repeatedly execute code-blocks

## Syntax

```hlasm
&LABEL   DO    ,                       * SYSLIST contains condition
```

Syntax variations:
1. DO WHILE,condition
2. DO UNTIL,condition
3. DO count                         \* Literal, field, or (reg)
4. DO                               \* For use with LEAVE macro

condition: as in [IF macro](IF.md)

## Macro code

The [DO macro](../bxamac/DO.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.