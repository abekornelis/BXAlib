# MAPSDWA macro

This macro maps the System Diagnostic Work Area

## Syntax

``` hlasm
&LABEL   MAPSDWA &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- SDWA     - System Diagnostic Work Area
- SDWANRC1 - SDWA Non-ReCordable extension 1
- SDWANRC2 - SDWA Non-ReCordable extension 2
- SDWANRC3 - SDWA Non-ReCordable extension 3
- SDWAPTRS - SDWA PoinTeRS extension block
- SDWARC1  - SDWA ReCordable extension 1
- SDWARC2  - SDWA ReCordable extension 2
- SDWARC3  - SDWA ReCordable extension 3

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPSDWA macro](../bxamac/MAPSDWA.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.