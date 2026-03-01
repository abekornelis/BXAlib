# SYSPARM macro

The assembler program accepts as a JCL-parameter a specification
for the variable SYSPARM. The value entered in the JCL will be
passed to a global set symbol named `&SYSPARM`. The value specified
in the JCL is passed as a single string. This macro decomposes the
string into separate parameters. Then the parameters are checked
and handled. 7 different keywords are allowed:
- `DBG`     : Generate debugging code (DBG-macro expansion)
- `NODBG`   : Do not generate debugging code
- `NOSRLIST`: Do not generate a list of subroutines
- `SRLIST`  : Generate a list of subroutines
- `SRXREF`  : Generate a cross reference of subroutines
- `SHOWALL` : Do not suppress any statement, report EJECT statements
- `OPT`     : Optimize generated code
- `NOOPT`   : Do not optimize generated code
- `LICENSE=`...... Name and version of the license for this software
- `LICSTAT=IAGREE` If you agree to the license terms

The default is: `NODBG,SRXREF,NOOPT,LICENSE(NONE),LICSTAT(NOTOK)`
If conflicting options are entered, the last one specified will
take precedence.

## Syntax

``` hlasm
         SYSPARM ,
```

## Macro code

The [SYSPARM macro](../bxamac/SYSPARM.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.