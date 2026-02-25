# BEGSR macro

This macro generates entry logic for subroutines

## Syntax

``` hlasm
&LABEL   BEGSR &TYPE=,                 * Nothing, ESTAE, or RETRY      *
               &LVL=                   * ESTAE level
```

## TYPE

indicates the type of subroutine being defined:
- if omitted or defaulted to INT, specifies a normal
  (ie: INTernal) subroutine
- if ESTAE, specifies an ESTAE-type recovery routine
  The ESTAE is required to specify as the user parameter the
  external savearea (=R13) as set up by the PGM-macro.
- if RETRY, specifies a dedicated retry routine. For these
  routines no save-area is needed, and no exit code is gen'd

## LVL

Nesting level of active ESTAE routines. Normally value
should be one, except for ESTAE's that are to protect
another (active) ESTAE.

*Remark:*
Save area usage for ESTAE-type subroutines differs somewhat
from the normal SA standards. It takes two inteernal SA's:
the first is used to store regsters R14-R12 from the
external SA, the second is used to store registers R14-R2,
R3 with the contents of R13, R4-R6 with the contents of the
first three fullwords of the external SA, and R7-R12 with
garbage. The external SA is then available for reuse and
can be addressed thru R13 in the usual way.
