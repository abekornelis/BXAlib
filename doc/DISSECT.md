# DISSECT macro

This macro Dissects a parameter into its constituent parts

## Syntax

```hlasm
&LABEL   DISSECT &TYPE,                * Type of parameter to dissect  *
               &INPUT                  * Parameter to dissect
```

## TYPE

must be one of the following:
- DB  = Displacement(Base)
- DLB = Displacement(Length,Base)
- DRB = Displacement(Register,Base)
- DXB = Displacement(indeX,Base)
- I   = Immediate
- M   = Mask
- R   = Register

## INPUT
will normally be a parameter passed to a macro that replaces
some machine instruction. May have been pre-processed with
the [SPLIT macro](SPLIT.md).

## Macro code

The [DISSECT macro](../bxamac/DISSECT.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.