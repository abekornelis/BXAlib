# MAPDCB macro

This macro maps the Data Control Block

The DCB must be located below 16M

## Syntax

``` hlasm
&LABEL   MAPDCB &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- BDW - Block Descriptor Word
- DCB - Data Control Block
- RDW - Record Descriptor Word
- SDW - Segment Descriptor Word

*Note:* The following is mapped but not supported for embedding:
- SCW - GRS Queue Hash Table ENTry

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPDCB macro](../bxamac/MAPDCB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.