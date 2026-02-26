# EXSVC macro

Execute an SVC-instruction with variable length

## Syntax

```hlasm
&LABEL   EXSVC &SVC                    * Register holding SVC number to use
```

## SVC

specifies the SVC number to be used. In stead of a SVC-number 
a register containing the SVC-number must be specified.

## Macro code

The [EXSVC macro](../bxamac/EXSVC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.