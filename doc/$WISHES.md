# Wish list for asmplus maclib

- Change type 'g' for GPR to 'r' for Register (Right half)
- Add type 'l' for Register (Left half)
- Add type 'g' for Register (Grande)
- Add support for vector registers
- Support for SHOWALL option should be removed from all macros and inserted into SPACE/EJECT/TITLE etc.
- CLEAR - Allow other types of operands
- DEC   - Allow other types of operands
- EPSW  - Not (yet) compatible with EPSW instruction
  - rename BXAEPSW to EPSW and allow 2nd operand!
  - remove the BXAEPSW macro (temporary solution)
- EQU   - Generate instruction labels as follows:
``` hlasm
         DS    0H
&LABEL   EQU   *,2,C'I'
```

- INC     - Allow other types of operands
- MAPREGS - Change type 'g' to type 'r'
  - All other macros must change accordingly
  - See EQU macro for other registertypes to add
- MAPREGS  - Add equates for 64-bit registers type 'g'
- MAPxxxxx - Make overrides dependent upon current OS level
- MAPxxxxx - Some mapping macros still have a different structure
- RDATA    - use locator name in stead of RLTORG macro
- RLTORG   - discard after changing RDATA to use locator name
