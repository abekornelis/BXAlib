# Macro index

The macros in this maclib are divided into the
following categories:
- [Structrured programming](#Structured-programming)
- [Register management](#Register-management)
- [Data defintions and overrides](#Data-defintions-and-overrides)
- [Smart data manipulation](#Smart-data-manipulation)
- [Extended branching](#Extended-branching)
- [Other instruction set extensions](#Other-instruction-set-extensions)
- [Various](#Various)
- [Mappings and overrides](#Mappings-and-overrides)

## Structured programming

| Macro                               | Function                                                 |
|-------------------------------------|----------------------------------------------------------|
| [BEGSR](BEGSR.md)                   | BEGin SubRoutine (start of subroutine definition)        |
| [CASE](CASE.md)                     | Multi-branch if statement                                |
| [DO](DO.md)                         | Start of a loop                                          |
| [ELSE](ELSE.md)                     | ELSE for an IF-THEN-ELSE-ENDIF construct                 |
| [END](END.md)                       | END of program, generates subroutine cross reference     |
| [ENDCASE](ENDCASE.md)               | End of a case construct                                  |
| [ENDDO](ENDDO.md)                   | End of a DO loop                                         |
| [ENDIF](ENDIF.md)                   | End of an IF-THEN-ELSE-EDIF construct                    |
| [ENDSR](ENDSR.md)                   | End of a subroutine definition                           |
| [EXSR](EXSR.md)                     | EXecute SubRoutine (subroutine invocation)               |
| [EXSR0](EXSR0.md)                   | (helper macro for EXSR)                                  |
| [EXSR_ADD_ENTRY](EXSR_ADD_ENTRY.md) | (helper macro for EXSR)                                  |
| [GLUE](GLUE.md)                     | Call module in a different Amode/Rmode                   |
| [GOTO](GOTO.md)                     | Branch with IF-like condition coded as parameters        |
| [IF$](IF$ALC.md)                    | (helper macro for IF/CASE/DO)                            |
| [IF$ALC](IF$ALC.md)                 | (helper macro for IF/CASE/DO)                            |
| [IF$LS](IF$LS.md)                   | (helper macro for IF/CASE/DO)                            |
| [IF$LU](IF$LU.md)                   | (helper macro for IF/CASE/DO)                            |
| [IF](IF.md)                         | Start of IF-THEN-ELSE-ENDIF construct                    |
| [LEAVE](LEAVE.md)                   | Exit from IF/CASE/LOOP construct                         |
| [LOOP](LOOP.md)                     | Repeat DO-ENDDO loop                                     |
| PGM                                 | ProGraM start                                            |
| PGM0                                | (helper macro with PGM)                                  |
| RETRN                               | RETuRN from subroutine                                   |

## Register management

| Macro                   | Function                                                 |
|-------------------------|----------------------------------------------------------|
| [DROP](DROP.md)         | Replaces DROP statement                                  |
| [DROP0](DROP0.md)       | (helper macro with DROP)                                 |
| [DROP_REG](DROP_REG.md) | (helper macro with DROP)                                 |
| [EQUREG](EQUREG.md)     | Allocate available register using EQU                    |
| USE                     | Declare register usage                                   |
| USEDREGS                | Show overview of registers in use                        |
| USING                   | Replaces USING statement                                 |

## Data definitions and overrides

| Macro                   | Function                                                 |
|-------------------------|----------------------------------------------------------|
| [DC](DC.md)             | Replaces DC statement                                    |
| [DCL](DCL.md)           | DeCLare a field, bit, or register                        |
| [DCOVR](DCOVR.md)       | Define an OVerRide for a later DC statement              |
| [DS](DS.md)             | Replaces DS statement                                    |
| [DSOVR](DSOVR.md)       | Define an OVerRide for a later DS statement              |
| [EQU](EQU.md)           | Replaces EQU statement                                   |
| [EQUOVR](EQUOVR.md)     | Define an OVerRide for a later EQU statement             |
| [EXTRN](EXTRN.md)       | Replaces EXTRN statement                                 |
| [EXTRNOVR](EXTRNOVR.md) | Define an OVerRide for a later EXTRN statement           |
| [GEN](GEN.md)           | Generate a replaced machine instruction                  |
| [GENMAPS](GENMAPS.md)   | GENerate MAP definitionS                                 |
| [LABEL](LABEL.md)       | Define a Label                                           |
| [LTORG](LTORG.md)       | Replaces LTORG statement                                 |
| NESTCB                  | Define a NESTed Control Block                            |
| RDATA                   | Remote DATA definition                                   |
| RLTORG                  | Remote LTORG                                             |
| RWTO                    | Remote WTO                                               |
| TRTAB                   | Define TRT table data                                    |

## Smart data manipulation

| Macro         | Function                                                 |
|---------------|----------------------------------------------------------|
| [CPY](CPY.md) | CoPY a field, register, etc. intelligently               |
| [DEC](DEC.md) | DECrement a register                                     |
| [INC](INC.md) | INCrement a register                                     |
| SET           | Set a coded-value field to a specific value              |
| SETOF         | Turn off a named bit                                     |
| SETON         | Turn on a named bit                                      |

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

| Macro             | Function                                                                  |
|-------------------|---------------------------------------------------------------------------|
| [EPSW](EPSW.md)   | Extract PSW (for machines not having the instruction)                     |
| [EXCLC](EXCLC.md) | EXecute CLC                                                               |
| [EXMVC](EXMVC.md) | EXecute MVC                                                               |
| [EXQ](EXQ.md)     | EXeQute instruction                                                       |
| [EXSVC](EXSVC.md) | EXecute SVC                                                               |
| [EXTR](EXTR.md)   | EXecute TR                                                                |
| [EXTRT](EXTRT.md) | EXecute TRT                                                               |
| [EXXC](EXXC.md)   | EXecute XC                                                                |
| [IPK](IPK.md)     | Replaces IPK instruction                                                  |
| [LA](LA.md)       | Replaces LA instruction                                                   |
| [LC](LC.md)       | Load Character (for machines not having the instruction)                  |
| [LR](LR.md)       | Replaces LR instruction                                                   |
| [LT](LT.md)       | Load and Test (for machines not having the instruction)                   |
| [LTA24](LTA24.md) | Load and Test 24-bit address                                              |
| [LTC](LTC.md)     | Load and Test Character (for machines not having the instruction)         |
| [LTH](LTH.md)     | Load and Test Halfword (for machines not having the instruction)          |
| [LTHU](LTHU.md)   | Load and Test Halfword Unsigned (for machines not having the instruction) |
| MVPL              | MoVe ParmList                                                             |
| STA24             | STore 24-bit address                                                      |
| TRT               | Replaces TRT instruction                                                  |

## Various

| Macro                   | Function                                                   |
|-------------------------|------------------------------------------------------------|
| [ABND](ABND.md)         | Branch to routine that issues abend (ABNDPGM)              |
| [ABNDPGM](ABNDPGM.md)   | Generates an out-of-line routine that abends the program   |
| [BXAEPSW](BXAEPSW.md)   | Extract PSW                                                |
| [CHKLIC](CHKLIC.md)     | Check license (assembly-time)                              |
| [CHKLIT](CHKLIT.md)     | Check whether argument is a valid numeric literal          |
| [CHKMAP](CHKMAP.md)     | Check parameters entered on a MAPxxx macro                 |
| [CHKNUM](CHKNUM.md)     | Check whether argument is a valid number                   |
| [CHKREG](CHKREG.md)     | Check whether argument is a valid register                 |
| [CLEAR](CLEAR.md)       | Clear an area of storage or a register                     |
| [CMDTXT](CMDTXT.md)     | Define a command-text for use with MGCRE                   |
| [DBG](DBG.md)           | Debugging logic                                            |
| [DISSECT](DISSECT.md)   | Dissect a parameter into its constituent parts             |
| [EJECT](EJECT.md)       | Replaces EJECT statement                                   |
| [EJECTOVR](EJECTOVR.md) | Manage overrides for EJECT                                 |
| NTCR                    | Create a name/token pair                                   |
| NTDL                    | Delete a name/token pair                                   |
| NTRT                    | Retrieve a name/token pair                                 |
| OPSYNS                  | Generate OPSYN statements for a list of instructions       |
| POP                     | Replaces POP statement                                     |
| PUSH                    | Replaces PUSH statement                                    |
| SETMODE                 | Call SETMODE function                                      |
| SETMODE0                | Define internal subroutine for SETMODE                     |
| SNAPHDR                 | Define header-text for use with STRHDR operand of SNAP     |
| SNAPNTRY                | Define entries in the STORAGE and STRHDR lists of SNAP     |
|                         | --> SNAPNTRY is intended for use with BXADBG00 only        |
| SPACE                   | Replaces SPACE statement                                   |
| SPLIT                   | Split a parameter string in its constituent parts          |
| SYSPARM                 | Analyze SYSPARM content                                    |

## Mappings and overrides

| Macro                   | Function                                                   |
|-------------------------|------------------------------------------------------------|
| [MAPABEP](MAPABEP.md)   | Map ABEP - ABdump Exit Parameter list
| [MAPACB](MAPACB.md)     | Map ACB - Access Control Block
| [MAPACEE](MAPACEE.md)   | Map ACEE - ACcessor Environment Element
| [MAPADSR](MAPADSR.md)   | Map ADSR c.a. - Symptom Record
| [MAPADYEN](MAPADYEN.md) | Map ADYENF - DAE Event NotiFication parameter list
| [MAPAE](MAPAE.md)       | Map AE - VSM Allocated Element
| [MAPASCB](MAPASCB.md)   | Map ASCB - Address Space Control Block
| [MAPASEO](MAPASEO.md)   | Map ASEO - Address Space crEation Output area
| [MAPASMVT](MAPASMVT.md) | Map ASMPools - ASM cell POOL controller and ASMVT - ASM Vector Table
| [MAPASSB](MAPASSB.md)   | Map ASSN - Address Space Secondary Block
| [MAPASVT](MAPASVT.md)   | Map ASVT - Address Space Vector Table
| [MAPASXB](MAPASXB.md)   | Map ASXB - Address Space eXtension Block
| [MAPBASEA](MAPBASEA.md) | Map BASEA, BASEX - Master Scheduler Resident Data Area and eXtension
| [MAPBITS](MAPBITS.md)   | Bit equates
| [MAPCAM](MAPCAM.md)     | Map CAMLST, CAMLOC, CAMLOCVOL - interface areas for CAMLST NAME
| [MAPCDE](MAPCDE.md)     | Map CDE - Contents Directory Entry
| [MAPCIB](MAPCIB.md)     | Map CIBHDR and CIBX - Command Input Buffer HeaDeR and eXtension
| [MAPCOM](MAPCOM.md)     | Map COM - COMmunication area
| [MAPCQE](MAPCQE.md)     | Map CQE - Console Queue Element
| [MAPCSCB](MAPCSCB.md)   | Map CSCB and CSCX - Command Scheduling Control Block and eXtension
| [MAPCVT](MAPCVT.md)     | Map CVT c.a. - Communications Vector Table
| [MAPDCB](MAPDCB.md)     | Map DCB, RDW, BDW, SDW, SCW - Data Control Block, Record/Block/Segment descriptors
| [MAPDCBE](MAPDCBE.md)   | Map DCBE - Data Control Block Extension
| [MAPDDRCO](MAPDDRCO.md) | Map DDRCOM - IOS Dynamic Device Reconfiguration COMmunication area
| [MAPDEB](MAPDEB.md)     | Map DEB c.a. - Data Extent Block and extensions
| [MAPDECB](MAPDECB.md)   | Map DECB - Data Event Control Block
| [MAPDES](MAPDES.md)     | Map DES c.a. - DirEntry Services areas
| [MAPDFA](MAPDFA.md)     | Map DFA - Data Facilities Area
| [MAPDOTU](MAPDOTU.md)   | Map DOCNTFLD, DOCNTLST, DOCNUNIT - Dynamic Output areas
| [MAPDSAB](MAPDSAB.md)   | Map DSAB, DSABANMI - Data Set Association Block and Alternate NaMe Information block
| [MAPDSABQ](MAPDSABQ.md) | Map SABQDB - DSAB Queue Descriptor Block
| [MAPDSCB](MAPDSCB.md)   | Map DSCB1 through DSCB5
| [MAPDSCB1](MAPDSCB1.md) | Map DSCB1 - Data Set Control Block - format 1
| [MAPDSCB2](MAPDSCB2.md) | Map DSCB2 - Data Set Control Block - format 2
| [MAPDSCB3](MAPDSCB3.md) | Map DSCB3 - Data Set Control Block - format 3
| [MAPDSCB4](MAPDSCB4.md) | Map DSCB4 - Data Set Control Block - format 4
| [MAPDSCB5](MAPDSCB5.md) | Map DSCB5 - Data Set Control Block - format 5
| [MAPECB](MAPECB.md)     | Map ECB, ECBE - Event Control block and Extension
| [MAPECVT](MAPECVT.md)   | Map ECVT - Extended Communications Vector Table
| [MAPEPAL](MAPEPAL.md)   | Map EPAL, EPAX, SWAREQPL - SWAREQ External Parameter List c.a.
| [MAPEQU](MAPEQU.md)     | Equates of registers, bits, and masks
| [MAPEVNT](MAPEVNT.md)   | Map EVNT, EVNTENTRY - EVeNTs control block and EVeNTs table ENTRY
| [MAPFRRPL](MAPFRRPL.md) | Map FRRPL - Function Recovery Routine Parameter area
| [MAPFRRS](MAPFRRS.md)   | Map FRRS, FRRSENTR, FRRSXENT, FRRSXSTK - FRR stack c.a.
| [MAPGVT](MAPGVT.md)     | Map GVT - GRS Vector Table
| [MAPGVTX](MAPGVTX.md)   | Map GVTX - GRS Vector Table eXtension
| [MAPIEANT](MAPIEANT.md) | Map NTCRPL, NTDLPL, NTRTPL - Named Token CReate, DeLete, ReTrieve Parameter Lists
| [MAPIECEQ](MAPIECEQ.md) | Open/Close/EOV equates
| [MAPIHSA](MAPIHSA.md)   | Map IHSA - Interrupt Handler Save Area
| [MAPIOB](MAPIOB.md)     | Map IOB - Input/Output Block 
| [MAPIOQ](MAPIOQ.md)     | Map IOQ, IOQE - IOS Queue element and Extension
| [MAPIOSB](MAPIOSB.md)   | Map IOSB, IOSX - I/O Supervisor Block and eXtension
| [MAPJCT](MAPJCT.md)     | Map ACT, JCT - Accounting Control Table and Job Control Table
| [MAPJCTX](MAPJCTX.md)   | Map JCTX - Job Control Table eXtension
| [MAPJESCT](MAPJESCT.md) | Map JESCT, JESMNTBL, JESPEXT - JES Communication Table c.a.
| [MAPJFCB](MAPJFCB.md)   | Map JFCB - Job File Control Block
| [MAPJFCBE](MAPJFCBE.md) | Map JFCBE - Job File Control Block Extension for 3800
| [MAPJFCBX](MAPJFCBX.md) | Map JFCBX - Job File Control Block eXtension
| [MAPJSCB](MAPJSCB.md)   | Map JSCB - Job Step Control BLock
| [MAPLCT](MAPLCT.md)     | Map LCT - Linkage Control Table
| [MAPLDA](MAPLDA.md)     | Map LDA - VSM Local Data Area
| [MAPLLE](MAPLLE.md)     | Map LLE - Load List Element
| [MAPLMASM](MAPLMASM.md) | Map LxxxPL and define equates - Latch Management parmlists and constants
| [MAPLPDE](MAPLPDE.md)   | Map LPDE - Link Pack Directory Entry
| [MAPOCPL](MAPOCPL.md)   | Map OC24, OC31 - Open/Close Parameter Lists
| [MAPORE](MAPORE.md)     | Map ORE - Operator Reply Element
| [MAPOUCB](MAPOUCB.md)   | Map OUCB - ResOurces manager User Control Block
| [MAPPCCA](MAPPCCA.md)   | Map PCCA - Physical Configuration Communication Area
| [MAPPCCAV](MAPPCCAV.md) | Map PCCAVT - PCCA Vector Table
| [MAPPDAB](MAPPDAB.md)   | Map PDAB - Parallel Data Access Block
| [MAPPDS](MAPPDS.md)     | Map PDS, PDS2, TTRN, TTRX - Partitioned Data Set support
| [MAPPEL](MAPPEL.md)     | Map PEL - Parameter Element List (ENQ/DEQ/RESERVE)
| [MAPPMAR](MAPPMAR.md)   | Map PMAR, PMARA, PMARL, PMARR - Program Management Attribute Record c.a.
| [MAPPRB](MAPPRB.md)     | Map PRB - Program Request Block
| [MAPPRMLB](MAPPRMLB.md) | Map PRM_LIST_BUFFER, PRM_MESSAGE_BUFFER, PRM_READ_BUFFER - PaRMlib support
| [MAPPSA](MAPPSA.md)     | Map PSA - Prefixed Storage Area
| [MAPPSL](MAPPSL.md)     | Map PSL - Page Service List entry
| [MAPPVT](MAPPVT.md)     | Map PVT, PVTEXT, PVTVVTAB - RSM Page Vector Table c.a.
| [MAPQCB](MAPQCB.md)     | Map QCB - GRS Queue Control Block
| [MAPQEL](MAPQEL.md)     | Map QEL - GRS Queue ELement
| [MAPQHT](MAPQHT.md)     | Map QHT, QHTENT - GRS Queue Hash Table header and ENTry
| [MAPQMIDS](MAPQMIDS.md) | Equates for SWAREQ
| [MAPRB](MAPRB.md)       | Map RB - Request Block
| [MAPRCTD](MAPRCTD.md)   | Map RCTD - Region Control Task Data area
| [MAPREGS](MAPREGS.md)   | REGister equateS
| [MAPRMCT](MAPRMCT.md)   | Map RMCT - System Resources Manager Control Table
| [MAPRMPL](MAPRMPL.md)   | Map RMPL, RMPLPT, RMPLP2 - Resource Manager Parameter List c.a.
| [MAPRPL](MAPRPL.md)     | Map RPL, RPL6 - Request Parameter List and extension for LU 6.2
| [MAPRQE](MAPRQE.md)     | Map RQE - EXCP Request Queue Element
| [MAPRT1W](MAPRT1W.md)   | RTMW, RT1TRACK, RT1TRECC, RT1W - RTM1 save/Work area c.a.
| [MAPS99](MAPS99.md)     | Map EMDSECT1-3 and S99\* blocks - DYNALLOC areas and constants
| [MAPSAVE](MAPSAVE.md)   | Map BXASAVE, SAVEAREA - Save areas
| [MAPSCCB](MAPSCCB.md)   | Map SCCB, SCCBCP, SCCBHSA, SCCBMPF - Service Call Control Block c.a.
| [MAPSCT](MAPSCT.md)     | Map SCT - Step Control Table
| [MAPSCTX](MAPSCTX.md)   | Map SCTX - Step Control Table eXtension
| [MAPSCVT](MAPSCVT.md)   | Map SCVT - Secondary Communications Vector Table
| [MAPSDWA](MAPSDWA.md)   | Map SDWA, SDWANRC1-3, SDWAPTRS, SDWARC1-3 - System Diagnostic Work Area c.a.
| [MAPSIOT](MAPSIOT.md)   | Map SIOT - Step Input/Output Table
| [MAPSMCA](MAPSMCA.md)   | Map SMCA - SMf Control tAble
| [MAPSMDE](MAPSMDE.md)   | Map SMDE, SMDE\* - System Managed Directory Entry c.a.
| [MAPSNAP](MAPSNAP.md)   | Map SNAPLIST, SNAPHLIST, SNAPDLIST - SNAP storage LIST entry, headers, dataspaces
| [MAPSRB](MAPSRB.md)     | Map SRB, XSRB - Service Request Block and eXtended Service Request Block
| [MAPSSDR](MAPSSDR.md)   | Map SSDR - SSOB extension for Dynamic device Reconfiguration
| [MAPSSL](MAPSSL.md)     | Map SSL - Short page Service List
| [MAPSSOB](MAPSSOB.md)   | Map SSOB - SubSystem Options Block
| [MAPSSRB](MAPSSRB.md)   | Map SSRB - Suspended Service Request Block
| [MAPSTCB](MAPSTCB.md)   | Map STCB - Seconary Task Control Block
| [MAPSVCE](MAPSVCE.md)   | SVCENTRY, SVCURT - SVC table ENTRY and SVC Update Recording Table entry
| [MAPSVRB](MAPSVRB.md)   | Map SVRB - SuperVisor Request Block
| [MAPSVT](MAPSVT.md)     | Map SVT - Supervisor Vector Table
| [MAPSWAPX](MAPSWAPX.md) | Map SWAPRFX - System Work Area PReFiX
| [MAPTAXE](MAPTAXE.md)   | Map TAXE - TSO Terminal Attention eXit Element
| [MAPTCB](MAPTCB.md)     | Map TCB, TCBFIX, TCBXTNT2 - Task Control Block, preFIX, eXTension
| [MAPTCCW](MAPTCCW.md)   | Map TCCW - EXCP Translation Control Block
| [MAPTCT](MAPTCT.md)     | Map TCT - SMF Timing Control Table
| [MAPTIOT](MAPTIOT.md)   | Map TIOENTRY, TIOTHDR, TIOTPOOL - Task I/O Table Entry, HeaDeR, POOL entry
| [MAPTQE](MAPTQE.md)     | Map TQE - Timer Queue Element
| [MAPUCB](MAPUCB.md)     | Map UCB, UCBOCR, UCBPDCTA, UCBUCS, UCB3540X, UCB3800X - Unit Control Block and extensions
| [MAPUCM](MAPUCM.md)     | Map UCM, UCM\* - Unit Controle Module definition c.a.
| [MAPVRA](MAPVRA.md)     | Map VRA - Variable Recording Area in SDWA
| [MAPVSL](MAPVSL.md)     | Map VSL - Virtual Subarea List entry
| [MAPWQE](MAPWQE.md)     | Map WQE, WQEMAJ, WQEMIN, WQESYAR - WTO Queue Element, Major/Minor WQE, WQE saved SYstem id-ARray
| [MAPWTOPL](MAPWTOPL.md) | Map WTOPL - Write To Operator Parameter List
| [MAPXSB](MAPXSB.md)     | Map XSB - eXtended Status Block

For mappings and overrides, please see [list of mapping macros]($DOC.md#Control-blocks-available-for-DCL).

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.