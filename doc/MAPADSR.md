# MAPADSR macro

This macro maps the Symptom Record

## Syntax

``` hlasm
&LABEL   MAPADSR &DSECT=YES,           * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- ADSR     - Symptom Record sections 1 and 2
- ADSRCMPS - Symptom Record section 2.1
- ADSRDBST - Symptom Record primary symptom string
- ADSRROSD - Symptom Record secondary symptom string
- ADSR5ST  - Symptom Record section 5

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPADSR macro](../bxamac/MAPADSR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.