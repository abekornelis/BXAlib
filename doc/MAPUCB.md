# MAPUCB macro

This macro maps the Unit Control Block

## Syntax

``` hlasm
&LABEL   MAPUCB &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- UCB      - Unit Control Block
- UCBOCR   - UCB extension - Optical Character Reader
- UCBPDCTA - UCB extension - Channel to channel Adapter
- UCBUCS   - UCB extension - Universal Character Set
- UCB3540X - UCB extension - 3540
- UCB3800X - UCB extension - 3800 printer

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPUCB macro](../bxamac/MAPUCB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.