# SNAPNTRY macro

This macro generates entries in the STORAGE and STRHDR lists and is
intended for use with BXADBG00 only.

It is required that the calling program include the [MAPSNAP macro](MAPSNAP.md).
There must be an active `USING SNAPLIST,R2`
          and an active `USING SNAPHLIST,R3`

## Syntax

``` hlasm
&LABEL   SNAPNTRY &ADR,                * Starting address or (reg)     *
               &LEN=,                  * Length or (reg)               *
               &END=,                  * (reg)                         *
               &HDR=                   * Address of header or (reg)
```

## ADR

Specifies the starting address of a storage area to be dumped

## LEN

Specifies the length of the storage area to be dumped

## END

Specifies a register contining the end-address

## HDR

Specifies the address of the header for the storage area dump
or specifies a the header, enclosed in single quotes

## Macro code

The [SNAPNTRY macro](../bxamac/SNAPNTRY.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.