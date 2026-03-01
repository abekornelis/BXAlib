# MAPRT1W macro

This macro maps the RTM1 Work Area

## Syntax

``` hlasm
&LABEL   MAPRT1W &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- RTMW     - RTM1 save/Work area
- RT1TRACK - RTM1 TRACKing area
- RT1TRECC - RTM1 RECursion Control data
- RT1W     - RTM1 Work area

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPRT1W macro](../bxamac/MAPRT1W.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.