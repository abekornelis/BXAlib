# MAPSCCB macro

This macro maps the Service Call Control Block

The SCCB can be found through the `CVTSCPIN` pointer

## Syntax

``` hlasm
&LABEL   MAPSCCB &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- SCCB    - Service Call Control Block


*Note:* The following is mapped but not supported for embedding:
- SCCBCP  - SCCB CPu information entry
- SCCBHSA - SCCB HSA information entry
- SCCBMPF - SCCB MPF information entry

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPSCCB macro](../bxamac/MAPSCCB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.