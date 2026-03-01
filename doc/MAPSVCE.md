# MAPSVCE macro

This macro maps the entries of the SVC table and the entries of
the SVC Udate Recording Table

## Syntax

``` hlasm
&LABEL   MAPSVCE &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- SVCENTRY - SVC table ENTRY
- SVCURT   - SVC Update Recording Table entry

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPSVCE macro](../bxamac/MAPSVCE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.