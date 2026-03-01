# SETOF macro

Turn off a bit in a bit-field

## Syntax variant 1

``` hlasm
&LABEL   SETOF &ADR,                   * Address of bit-field          *
               &MASK                   * Bit field mask
```

## Syntax variant 2

``` hlasm
&LABEL   SETOF &BIT,...                * DCL-defined bit names
```

## ADR

specifies the location in storage where the bit-field resides.
Must be in offset(register) notation, or a symbolic name.

## MASK

specifies which bits are to be turned off

## BIT

specifies the name of a DCL-declared bit. Any number of
arguments may follow, but they all have to be DCL-declared
bit names too.

## Macro code

The [SETOF macro](../bxamac/SETOF.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.