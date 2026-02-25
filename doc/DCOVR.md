# DCOVR macro

This macro handles the stack of DC modifications for use by the
DC macro, which replaces the assembler's DC instruction

## Syntax

``` hlasm
&LABEL   DCOVR &OPT,                   * Parameters are in &SYSLIST    *
               &NEWNAM                 * New name for *NEWNAME option
```

## LABEL

mandatory, except when &OPT=`*END`

To specify an override for an unlabeled DC, specify the label
of the last preceding labeled DC and the relative number of
the unlabeled statement to be overridden. E.g.: LABEG+3,
would  mean the third unlabeled DC after the DC with label
LABEG.

## OPT

specifies one of the following:
- `*END` cancels all outstanding DCOVR requests
- `*DS`  changes the DC into a DS, which may in turn
  be overridden using the [DSOVR macro](DSOVR.md)
- `*SUPPRESS` suppresses the definition of &LABEL
- `*NEWNAME` changes the DC for &LABEL into one for &NEWNAM,
- i.e. Specify `*NEWNAME`,newname,parmstring
- Other values override the DC-operand string

## NEWNAM

Specifies the new name, if &OPT=`*NEWNAME`
- &NEWNAM may optionally be followed by a parameter string
- If &NEWNAM specifies `*NONAME` the DC will become unlabeled

## SYSLIST

Specifies an operand string, which replaces the complete
operand string of the original DC statement.

## Macro code

The [DCOVR macro](../bxamac/DCOVR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.