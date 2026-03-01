# MAPOCPL macro

Mapping macro for parameter list entries used by OPEN/CLOSE SVC's

This parameter list is used by:
- SVC 19 = OPEN
- SVC 20 = CLOSE
- SVC 22 = OPEN,TYPE=J
- SVC 23 = CLOSE,TYPE=T

## Syntax

``` hlasm
&LABEL   MAPOCPL &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- OC24 - Open/Close parameter list (24-bit mode)
- OC31 - Open/Close parameter list (31-bit mode)

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPOCPL macro](../bxamac/MAPOCPL.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.