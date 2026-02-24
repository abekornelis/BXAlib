# Macro index

The macros in this maclib are divided into the
following categories:
- [Structrured programming](#Structured-programming)
- [Register management](#Register-management)
- [Data defintions and overrides](#Data-defintions-and-overrides)
- [Extended branching](#Extended-branching)
- [Other instruction set extensions](#Other-instruction-set-extensions)
- [Various](#Various)
- [Mappings and overrides](#Mappings-and-overrides)

## Structured programming

| Macro    | Function                                                 |
|----------|----------------------------------------------------------|
| BEGSR    | BEGin SubRoutine (start of subroutine definition)        |
| CASE     | Multi-branch if statement                                |
| DO       | Start of a loop                                          |
| ELSE     | ELSE for an IF-THEN-ELSE-ENDIF construct                 |
| END      | END of program, generates subroutine cross reference     |
| ENDCASE  | End of a case construct                                  |
| ENDDO    | End of a DO loop                                         |
| ENDIF    | End of an IF-THEN-ELSE-EDIF construct                    |
| ENDSR    | End of a subroutine definition                           |
| EXSR     | EXecute SubRoutine (subroutine invocation)               |
| EXSR0    | (helper macro for EXSR)                                  |
| GLUE     | Call module in a different Amode/Rmode                   |
| GOTO     | Branch with IF-like condition coded as parameters        |
| IF$      | (helper macro for IF/CASE/DO)                            |
| IF$ALC   | (helper macro for IF/CASE/DO)                            |
| IF$LS    | (helper macro for IF/CASE/DO)                            |
| IF$LU    | (helper macro for IF/CASE/DO)                            |
| IF       | Start of IF-THEN-ELSE-ENDIF construct                    |
| LEAVE    | Exit from IF/CASE/LOOP construct                         |
| LOOP     | Repeat DO-ENDDO loop                                     |
| PGM      | ProGraM start                                            |
| PGM0     | (helper macro with PGM)                                  |
| RETRN    | RETuRN from subroutine                                   |

## Register management

| Macro    | Function                                                 |
|----------|----------------------------------------------------------|
| DROP     | Replaces DROP statement                                  |
| DROP0    | (helper macro with DROP)                                 |
| EQUREG   | Allocate available register using EQU                    |
| USE      | Declare register usage                                   |
| USEDREGS | Show overview of registers in use                        |
| USING    | Replaces USING statement                                 |

## Data defintions and overrides

| Macro    | Function                                                 |
|----------|----------------------------------------------------------|
| DC       | Replaces DC statement                                    |
| DCL      | DeCLare a field, bit, or register                        |
| DCOVR    | Define an OVerRide for a later DC statement              |
| CPY      | CoPY a field, register, etc. intelligently               |
| DEC      | DECrement field or register                              |
| DS       | Replaces DS statement                                    |
| DSOVR    | Define an OVerRide for a later DS statement              |
| EQU      | Replaces EQU statement                                   |
| EQUOVR   | Define an OVerRide for a later EQU statement             |
| EXTRN    | Replaces EXTRN statement                                 |
| EXTRNOVR | Define an OVerRide for a later EXTRN statement           |
| GEN      | Generate a replaced machine instruction                  |
| GENMAPS  | GENerate MAP definitionS                                 |
| INC      | INCrement a field or register                            |
| LABEL    | Define a Label                                           |
| LTORG    | Replaces LTORG statement                                 |
| NESTCB   | Define a NESTed Control Block                            |
| RDATA    | Remote DATA definition                                   |
| RLTORG   | Remote LTORG                                             |
| RWTO     | Remote WTO                                               |
| SET      | Set a coded-value field to a specific value              |
| SETOF    | Turn off a named bit                                     |
| SETON    | Turn on a named bit                                      |
| TRTAB    | Define TRT table data                                    |

## Extended branching

| Macro    | Function                                                 |
|----------|----------------------------------------------------------|
| BALC     | BAL Conditionally                                        |
| BALE     | BAL on Equal                                             |
| BALH     | BAL on High                                              |
| BALL     | BAL on Low                                               |
| BALM     | BAL on Mixed/Minus                                       |
| BALNE    | BAL on Not Equal                                         |
| BALNH    | BAL on Not High                                          |
| BALNL    | BAL on Not Low                                           |
| BALNM    | BAL on Not Mixed/Minus                                   |
| BALNO    | BAL on Not Ones/Overflow                                 |
| BALNP    | BAL on Not Plus                                          |
| BALNZ    | BAL on Not Zero                                          |
| BALO     | BAL on Ones/Overflow                                     |
| BALP     | BAL on Plus                                              |
| BALZ     | BAL on Zero                                              |
| BASC     | BAS Conditionally                                        |
| BASE     | BAS on Equal                                             |
| BASH     | BAS on High                                              |
| BASL     | BAS on Low                                               |
| BASM     | BAS on Mixed/Minus                                       |
| BASNE    | BAS on Not Equal                                         |
| BASNH    | BAS on Not High                                          |
| BASNL    | BAS on Not Low                                           |
| BASNM    | BAS on Not Mixed/Minus                                   |
| BASNO    | BAS on Not Ones/Overflow                                 |
| BASNP    | BAS on Not Plus                                          |
| BASNZ    | BAS on Not Zero                                          |
| BASO     | BAS on Ones/Overflow                                     |
| BASP     | BAS on Plus                                              |
| BASZ     | BAS on Zero                                              |
| BHE      | Branch on High or Equal                                  |
| BHER     | Branch on High or Equal Register                         |
| BLE      | Branch on Low or Equal                                   |
| BLER     | Branch on Low or Equal Register                          |
| BLH      | Branch on Low or High                                    |
| BLHR     | Branch on Low or High Register                           |
| BNHE     | Branch on Not High or Equal                              |
| BNHER    | Branch on Not High or Equal Register                     |
| BNLE     | Branch on Not Low or Equal                               |
| BNLER    | Branch on Not Low or Equal Register                      |
| BNLH     | Branch on Not Low or High                                |
| BNLHR    | Branch on Not Low or High Register                       |

## Other instruction set extensions

| Macro    | Function                                                                  |
|----------|---------------------------------------------------------------------------|
| EPSW     | Extract PSW (for machines not having the instruction)                     |
| EXCLC    | EXecute CLC                                                               |
| EXMVC    | EXecute MVC                                                               |
| EXQ      | EXeQute instruction                                                       |
| EXSVC    | EXecute SVC                                                               |
| EXTR     | EXecute TR                                                                |
| EXTRT    | EXecute TRT                                                               |
| EXXC     | EXecute XC                                                                |
| IPK      | Replaces IPK instruction                                                  |
| LA       | Replaces LA instruction                                                   |
| LC       | Load Character (for machines not having the instruction)                  |
| LR       | Replaces LR instruction                                                   |
| LT       | Load and Test (for machines not having the instruction)                   |
| LTA24    | Load and Test 24-bit address                                              |
| LTC      | Load and Test Character (for machines not having the instruction)         |
| LTH      | Load and Test Halfword (for machines not having the instruction)          |
| LTHU     | Load and Test Halfword Unsigned (for machines not having the instruction) |
| MVPL     | MoVe ParmList                                                             |
| STA24    | STore 24-bit address                                                      |
| TRT      | Replaces TRT instruction                                                  |

## Various

| Macro    | Function                                                   |
|----------|------------------------------------------------------------|
| ABND     | Branch to routine that issues abend (ABNDPGM)              |
| ABNDPGM  | Generates an out-of-line routine that abends the program   |
| BXAEPSW  | Extract PSW                                                |
| CHKLIC   | Check license (assembly-time)                              |
| CHKLIT   | Check whether argument is a valid numeric literal          |
| CHKMAP   | Check parameters entered on a MAPxxx macro                 |
| CHKNUM   | Check whether argument is a valid number                   |
| CHKREG   | Check whether argument is a valid register                 |
| CLEAR    | Clear an area of storage or a register                     |
| CMDTXT   | Define a command-text for use with MGCRE                   |
| DBG      | Debugging logic                                            |
| DISSECT  | Dissect a parameter into its constituent parts             |
| EJECT    | Replaces EJECT statement                                   |
| EJECTOVR | Manage overrides for EJECT                                 |
| NTCR     | Create a name/token pair                                   |
| NTDL     | Delete a name/token pair                                   |
| NTRT     | Retrieve a name/token pair                                 |
| OPSYNS   | Generate OPSYN statements for a list of instructions       |
| POP      | Replaces POP statement                                     |
| PUSH     | Replaces PUSH statement                                    |
| SETMODE  | Call SETMODE function                                      |
| SETMODE0 | Define internal subroutine for SETMODE                     |
| SNAPHDR  | Define header-text for use with STRHDR operand of SNAP     |
| SNAPNTRY | Define entries in the STORAGE and STRHDR lists of SNAP     |
|          | --> SNAPNTRY is intended for use with BXADBG00 only        |
| SPACE    | Replaces SPACE statement                                   |
| SPLIT    | Split a parameter string in its constituent parts          |
| SYSPARM  | Analyze SYSPARM content                                    |

## Mappings and overrides

For mappings and overrides, please see [list of mapping macros]($DOC.md#Control-blocks-available-for-DCL).