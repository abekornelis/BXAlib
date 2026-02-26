# GLUE macro

Call a program that may have another AMODE

This macro is intended for calling a program that may or may not
be in another AMODE. Registers R0 thru R13 are supposed to be
set up for interfacing with the target program, and will therefore
not be modified by this macro.

## Syntax

``` hlasm
&LABEL   GLUE  &DEST,                  * Destination register          *
               &AMODE,                 * Desired AMODE                 *
               &MF=                    * Macro form
```

## DEST

specifies the register containing the destination address
which is the entry point address of the program to be
invoked.

## AMODE

specifies the AMODE for the called program, used only on MF=E.
- 31: Makes sure the destination pgm is called with AMODE=31
- 24: Makes sure the destination pgm is called with AMODE=24
- Omitted: Amode is taken from &DEST-register:
  AMODE 24 if bit0 is 0, AMODE 31 if bit0 is 1

## MF

Specifies the macro form:
- L specifies the list form
- (E,addr) or (E,(reg)) specifies the execute form.
  addr must be a location, that is addressed thru R13, and
  must reside below the 16M-line

## Macro code

The [GLUE macro](../bxamac/GLUE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.