# NTCR macro

Create a name/token pair

## Syntax

``` hlasm
&LABEL   NTCR  &PAR1,                  * Parameter 1                   *
               &PAR2,                  * Parameter 2                   *
               &PAR3,                  * Parameter 3                   *
               &PAR4,                  * Parameter 4                   *
               &PAR5,                  * Parameter 5                   *
               &LVL=,                  * Value for level parameter     *
               &NAME=,                 * Value for token name          *
               &TOKEN=,                * Value for token value         *
               &PERSIST=,              * Value for persist option      *
               &MF=                    * MF=L or MF=(E,list_addr)      *
                                       *      or MF=(G,list_addr)
```

## PAR1

(reg) or name of a fullword, containing the level
if omitted LVL= must be specified.

## PAR2

(reg) or name of a 16-byte area, containing the token name
if omitted NAME= must be specified.

## PAR3

(reg) or name of a 16-byte area, containing the token value
if omitted TOKEN= must be specified.

## PAR4

(reg) or name of a fullword, containing the persist option
if omitted PERSIST= must be specified.

## PAR5

(reg) or name of a fullword, where the returncode will go
must not be omitted.

## LVL

Literal, constant, or (reg). If specified, will be moved
into the level parameter fullword.

## NAME

Literal, constant, or (reg). If specified, will be moved
into the token name parameter 16-byte area.

## TOKEN

Literal, constant, or (reg). If specified, will be moved
into the token value parameter 16-byte area.

## PERSIST

Literal, constant, or (reg). If specified, will be moved
into the persistence option parameter fullword.

## MF

- L or (L) for the list-form
- (E,list_addr) for the execute form
- (G,list_addr) for the generate form

## Macro code

The [NTCR macro](../bxamac/NTCR.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.