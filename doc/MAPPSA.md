# MAPPSA macro

This macro maps the Prefixed Storage Area (Virtual 1st page)

Since the PSA is always addressable thru R0, a USING is
included in the expansion, setting the PSA addressable troughout
the program.

## Syntax

``` hlasm
&LABEL   MAPPSA &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- PSA - Prefixed Storage Area

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPPSA macro](../bxamac/MAPPSA.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.