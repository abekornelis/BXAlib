# IF$ macro

Structured programming macro: IF$

This macro takes 1 argument, which is a list of the actual arguments.
The arguments come in 6 different syntax types. IF$ is a sub-macro
for use by the [IF macro](IF.md). IF$ tests a single condition for IF.

## Syntax

``` hlasm
&LABEL   IF$   &TARGET=,               * Optional target if cond. met  *
               &COND=                  * Condition for TARGET
.*                                     * Condition in &SYSLIST(1)
```

9 different syntax versions are allowed; each may or may not have the target label specified.

| Syntax variation        | usage notes                                      |
|-------------------------|--------------------------------------------------|
| cond                    | condition mnemonic                               |
| bitfield,...            | Must share byte-location                         |
| NOT,bitfield,...        | Must share byte-location                         |
| ANY,bitfield,...        | Must share byte-location                         |
| field1,cond             | storage or register; cond: Z,NZ,M,NM,P,NP        |
| field1,rel,field2       | storage and/or register; rel: EQ,NE,LT,LE,GT,GE  |
| cond,opcode,oper1,oper2 | condition with operation                         |
| codefield               | only 1 can be specified                          |
| NOT,codefield           | only 1 can be specified                          |

## TARGET

may be specified as a label-na, i.e. a RX-type address, or
it may be specified as (register).

If TARGET is not specified, COND is ignored and a normal
IF-THEN-ELSE-ENDIF of IF-THEN-ENDIF sequence will be generated.

## COND

If TARGET is specified, COND must be TRUE (which is the default)
or it must specify FALSE. For COND=TRUE a branch to TARGET will
be taken if the condition in &SYSLIST(1) is true, otherwise
the branch to TARGET will be taken whenever the condition in
&SYSLIST(1) is false.

## Macro code

The [IF$ macro](../bxamac/IF$.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.