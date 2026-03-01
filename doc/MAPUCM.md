# MAPUCM macro

This macro maps the Unit Control Module definition

## Syntax

``` hlasm
&LABEL   MAPUCM &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- UCM      - Unit Controle Module definition
- UCMEFEXT - UCM individual device Entry Fixed EXTension
- UCMEIL   - UCM Event Indication List
- UCMEPEXT - UCM indiv. device Entry Pageable EXTension
- UCMFEXTA - UCM Fixed EXTension bAse
- UCMFSAVE - UCM Fixed extension SAVE area
- UCMLIST  - UCM List of individual device entries
- UCMPEXTA - UCM Pageable EXTension bAse
- UCMPRFX  - UCM MCS PReFiX area
- UCM2EXT  - UCM OS/VS2 EXTension

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPUCM macro](../bxamac/MAPUCM.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.