# MAPDSCB2 macro

This macro maps the Data Set Control Block formats 2

The DSCB-formats are documented in DFSMSdfp Advanced Services Topic 1.1.1 ff

## Syntax

``` hlasm
&LABEL   MAPDSCB2 &DSECT=YES,          * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- DSCB2 - Data Set Control Block - format 2

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPDSCB2 macro](../bxamac/MAPDSCB2.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.