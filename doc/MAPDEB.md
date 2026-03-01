# MAPDEB macro

This macro maps the Data Extent Block

## Syntax

``` hlasm
&LABEL   MAPDEB &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- DEB      - Data Extent Block
- DEBACSMD - DEB ACcesS Method Dependent section
- DEBDASD  - DEB Direct Access Storage Device section
- DEBSUBNM - DEB SUBroutine NaMe section
- DEBXTN   - DEB eXTeNsion section for OS/VS2
- DEB2XTN  - DEB 2nd eXTeNsion

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPDEB macro](../bxamac/MAPDEB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.