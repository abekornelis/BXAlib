# DSOVR macro

This macro handles the stack of DS modifications for use by the
DS macro, which replaces the assembler's DS instruction

## Syntax

``` hlasm
&LABEL   DSOVR &OPT,                   * Parameters are in &SYSLIST    *
               &NEWNAM                 * New name for *NEWNAME option
```

## LABEL

mandatory, except when &OPT=`*END`

To specify an override for an unlabelled DS, specify the label
of the last preceding labeled DS and the relative number of
the unlabelled statement to be overridden. E.g.: LABEG+3,
would  mean the third unlabelled DS after the DS with label
LABEG.

## OPT

specifies one of the following:
- `*END` cancels all outstanding DSOVR requests
- `*SUPPRESS` suppresses the definition of &LABEL
- `*NEWNAME` changes the DS for &LABEL into one for &NEWNAM, i.e. Specify `*NEWNAME`,newname,parmstring
- Other values override the DS-operand string
- NEWNAM Specifies the new name, if &OPT=`*NEWNAME`.
      &NEWNAM may optionally be followed by a parameter string
      If &NEWNAM specifies `*NONAME` the DS will become unlabelled

## SYSLIST

Specifies an operand string, which replaces the complete
operand string of the original DS statement.

## Macro code

The [DSOVR macro](../bxamac/DSOVR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.