# LOOP macro

Structured programming macro: LOOP

Combines with the [DO macro](DO.md) to repeat an executing loop

*Note:* You can use COPY and OPSYN to rename the LOOP macro to `ITERATE` or `REPEAT`
or any other keyword of your liking.

## Syntax

``` hlasm
&LABEL   LOOP  &DOLAB=                 * Label of associated DO
.*                                     * Condition in &SYSLIST
```

Syntax variations:

1. LOOP
2. LOOP cond
3. LOOP UNLESS,cond

where cond is a condition, as described in the [IF macro](IF.md)

## Macro code

The [LOOP macro](../bxamac/LOOP.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.