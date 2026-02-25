# CHKLIC macro

The assembler program accepts as a JCL-parameter a specification
for the variable SYSPARM. The value entered in the JCL will be
passed to a global set symbol named &SYSPARM. The value specified
in the JCL is decomposed by the SYSPARM macro, which translates the
specified values into settings for global SETx variables.

This macro checks the validity and acceptance (by the user)
of the license for the BXA macro library

## Important Notice

The code in this macro checks whether 'USER' accepted the terms and conditions
of the license for the BXA macro library. This code is to be treated
as part of the Copyright Notice and therefore may not be changed
or disabled in any way.

## Syntax

``` hlasm
         CHKLIC &MACRO                                                  
```

## Macro code

The [CHKLIC macro](../bxamac/CHKLIC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.