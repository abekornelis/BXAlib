# ABNDPGM macro

This macro generates an out-of-line routine that abends the program
with a specified return code, normally the failing address.
The generated routine will normally be called through the [ABND](ABND.md) macro.

## Syntax

``` hlasm
&LABEL   ABNDPGM &CODE=,               * User Abend code               *
               &REASON=R14             * Reasoncode (dft: reg 14)
```

## CODE

specifies the user abend code to generate on the ABEND macro.

## REASON

specifies the register that contains the reason code,
normally the failing address. When omitted defaults to R14.

## Macro code

The [ABNDPGM macro](../bxamac/ABNDPGM.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.