# MAPDOTU macro

This macro contains the Dynamic Output Text Unit Mappings

## Syntax

``` hlasm
&LABEL   MAPDOTU &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- DOCNTFLD - Dynamic Output length/parameter FieLD
- DOCNTLST - Dynamic Output LiST of text unit pointers
- DOCNUNIT - Dynamic Output text UNIT

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPDOTU macro](../bxamac/MAPDOTU.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.