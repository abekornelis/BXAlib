# EXSR macro

EXecute a SubRoutine

## Syntax

``` hlasm
&LABEL   EXSR  &SUBR,                  * Routine to be called          *
               &COND,                  * Calling condition             *
               &TYPE,                  * Type of subroutine involved   *
               &SUBRS=,                * Subroutine names              *
               &ARSAVE=                * YES or NO
```
## SUBR

specifies the label of a SUBR statement or (reg)

## COND

specifies a condition for conditional execution

## TYPE

specifies `INT`ernal subroutine or `EXT`ernal subroutine (CSECT)

## SUBRS

specifies the routines that may be invoked when SUBR=(reg)

## ARSAVE

specifies whether or not to save/restore access registers
valid only for TYPE=EXT

## Macro code

The [EXSR macro](../bxamac/EXSR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.
