# MAPS99 macro

This macro maps the Control Blocks used with SVC 99 (DYNALLOC)

It adds the documented S99 constants that are not defined in IBM's `IEFZB4D0`, `IEFZB4D2`, `IEFZB476` macros.

## Syntax

``` hlasm
&LABEL   MAPS99 &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- EMDSECT1 - Dynalloc parameter list to IEFDB476
- EMDSECT2 - Dynalloc message buffer area
- EMDSECT3 - Dynalloc message buffer area array
- S99RB    - Dynalloc Request Block
- S99RBP   - Dynalloc Request Block Pointer
- S99RBX   - Dynalloc Request Block eXtension
- S99TUFLD - Dynalloc request Text Unit FieLD
- S99TUNIT - Dynalloc request Text UNIT
- S99TUPL  - Dynalloc request Text Unit Pointer List

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPS99 macro](../bxamac/MAPS99.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.