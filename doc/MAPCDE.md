# MAPCDE macro

This macro maps the Contents Directory Entry

CDEs for FLPA/MLPA are in a chain. Field `CVTQLPAQ` points to
a dummy header entry, which points to the first real CDE on the
queue. The last entry in the chain has CDCHAIN=0.

CDEs for dynamic LPA are also in a chain, Field `ECVTDLPF` points
to the first entry - no header entry is provided. The last entry
in the chain is a dummy entry with CDENAME=XL8'00'. It points to
the first real entry in the FLPA/MLPA queue.

## Syntax

``` hlasm
&LABEL   MAPCDE &DSECT=YES,            * YES or NO                     *
               &CB=,                   * Control block to generate     *
               &PRFX=                  * Prefix to use
```

## DSECT

- If `YES` (or omitted) indicates to generate the block as a DSECT.
- if `NO` specifies to generate the block as an embedded area.

## CB

Specify the short name (i.e. without its three-character prefix) of the control block when embedding one with DESCT=NO.

Supported values:
- CDE - Contents Directory Entry

## PRFX

Specify a value to set a prefix when embedding the control block with DESCT=NO.
Ignored for DSECT=YES.

## Macro code

The [MAPCDE macro](../bxamac/MAPCDE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.