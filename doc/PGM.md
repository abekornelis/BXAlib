# PGM macro

This macro generates entry logic for a CSECT and sets up the
Bixoft eXtended Assembly environment

## Syntax

``` hlasm
&LABEL   PGM   &VERSION=,              * Version id: VnnRnnMnn         *
               &AMODE=31,              * Amode default=31              *
               &RMODE=ANY,             * Rmode default=ANY             *
               &ENTRY=MAIN,            * MAIN/SUBR/SUBPGM/SVC          *
               &SAVES=,                * Nr of internal saveareas      *
               &MAPS=,                 * Mapping macro's to include    *
               &LIST=NO,               * List maps (YES/NO)            *
               &WORKPTR=,              * Pointer to dyn.area           *
               &WORKAREA=,             * Descriptor of dyn.area        *
               &HDRTXT='No description', * Description for list-headers*
               &DBG=,                  * Name of ptrs for debugging    *
               &ABND=                  * Info for Abend service rout.
```


## LABEL

CSECT name to be used. Defaults to member name.

## VERSION

must be in the format VnnRnnMnn

## AMODE

must be 24 or 31

## RMODE

must be 24, 31, or ANY

## ENTRY

Type of program (see below) or (Type,ASC-mode)
- ASC-mode defaults to `PRIM`, but may be specified as `AR` as well.

The following types of program are defined:
- `MAIN`:
  Generates linkage using a stack-entry (BAKR). Intended for main programs
- `SUBPGM`:
  Generates normal linkage using savearea at R13. Intended for sub-programs
- `SUBR`:
  Generates normal linkage using internal savearea. Intended for CSECTS that share their R13 with their caller.
- `SVC`:
  Generates linkage appropriate for SVC-entry. Intended for SVCs and SVC-screening routines
- `SPCR:
  Generates linkage appropriate for stacking PC-routines. Assumes routine is entered in supervisor mode.
- `SRB`:
  Generates linkage appropriate for SRB-entry.
  Sets up FRR parmlist with ptr to SRB and passes
  the SRB parmlist ptr in R1 to the mainline.
- `FRR`:
  Generates linkage appropriate for FRR routines.
- `RMTR`:
  Generates linkage appropriate for RMTR routines.
  Passes the SRB address in R1 to the mainline.
- `RESMGR`:
  Generates linkage appropriate for a resource
  manager routine. Sets up MAIN linkage and
  establishes addressability to the RMPL.

## SAVES

The number of internal save-areas to allocate

## MAPS

Mapping macros to be generated, must be a sublist

## LIST

- `NO`: no listings are generated from the MAPS parameter
- `YES`: listings are generated from the MAPS parameter

## WORKPTR

Either one or three sub-operands.

When omitted, no pointer is assumed to exist and a
workarea will be allocated, as specified in &WORKAREA.

If specified as three operands, they must be specified as follows:
- The label of the pointer field
- The label of a using-location
- The register that contains the address of the using loc.

If there is only 1 sub-operand, must be a (register),
unless ENTRY=`SUBR`, in which case the sub-operand may
specify a field in the workarea, passed thru R13.

## WORKAREA

DSECT name or sublist with two to four sub-operands:
- DSECT name for using with R13. This DSECT must start
  with a DCL BXASAVE. It also must contain an
  equate for DSECTname_LEN. The DSECT must be specified on
  the MAPS-parameter of the macro invocation.
- Length of the work-area to be allocated
  This parameter may be omitted for ENTRY=SUBR
- An optional 8-character id for the first 8 positions of
  the work-area. Defaults to &LABEL.
- An optional fieldname in the workarea, which is to
  contain the total amount of storage allocated for
  the workarea plus internal saveareas.

Work-area requirements: See [MAPSAVE macro](MAPSAVE.md)
- at offset  0: a doubleword reserved for an area ID
- at offset  8: a standard MVS save-area of 18 fullwords
- at offset 80: two pointers to internal save-areas, see [MAPSAVE macro](MAPSAVE.md)

## HDRTXT

Header text for use on the listing's header lines

## DBG

Valid only with ENTRY=SUBR. Names of 2 fields with:
- pointer to debug module
- plist for debug module

## ABND

One or two sub-operands
- User abend code to use for this program
- Label to use for the abend service routine (default: `_ABND`)

## Macro code

The [PGM macro](../bxamac/PGM.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.