# MAPPMAR macro

This macro maps the Program Management Attribute Record (associated with [SMDE](SMDE.md))

Warning: field `PMARA_LEN` is renamed to `PMARA_SIZE`

## Syntax

``` hlasm
&LABEL   MAPPMAR &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- PMAR  - Program Management Attribute Record
- PMARA - PMAR - load module extension
- PMARL - PMAR - program object extension
- PMARR - PMAR - internal extension

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPPMAR macro](../bxamac/MAPPMAR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.