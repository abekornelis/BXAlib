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

| Macro             | Function                                                 |
|-------------------|----------------------------------------------------------|
| [BEGSR](BEGSR.md) | BEGin SubRoutine (start of subroutine definition)        |
| CASE              | Multi-branch if statement                                |
| DO                | Start of a loop                                          |
| ELSE              | ELSE for an IF-THEN-ELSE-ENDIF construct                 |
| END               | END of program, generates subroutine cross reference     |
| ENDCASE           | End of a case construct                                  |
| ENDDO             | End of a DO loop                                         |
| ENDIF             | End of an IF-THEN-ELSE-EDIF construct                    |
| ENDSR             | End of a subroutine definition                           |
| EXSR              | EXecute SubRoutine (subroutine invocation)               |
| EXSR0             | (helper macro for EXSR)                                  |
| GLUE              | Call module in a different Amode/Rmode                   |
| GOTO              | Branch with IF-like condition coded as parameters        |
| IF$               | (helper macro for IF/CASE/DO)                            |
| IF$ALC            | (helper macro for IF/CASE/DO)                            |
| IF$LS             | (helper macro for IF/CASE/DO)                            |
| IF$LU             | (helper macro for IF/CASE/DO)                            |
| IF                | Start of IF-THEN-ELSE-ENDIF construct                    |
| LEAVE             | Exit from IF/CASE/LOOP construct                         |
| LOOP              | Repeat DO-ENDDO loop                                     |
| PGM               | ProGraM start                                            |
| PGM0              | (helper macro with PGM)                                  |
| RETRN             | RETuRN from subroutine                                   |

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

| Macro             | Function                                                 |
|-------------------|----------------------------------------------------------|
| [BALC](BALC.md)   | BAL Conditionally                                        |
| [BALE](BALE.md)   | BAL on Equal                                             |
| [BALH](BALH.md)   | BAL on High                                              |
| [BALL](BALL.md)   | BAL on Low                                               |
| [BALM](BALM.md)   | BAL on Mixed/Minus                                       |
| [BALNE](BALNE.md) | BAL on Not Equal                                         |
| [BALNH](BALNH.md) | BAL on Not High                                          |
| [BALNL](BALNL.md) | BAL on Not Low                                           |
| [BALNM](BALNM.md) | BAL on Not Mixed/Minus                                   |
| [BALNO](BALNO.md) | BAL on Not Ones/Overflow                                 |
| [BALNP](BALNP.md) | BAL on Not Plus                                          |
| [BALNZ](BALNZ.md) | BAL on Not Zero                                          |
| [BALO](BALO.md)   | BAL on Ones/Overflow                                     |
| [BALP](BALP.md)   | BAL on Plus                                              |
| [BALZ](BALZ.md)   | BAL on Zero                                              |
| [BASC](BASC.md)   | BAS Conditionally                                        |
| [BASE](BASE.md)   | BAS on Equal                                             |
| [BASH](BASH.md)   | BAS on High                                              |
| [BASL](BASL.md)   | BAS on Low                                               |
| [BASM](BASM.md)   | BAS on Mixed/Minus                                       |
| [BASNE](BASNE.md) | BAS on Not Equal                                         |
| [BASNH](BASNH.md) | BAS on Not High                                          |
| [BASNL](BASNL.md) | BAS on Not Low                                           |
| [BASNM](BASNM.md) | BAS on Not Mixed/Minus                                   |
| [BASNO](BASNO.md) | BAS on Not Ones/Overflow                                 |
| [BASNP](BASNP.md) | BAS on Not Plus                                          |
| [BASNZ](BASNZ.md) | BAS on Not Zero                                          |
| [BASO](BASO.md)   | BAS on Ones/Overflow                                     |
| [BASP](BASP.md)   | BAS on Plus                                              |
| [BASZ](BASZ.md)   | BAS on Zero                                              |
| [BHE](BHE.md)     | Branch on High or Equal                                  |
| [BHER](BHER.md)   | Branch on High or Equal Register                         |
| [BLE](BLE.md)     | Branch on Low or Equal                                   |
| [BLER](BLER.md)   | Branch on Low or Equal Register                          |
| [BLH](BLH.md)     | Branch on Low or High                                    |
| [BLHR](BLHR.md)   | Branch on Low or High Register                           |
| [BNHE](BNHE.md)   | Branch on Not High or Equal                              |
| [BNHER](BNHER.md) | Branch on Not High or Equal Register                     |
| [BNLE](BNLE.md)   | Branch on Not Low or Equal                               |
| [BNLER](BNLER.md) | Branch on Not Low or Equal Register                      |
| [BNLH](BNLH.md)   | Branch on Not Low or High                                |
| [BNLHR](BNLHR.md) | Branch on Not Low or High Register                       |

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

| Macro                 | Function                                                   |
|-----------------------|------------------------------------------------------------|
| [ABND](ABND.md)       | Branch to routine that issues abend (ABNDPGM)              |
| [ABNDPGM](ABNDPGM.md) | Generates an out-of-line routine that abends the program   |
| [BXAEPSW](BXAEPSW.md) | Extract PSW                                                |
| CHKLIC                | Check license (assembly-time)                              |
| CHKLIT                | Check whether argument is a valid numeric literal          |
| CHKMAP                | Check parameters entered on a MAPxxx macro                 |
| CHKNUM                | Check whether argument is a valid number                   |
| CHKREG                | Check whether argument is a valid register                 |
| CLEAR                 | Clear an area of storage or a register                     |
| CMDTXT                | Define a command-text for use with MGCRE                   |
| DBG                   | Debugging logic                                            |
| DISSECT               | Dissect a parameter into its constituent parts             |
| EJECT                 | Replaces EJECT statement                                   |
| EJECTOVR              | Manage overrides for EJECT                                 |
| NTCR                  | Create a name/token pair                                   |
| NTDL                  | Delete a name/token pair                                   |
| NTRT                  | Retrieve a name/token pair                                 |
| OPSYNS                | Generate OPSYN statements for a list of instructions       |
| POP                   | Replaces POP statement                                     |
| PUSH                  | Replaces PUSH statement                                    |
| SETMODE               | Call SETMODE function                                      |
| SETMODE0              | Define internal subroutine for SETMODE                     |
| SNAPHDR               | Define header-text for use with STRHDR operand of SNAP     |
| SNAPNTRY              | Define entries in the STORAGE and STRHDR lists of SNAP     |
|                       | --> SNAPNTRY is intended for use with BXADBG00 only        |
| SPACE                 | Replaces SPACE statement                                   |
| SPLIT                 | Split a parameter string in its constituent parts          |
| SYSPARM               | Analyze SYSPARM content                                    |

## Mappings and overrides

For mappings and overrides, please see [list of mapping macros]($DOC.md#Control-blocks-available-for-DCL).