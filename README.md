Bixoft eXtended Assembly language consists of a set of macros that make coding, reading, and maintaining assembler programs easier.
Some of its features:
- Strong typing for enhanced early error detection
- Enhanced USE/DROP to mark register usage
- Dynamic register allocation during assembly
- Inheritance of data attributes
- Bit hanlding by bit name - location implied
- Structured Programming macros:
  - IF/ELSE/ENDIF
  - CASE/ELSE/ENDCASE
  - DO UNTIL/ DO WHILE/DO n/DO/LEAVE/ENDDO
  - BEGSR/ENDSR/EXSR (begin/end/execute subroutine)
  - PGM (generates entry linkage code, mappings, SYSPARM analysis, etc.)
- Pre-linked save areas for subroutine calls
- Subroutine call tree generated at end of program
- Large number of mappings with overrides to correct field types for IBM-defined control blocks

*Usage Note:*
To use any of these macros, use PGM and pass a SYSPARM containing
`LICENSE=GPL2.0,LICSTAT=IAGREE` or in some other way set the following
`GBLC` variables:
``` hlasm
         GBLC  &SP_LICENSE             * License name / version
         GBLC  &SP_LICSTAT             * License status
&SP_LICENSE SETC 'GPL2.0'              * License name / version
&SP_LICSTAT SETC 'IAGREE'              * License status
```

*The tests for license acceptance are considered part of the Copyright Notice
and therefore may not be changed or disabled in any way.*

Documentation:
- [Getting started](doc/$README.md)
- [Documentation overview](doc/$DOC.md)
- [Macro index by category](doc/$INDEX.md)
