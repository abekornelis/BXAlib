# GENMAPS macro

This macro expands 1 or more mapping macro's.
Used by the [PGM macro](PGM.md).

## Syntax

``` hlasm
&LABEL   GENMAPS &MAPS,                * Sublist of map-macro's        *
               &LIST=NO                * YES/NO create map-listing
```

## MAPS

specifies - in sublist notation - the mapping macro's to be
expanded. Must be in sublist notation.

## LIST

specifies whether or not the listing of the expanded mapping
macro's are to be included in the assembly listing.

## Macro code

The [GENMAPS macro](../bxamac/GENMAPS.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.