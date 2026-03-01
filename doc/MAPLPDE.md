# MAPLPDE macro

This macro maps the Link Pack Directory Entry

LPDEs are in a table, pointed to by `CVTLPDIA`. LPDEs are
consecutive in storage, end-of-table is marked by a dummy LPDE
which has `LPDENAME`=`XL8'FFFFFFFF'`

## Syntax

``` hlasm
&LABEL   MAPLPDE &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- LPDE - Link Pack Directory Entry

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPLPDE macro](../bxamac/MAPLPDE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.