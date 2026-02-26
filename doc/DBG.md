# DBG macro

This macro generates debugging code.

## Syntax

``` hlasm
&LABEL   DBG   &TYPE,                  * LOAD, FIND, SNAP, CLOSE, ABEND*
               &TITLE,                 * SNAP: title for SNAP dump     *
               &EP=,                   * LOAD: entrypoint name         *
               &PTR=,                  * LOAD: pointer to debug module *
               &PLIST=,                * LOAD: fieldnames for plist    *
               &CB=,                   * SNAP: control blocks to dump  *
               &NTRT=,                 * FIND: NTRT field names        *
               &SAVE=                  * SNAP: YES/NO save/restore regs
```

## TYPE

specifies the type of code to generate:
- LOAD : loads and initializes the debug module
- FIND : retrieves existing DBG environment (if any)
- CLOSE: terminates and removes the debug module
- SNAP : generates a call to the debug module
- ABEND: forces an immediate S0C1-abend

## TITLE

used only with TYPE=SNAP. Specifies the title of the snapdump
used only with TYPE=ABND. Specifies NOWARN to suppress the
warning message normally issued for a deliberate S0C1-abend.

## EP

used only with TYPE=LOAD. Specifies the entry point name
of the debugging module.

## PTR

used only with TYPE=LOAD and TYPE=FIND.
Specifies the name of a field that
will be used to hold the entry point address to the debug
module. This fieldname is set on the TYPE=LOAD/FIND expansion
and subsequently used on all TYPE=SNAP and TYPE=CLOSE
expansions.

## PLIST

used only with TYPE=LOAD and TYPE=FIND.
Specifies the names of two fields:
- PLIST area for debug module, mapped by MAPDBG macro
- An area for the function code

## CB

used only with TYPE=SNAP. Specifies which control blocks
will be snapped. Valid values for CB are:
- USER all user control blocks will be SNAPped: SCB and anything pointed to by the SCB
- SYS  a variety of system control blocks will be SNAPped: CVT, SCVT, SVC-table, SVC update table, etc.
- DSPC the contents of dataspace BXADSPC will be SNAPped
- TASK the contents of TCB and related control blocks will be SNAPped

## NTRT

used only with TYPE=FIND.
Specifies the name of three fields:
- Plist area for NTRT macro
- An area for the retrieved token
- An area for the returncode from NTRT

## SAVE

used only with TYPE=SNAP. Defaults to yes if omitted.
If YES all GPRs and all ARs will be stored in the DBG
dynamic area before DBG is invoked. Upon return, all 32
registers will be restored.

## Macro code

The [DBG macro](../bxamac/DBG.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.