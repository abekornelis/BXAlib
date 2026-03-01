# SETMODE macro

Set operational mode

## Syntax

``` hlasm
&LABEL   SETMODE &MODE,                * Mode indicator                *
               &OPTION,                * Option indicator              *
               &KEY=,                  * Desired storage key           *
               &SAVE=                  * (reg) to save current PSW key
```

## MODE

specifies the desired mode. Valid values are:
- `SUP`    to switch to supervisor mode
- `PROB`   to switch to problem program mode
- `AR`     to switch to access register mode
- `PRIM`   to switch to primary mode
- `PSWKEY` to change the current PSW key
- `SMC`    to switch to step-must-complete status
- `NOSMC`  to cancel step-must-complete status

## OPTION

specifies an option for the specified MODE. Valid are:
- `PSWKEY,SAVE` to save the PSW key in R2
- `PSWKEY,RESET` to reset the PSW key to its former value

## KEY

specifies the desired storage key. Used with `SUP`/`PROB`/`PSWKEY`.
For `SUP` the default is `ZERO`, for `PROB` the default is `NZERO`.
For `PSWKEY` there is no default.

## SAVE

Specifies a (reg) which must contain the current PSW key
Used with `PSWKEY` and `SUP`.

## Macro code

The [SETMODE macro](../bxamac/SETMODE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.