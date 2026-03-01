# MAPSMDE macro

This macro maps the System Managed Directory Entry

Warning: Field `SMDE_LEN` has been renamed to `SMDE_SIZE`

## Syntax

``` hlasm
&LABEL   MAPSMDE &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- SMDE       - System Managed Directory Entry basic section

*Note:* The following are mapped but not supported for embedding:
- SMDE_FD    - SMDE hfs File Descriptor section
- SMDE_NAME  - SMDE NAME section
- SMDE_NLST  - SMDE NoteLiST section
- SMDE_PNAME - SMDE Primary NAME section
- SMDE_TOKEN - SMDE TOKEN section

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPSMDE macro](../bxamac/MAPSMDE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.