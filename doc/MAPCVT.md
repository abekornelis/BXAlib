# MAPCVT macro

This macro maps the Communications Vector Table

## Syntax

``` hlasm
&LABEL   MAPCVT &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

- CVT      - Communications Vector Table
- CVTFIX   - Communications Vector Table preFIX
- CVTVSTGX - CVT Virtual SToraGe eXtension
- CVTXTNT1 - CVT os-os/vs common eXTension
- CVTXTNT2 - CVT os/vs1-os/vs2 common eXTension

*Note:* CVTFIX is mappped when DSECT=YES, but cannot be embedded using DSECT=NO

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPCVT macro](../bxamac/MAPCVT.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.