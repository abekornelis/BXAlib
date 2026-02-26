# IF macro

Structured programming macro: IF

Combines with [ELSE macro](ELSE.md) and [ENDIF macro](ENDIF.md) to conditionally execute code-blocks

If the SYSLIST conatains only a single argument, which is enclosed
in parentheses, then that condition string is passed to the [IF$ macro](IF$.md) as is.
Otherwise, the arguments are assembled into a parenthesized
string, which is then passed to the [IF$ macro](IF$.md).

## Syntax

``` hlasm
&LABEL   IF    &TARGET=,               * Optional target if cond. met  *
               &COND=                  * Condition for use with TARGET
.*                                     * Condition in &SYSLIST
```

See IF$ for basic IF-syntax

The following rules apply:
1. Basic condition - as in IF$
2. Several basic conditions, separated by AND:
   cond1,AND,cond2,AND,cond3,...
3. Several basic conditions, separated by OR:
   cond1,OR,cond2,OR,cond3,...
4. Mixing AND and OR is not supported.
5. Condition nesting by means of parentheses is not supported.

If TARGET is not specified, a normal IF-THEN-ELSE will be built.

For TARGET specified and COND=TRUE or omitted, if the specified
condition is met, a branch to TARGET will be taken.

For TARGET specified and COND=FALSE, if the specified condition is
not met, a branch to TARGET will be taken.

## Macro code

The [IF macro](../bxamac/IF.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.