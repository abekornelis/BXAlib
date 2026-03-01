# RDATA macro

Define Remote DATA

All data defined thru the RDATA macro will be put into a remote
literal pool, which is created by the END-macro, using the RLTORG
macro.

## Syntax

``` hlasm
&LABEL   RDATA &OPCD,                  * Defining opcode               *
               &RD_MODE=ADD,           * COND for conditional entries  *
               &ALIGN=,                * Alignment                     *
               &MF=X                   * MF should not be specified
```

## LABEL

specifies the label of the data
if specified as two dashes (--) no label will be generated

## OPCD

specifies the defining opcode. The following opcodes are currently supported:
- CNOP,DC,DS,EQU
- SNAPHDR
- Any other opcode that requires no keyword parmaters

*Note:* on defining a DCB

For keyword parameters the following applies:
In stead of separating the keyword parameter name and its
value with an equal sign(=), separate them with a slash(/).
E.g.: RDATA DCB,DSORG/PS,RECFM/VBA,.....   etc.

## Macro code

The [RDATA macro](../bxamac/RDATA.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.