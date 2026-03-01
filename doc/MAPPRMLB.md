# MAPPRMLB macro

This macro maps the return and reason codes for IEFPRMLB as well as
its parameter areas

## Syntax

``` hlasm
&LABEL   MAPPRMLB &DSECT=YES,          * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- PRM_LIST_BUFFER    - PaRMlib services LIST BUFFER
- PRM_MESSAGE_BUFFER - PaRMlib services MESSAGE BUFFER
- PRM_READ_BUFFER    - PaRMlib services BUFFER for member READ

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPPRMLB macro](../bxamac/MAPPRMLB.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.