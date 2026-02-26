# LEAVE macro

Structured programming macro: LEAVE

Combines with [DO macro](DO.md) to abort an executing loop

## Syntax

``` hlasm
&LABEL   LEAVE &DOLAB=                 * Label of associated DO
.*                                     * Condition in &SYSLIST
```

Syntax variations:
1. LEAVE
2. LEAVE cond
3. LEAVE UNLESS,cond

where cond is a condition, as described in the [IF macro](IF.md)

## Macro code

The [LEAVE macro](../bxamac/LEAVE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.