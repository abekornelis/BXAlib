# Documentation overview

This document provides a technical overview of
- [Coding conventions for macros](#Coding-conventions-for-macros)
- [Overview of global SETx variables](#Overview-of-global-SETx-variables)
- [Control blocks available for DCL](#Control-blocks-available-for-DCL)

Additionally:
- The [Getting Started]($README.md) provides an overview of functionality
- The [Macro index overview]($INDEX.md) provides an overview of macros by category
- The [Wish List]($WISHES.md) provides an overview of pending changes

## Coding conventions for macros

- All global variables start with `&BXA`; these are documented in this
  member. See below.
- Macro-generated labels always start with an underscore
- All local variables, when derived from a parameter, are named after
  the parameter-name, prefixed with an underscore. E.g. if `&REG` is
  defined as a parameter, `&_REG` is the associated local variable.
- For generated code, the same rules apply as for open code, except for
  labels. Within macro's these do not need to appear on an `EQU`
  statement.
- All macro's - except mapping macro's (`MAPxxxxx`) - have a `&LABEL`
  parameter, which is expanded using the [LABEL](LABEL.md) macro.
- All mapping macro's contain a label with the acronym of the control
  block they map. This name is for use with `USING` statements.
- All `DSECT`s contain a length value: the control block acronym with
  `_LEN` appendended. The length `EQU` is preceded by an `ORG` instruction
  to ensure proper evaluation. If this name conflicts with an existing
  field definition in the control block, that field is renamed to
  the acronym with `_SIZE` appended.
- All private control blocks end with alignment on a doubleword
  because internal save areas are allocated adjacent to it.
- If a macro needs expansion of a `DSECT`, this is done through the
  `GENMAPS` macro.

## Overview of global SETx variables

| Name               | Defined  | Used     | Purpose                                           |
|--------------------|----------|----------|---------------------------------------------------|
| &BXA_ABND          | ABND     | END      | Target addresses used by ABND                     |
| &BXA_ABND_DFT      | ABND     | .        | Default label for ABND macro                      |
| &BXA_ABNDPGM       | ABNDPGM  | END      | Dest. addresses for use by ABND                   |
| &BXA_AMODE         | PGM      | .        | Indicate current AMODE: 31 or 24                  |
| &BXA_BITF_...      | DCL      | IF       | \\ Field name containing                          |
| .                  | .        | IFx      |  \\  specified bit name                           |
| .                  | .        | SET      |   \\ or specified value location                  |
| .                  | .        | SETOF    |    \\                                             |
| .                  | .        | SETON    |     \\                                            |
| &BXA_CB_...        | MAP...   | DCL      | Link control block to map-macro                   |
| &BXA_DBG_EP        | DBG      | .        | Name of DBG-routine                               |
| &BXA_DBG_SKIP      | DBG      | END      | Nr of DBG-operations skipped                      |
| &BXA_DBG_PLIST     | DBG      | .        | Name of field containing plist                    |
| &BXA_DBG_PTR       | DBG      | .        | Name of ptr field to DBG-routine                  |
| &BXA_DROP          | DROP     | .        | Prevent multiple expansion                        |
| &BXA_DC_LASTLAB    | DC       | .        | Original label of last labeled DC                 |
| &BXA_DC_OFFSET     | DC       | .        | Nr of unlabeled DCs after LASTLAB                 |
| &BXA_DCOVR         | DCOVR    | DC       | Nr of valid entries in DCOVR_xxx                  |
| &BXA_DCOVR_LAB     | DCOVR    | DC       | Labels of DCOVR entries                           |
| &BXA_DCOVR_PRM     | DCOVR    | DC       | Parm strings for DCOVR entries                    |
| &BXA_DCOVR_NAM     | DCOVR    | DC       | New names (DCOVR \*NEWNAME entries)               |
| &BXA_DS_LASTLAB    | DS       | .        | Original label of last labeled DS                 |
| &BXA_DS_OFFSET     | DS       | .        | Nr of unlabeled DS-s after LASTLAB                |
| &BXA_DSOVR         | DSOVR    | DS       | Nr of valid entries in DSOVR_xxx                  |
| &BXA_DSOVR_LAB     | DSOVR    | DS       | Labels of DSOVR entries                           |
| &BXA_DSOVR_PRM     | DSOVR    | DS       | Parm strings for DSOVR entries                    |
| &BXA_DSOVR_NAM     | DSOVR    | DS       | New names (DSOVR \*NEWNAME entries)               |
| &BXA_EJECTOVR      | EJECTOVR | EJECT    | Ptr to first and last valid in ...                |
| &BXA_EJECTOVR_OPT  | EJECTOVR | EJECT    | Stack of override options                         |
| &BXA_ENTRY         | PGM      | RETRN    | Entry parameter of PGM q.v.                       |
| .                  | .        | EXSR     |                                                   |
| &BXA_EQUOVR        | EQUOVR   | EQU      | Nr of valid entries in EQUOVR_xxx                 |
| &BXA_EQUOVR_LAB    | EQUOVR   | EQU      | Labels of EQUOVR entries                          |
| &BXA_EQUOVR_LEN    | EQUOVR   | EQU      | Lengths of EQUOVR entries                         |
| &BXA_EQUOVR_LOC    | EQUOVR   | EQU      | Locations of EQUOVR for bitfields                 |
| &BXA_EQUOVR_TYP    | EQUOVR   | EQU      | Types of EQUOVR entries                           |
| &BXA_EQUOVR_VAL    | EQUOVR   | EQU      | Values of EQUOVR entries                          |
| &BXA_EXQ_I         | EXQ      | LTORG    | Define instructions for EXecute                   |
| &BXA_EXQ_LAST      | LTORG    | .        | Pointer to last expanded EXQ-instr                |
| &BXA_EXQ_OPS       | EXQ      | LTORG    | Define operands for BXA_EXQ_I                     |
| &BXA_EXSR          | EXSR     | .        | Prevent multiple expansion                        |
| &BXA_EXTRNOVR      | EXTRNOVR | EXTRN    | Nr of valid entries EXTRNOVR_xxx                  |
| &BXA_EXTRNOVR_LAB  | EXTRNOVR | EXTRN    | EXTRNs to be overridden                           |
| &BXA_EXTRNOVR_NAM  | EXTRNOVR | EXTRN    | New name or \*SUPPRESS for EXTRN                  |
| &BXA_MAC_xxxxxxxx  | xxxxxxxx | .        | Prevent multiple expansion                        |
| &BXA_MAPS_LST      | GENMAPS  | .        | List-option on highest level                      |
| &BXA_NEST_fldname  | NESTCB   | CPY      | Control block defined in field                    |
| &BXA_NUMVAL        | CHKDIG   | CLEAR    | A-value of operand, if valid                      |
| .                  | .        | ENDSR    |                                                   |
| .                  | .        | PGM      |                                                   |
| .                  | CHKREG   | USE      | Register number plus 1, if valid                  |
| .                  | .        | USING    |                                                   |
| &BXA_PGM           | PGM      | EXSR     | Prevent multiple expansion                        |
| &BXA_PGM_LABEL     | PGM      | BEGSR    | Label used by PGM-expansion                       |
| &BXA_PGM_TITLE     | PGM      | MAPPRMLB | Title for listing                                 |
| &BXA_PRM(3)        | SPLIT    | .        | Split string into parameters                      |
| .                  | DISSECT  | .        |                                                   |
| &BXA_RC            | CHKMAP   | MAP...   | Returncode                                        |
| &BXA_RD_ALG        | RDATA    | RLTORG   | Define remote data alignment                      |
| &BXA_RD_ARG        | RDATA    | RLTORG   | Define remote data arguments                      |
| &BXA_RD_KEY        | RDATA    | RLTORG   | Define remote data keywords                       |
| &BXA_RD_LAB        | RDATA    | RLTORG   | Define remote data labels                         |
| &BXA_RD_NDX        | RDATA    | RLTORG   | Define remote data indexes                        |
| &BXA_RD_OPC        | RDATA    | RLTORG   | Define remote data opcodes                        |
| &BXA_RD_RETVAL     | RDATA    | RLTORG   | RD_MODE=COND: label of dup. data                  |
| &BXA_RD_VAL        | RDATA    | RLTORG   | Define remote data keyword values                 |
| &BXA_REGN_...      | EQU      | .        | Register numbers                                  |
| &BXA_REGT_...      | EQU      | .        | Register types                                    |
| &BXA_RETRN_LBL     | RETRN    | END      | Labels for out-of-line routine                    |
| &BXA_RETRN_RC      | RETRN    | END      | Returncodes                                       |
| &BXA_RETRN_RP      | RETRN    | END      | Return pointers                                   |
| &BXA_RETRN_RS      | RETRN    | END      | Reasoncodes                                       |
| &BXA_RETRN_WA      | RETRN    | END      | WORKAREA=FREE/NOFREE                              |
| &BXA_SAVES         | PGM      | END      | Nr of internal save-areas                         |
| &BXA_SETMODE       | SETMODE  | .        | Prevent multiple expansion                        |
| &BXA_SETMODE_SAVE  | SETMODE  | .        | Register with saved PSW key                       |
| &BXA_SHOWALL       | PGM      | PGM      | Do not suppress any listing lines                 |
| .                  | .        | GENMAPS  | Do not suppress any listing lines                 |
| &BXA_SR_CALLER     | EXSR     | END      | Array of calling subr-names                       |
| &BXA_SR_CALLED     | EXSR     | END      | Array of called subr-names                        |
| &BXA_SRDNAM        | BEGSR    | END      | Array of defined subroutines                      |
| &BXA_SRDDUP        | BEGSR    | END      | Array of 'multiply defined' indic.                |
| &BXA_SRDTYP        | BEGSR    | EXSR     | Array of defined subroutine types                 |
| .                  | .        | ENDSR    |                                                   |
| &BXA_SRNAML        | BEGSR    | END      | Max length of subroutine name                     |
| .                  | EXSR     |          |                                                   |
| &BXA_SRUASC        | EXSR     | BEGSR    | Array of used subroutines ASCmode                 |
| &BXA_SRUCT         | EXSR     | END      | Array of subr invocation count                    |
| &BXA_SRUNAM        | EXSR     | END      | Array of used subroutines                         |
| &BXA_SRUSVC        | EXSR     | BEGSR    | Array of used subroutines SVCmode                 |
| &BXA_STK           | IF       | ELSE     | Ptr to last valid in &BXA_STK_...                 |
| .                  | .        | ENDIF    |                                                   |
| .                  | CASE     | ENDCASE  |                                                   |
| .                  | DO       | ENDDO    |                                                   |
| .                  | LOOP     | LEAVE    |                                                   |
| .                  | .        | PGM0     |                                                   |
| &BXA_STK_CND       | DO       | ENDDO    | Stack of UNTIL condition/count reg                |
| &BXA_STK_CLB       | LOOP     | ENDDO    | Stack of UNTIL condition labels                   |
| &BXA_STK_DO        | DO       | ENDDO    | Stack of DO labels                                |
| .                  | .        | LEAVE    |                                                   |
| &BXA_STK_OP        | IF       | ELSE     | Stack of open structure opcodes                   |
| .                  | CASE     | ENDCASE  |                                                   |
| .                  | DO       | ENDIF    |                                                   |
| .                  | .        | LEAVE    |                                                   |
| &BXA_STK_LBL       | IF       | ELSE     | \\ Stack of labels to be generated                |
| .                  | CASE     | ENDCASE  |  \\ (End-of-block labels)                         |
| .                  | DO       | ENDIF    |                                                   |
| &BXA_STK_LVL       | CASE     | ENDCASE  | Nesting levels                                    |
| &BXA_STK_USE       | DO       | ENDDO    | USEd register for loop counter                    |
| &BXA_SUBR          | BEGSR    | ENDSR    | Current subroutine name or \*MAIN                 |
| .                  | PGM      | EXSR     |                                                   |
| &BXA_SUBRTP        | BEGSR    | ENDSR    | Type of current subroutine                        |
| .                  | PGM      | EXSR     |                                                   |
| &BXA_SVCMODE       | PGM      | SETMODE  | On when in supervisor mode                        |
| &BXA_USE_DS        | DCL      | USE      | Names of enclosing DSECTs                         |
| &BXA_USE_FLD       | DCL      | USE      | Names of DeCLared complex fields                  |
| &BXA_USE_LBL       | DCL      | USE      | Labels for the dependent USINGs                   |
| &BXA_USE_R12       | PGM      | BEGSR    | Label for USING R12                               |
| &BXA_USE_SDS       | DCL      | USE      | Names of enclosed DSECTs                          |
| &BXA_USEC_ROUT     | USE      | BEGSR    | Routine names for USE SCOPE=CALLED                |
| &BXA_USEC_ARGL     | USE      | BEGSR    | Labels on USE SCOPE=CALLED                        |
| &BXA_USEC_ARG1     | USE      | BEGSR    | Control-block on USE SCOPE=CALLED                 |
| &BXA_USEC_ARG2     | USE      | BEGSR    | Base on USE SCOPE=CALLED                          |
| &BXA_USED_REGS     | USING    | .        | Registers available/unavailable                   |
| .                  | USE      |          |                                                   |
| &BXA_USEFLD        | USING    | DROP     | Fields used with &BXA_USELBL                      |
| .                  | PUSH     | POP      |                                                   |
| &BXA_USENDX        | USING    | DROP     | \\ Current valid in &BXA_USENDX0                  |
| .                  | PUSH     | POP      |  \\  and &BXA_USENDX1                             |
| &BXA_USENDX0       | USING    | DROP     | \\ Stack of low indexes for                       |
| .                  | PUSH     | POP      |  \\   &BXA_USELBL and &BXA_USEREG                 |
| &BXA_USENDX1       | USING    | DROP     | \\ Stack of high indexes for                      |
| .                  | PUSH     | POP      |  \\  &BXA_USELBL and &BXA_USEREG                  |
| &BXA_USELBL        | USING    | DROP     | Labels of ordinary usings                         |
| .                  | PUSH     | POP      |                                                   |
| &BXA_USEREG        | USING    | DROP     | Registers used with &BXA_USELBL                   |
| .                  | PUSH     | POP      |                                                   |
| &BXA_WALAB         | PGM      | BEGSR    | Using label for obtained storage                  |
| &BXA_WALEN         | PGM      | RETRN    | Length of obtained storage                        |
| &BXA_WORKPTR(3)    | PGM      | RETRN    | Pointer to obtained storage                       |
| &IEC024I           | MAP$AMQS | .        | Prototype message text                            |
| ------------------ | -------- | -------- | ----------------------------------                |
| &SP_DBG            | SYSPARM  | DBG      | On if debugging requested                         |
| .                  | .        | END      |                                                   |
| .                  | .        | GENMAPS  |                                                   |
| .                  | .        | MAP$DBG  |                                                   |
| &SP_LICENSE        | SYSPARM  | CHKLIC   | License name                                      |
| &SP_LICSTAT        | SYSPARM  | CHKLIC   | License status                                    |
| &SP_LICOK          | SYSPARM  | --       | On if valid license accespted                     |
| &SP_OPT            | SYSPARM  | PGM      | On if optimization requested                      |
| &SP_SHOWALL        | SYSPARM  | PGM      | On if nothing to be suppressed                    |
| .                  | .        | END      |                                                   |
| .                  | .        | GENMAPS  |                                                   |
| .                  | .        | LTORG    |                                                   |
| &SP_SRLIST         | SYSPARM  | END      | On if subroutine listing requested                |
| &SP_SRXREF         | SYSPARM  | END      | On for subroutine cross-reference                 |

## Control blocks available for DCL

The MAPxxxxx macros do NOT contain a copy of the IBM-defined control block.
Rather, they contain overrides for the IBM-defined fields and bits.

The overrides are based on the IBM mapping macros as shipped with OS/390 V2.6.
Any later changes to the underlying mapping macros are not reflected in the MAPxxxxx macros mentioned below.

| Control block name | Mapmacro | Description                                |
|--------------------|----------|--------------------------------------------|
|                    | MAPBITS  | BIT equateS                                |
|                    | MAPEQU   | EQUates of registers, bits, and masks      |
|                    | MAPLMASM | Latch Management equates for ASseMbler     |
|                    | MAPREGS  | REGister equateS                           |
| ABEP               | MAPABEP  | ABend Exit Parameter list                  |
| ACB                | MAPACB   | Access Control Block                       |
| ACEE               | MAPACEE  | ACcessor Environment Element               |
| ACT                | MAPJCT   | Accounting Control Table                   |
| ADSR               | MAPADSR  | Symptom Record sections 1 and 2            |
| ADSRCMPS           | MAPADSR  | Symptom Record section 2.1                 |
| ADSRDBST           | MAPADSR  | Symptom Record primary symptom string      |
| ADSRROSD           | MAPADSR  | Symptom Record secondary symptom string    |
| ADSR5ST            | MAPADSR  | Symptom Record section 5                   |
| ADYENF             | MAPADYEN | DAE Event NotiFication parameter list      |
| AE                 | MAPAE    | VSM Allocated Element                      |
| ASCB               | MAPASCB  | Address Space Control Block                |
| ASEO               | MAPASEO  | Address Space crEation Output area         |
| ASMPOOLS           | MAPASMVT | ASM cell POOL controller                   |
| ASMVT              | MAPASMVT | Auxiliary Storage Manager Vector Table     |
| ASSB               | MAPASSB  | Address Space Secondary Block              |
| ASVT               | MAPASVT  | Address Space Vector Table                 |
| ASXB               | MAPASXB  | Address Space eXtension Block              |
| BASEA              | MAPBASEA | Master Scheduler Resident Data Area        |
| BASEX              | MAPBASEA | Master Scheduler Resident Data Area eXtens.|
| BDW                | MAPDCB   | Block Descriptor Word                      |
| BXASAVE            | MAPSAVE  | Extended SAVE area                         |
| CAMLOC             | MAPCAM   | CAMlst LOCate results                      |
| CAMLOCVOL          | MAPCAM   | CAMlst LOCate VOLume entry                 |
| CAMLST             | MAPCAM   | CAMLST parameter list                      |
| CDE                | MAPCDE   | Contents Directory Entry                   |
| CIBHDR             | MAPCIB   | Command Input Buffer HeaDeR                |
| CIBX               | MAPCIB   | Command Input Buffer eXtension             |
| COM                | MAPCOM   | COMmunication area                         |
| CQE                | MAPCQE   | Console Queue Element                      |
| CSCB               | MAPCSCB  | Command Scheduling Control Block           |
| CSCX               | MAPCSCB  | Command Scheduling Control block eXtension |
| CVT                | MAPCVT   | Communications Vector Table                |
| CVTFIX             | MAPCVT   | Communications Vector Table preFIX         |
| CVTVSTGX           | MAPCVT   | CVT Virtual SToraGe eXtension              |
| CVTXTNT1           | MAPCVT   | CVT os-os/vs common eXTension              |
| CVTXTNT2           | MAPCVT   | CVT os/vs1-os/vs2 common eXTension         |
| DCB                | MAPDCB   | Data Control Block                         |
| DCBE               | MAPDCBE  | Data Control Block Extension               |
| DDRCOM             | MAPDDRCO | \\ IOS Dynamic Device Reconfiguration      |
|                    |          |  \\   COMmunication area                   |
| DECB               | MAPDECB  | Data Event Control Block                   |
| DESB               | MAPDES   | DirEntry Services Buffer header            |
| DESD               | MAPDES   | DirEntry Services member Data descriptor   |
| DESL               | MAPDES   | DirEntry Services name List                |
| DESN               | MAPDES   | DirEntry Services Name record              |
| DESP               | MAPDES   | DirEntry Services Parmlist                 |
| DESR               | MAPDES   | DirEntry Services Reason codes             |
| DESRCS             | MAPDES   | DirEntry Services Return CodeS             |
| DESX               | MAPDES   | DirEntry Services eXit plist               |
| DOCNTFLD           | MAPDOTU  | Dynamic Output length/parameter FieLD      |
| DOCNTLST           | MAPDOTU  | Dynamic Output LiST of text unit pointers  |
| DOCNUNIT           | MAPDOTU  | Dynamic Output text UNIT                   |
| DSAB               | MAPDSAB  | Data Set Association Block                 |
| DSABANMI           | MAPDSAB  | DSAB Alternate NaMe Information block      |
| DSABQDB            | MAPDSABQ | DSAB Queue Descriptor Block                |
| DSCB1              | MAPDSCB1 | Data Set Control Block - format 1          |
| DSCB2              | MAPDSCB2 | Data Set Control Block - format 2          |
| DSCB3              | MAPDSCB3 | Data Set Control Block - format 3          |
| DSCB4              | MAPDSCB4 | Data Set Control Block - format 4          |
| DSCB5              | MAPDSCB5 | Data Set Control Block - format 5          |
| DST                | MAPDES   | Direntry Services Screen Table             |
| ECB                | MAPECB   | Event Control Block                        |
| ECBE               | MAPECB   | Event Control Block Extension              |
| ECVT               | MAPECVT  | Extended Communications Vector Table       |
| EMDSECT1           | MAPS99   | Dynalloc parameter list to IEFDB476        |
| EMDSECT2           | MAPS99   | Dynalloc message buffer area               |
| EMDSECT3           | MAPS99   | Dynalloc message buffer area array         |
| EPAL               | MAPEPAL  | External Parameter Area for Locate SWA mgr |
| EPAX               | MAPEPAL  | eXtended EPAL                              |
| EVNT               | MAPEVNT  | EVeNTs control block                       |
| EVNTENTRY          | MAPEVNT  | EVeNTs table ENTRY                         |
| FRRPL              | MAPFRRPL | Function Recovery Routine Parameter area   |
| FRRS               | MAPFRRS  | Function Recovery Routine Stack            |
| FRRSENTR           | MAPFRRS  | FRR ENTRy                                  |
| FRRSXENT           | MAPFRRS  | FRR ENTry eXtension                        |
| FRRSXSTK           | MAPFRRS  | FRR STacK eXtension                        |
| GVT                | MAPGVT   | GRS Vector Table                           |
| GVTX               | MAPGVTX  | GRS Vector Table eXtension                 |
| IHSA               | MAPIHSA  | Interrupt Handler Save Area                |
| IOB                | MAPIOB   | Input/Output Block                         |
| IOQ                | MAPIOQ   | IOS Queue element                          |
| IOQE               | MAPIOQ   | IOS Queue element Extension                |
| IOSB               | MAPIOSB  | I/O Supervisor Block                       |
| IOSX               | MAPIOSX  | I/O Supervisor block eXtension             |
| JCT                | MAPJCT   | Job Control Table                          |
| JCTX               | MAPJCTX  | Job Control Table eXtension                |
| JESCT              | MAPJESCT | JES Communication Table                    |
| JESMNTBL           | MAPJESCT | JES MouNTaBLe device class table           |
| JESPEXT            | MAPJESCT | JESCT Pageable EXTension                   |
| JFCB               | MAPJFCB  | Job File Control Block                     |
| JFCBE              | MAPJFCBE | Job File Control Block Extension for 3800  |
| JFCBX              | MAPJFCBX | Job File Control Block eXtension           |
| JSCB               | MAPJSCB  | Job Step Control BLock                     |
| LCT                | MAPLCT   | Linkage Control Table                      |
| LDA                | MAPLDA   | VSM Local Data Area                        |
| LLE                | MAPLLE   | Load List Element                          |
| LPDE               | MAPLPDE  | Link Pack Directory Entry                  |
| NTCRPL             | MAPIEANT | Named Token CReate Parameter List          |
| NTDLPL             | MAPIEANT | Named Token DeLete Parameter List          |
| NTRTPL             | MAPIEANT | Named Token ReTrieve Parameter List        |
| OC24               | MAPOCPL  | Open/Close parameter list (24-bit mode)    |
| OC31               | MAPOCPL  | Open/Close parameter list (31-bit mode)    |
| ORE                | MAPORE   | Operator Reply Element                     |
| OUCB               | MAPOUCB  | ResOurces manager User Control Block       |
| PCCA               | MAPPCCA  | Physical Configuration Communication Area  |
| PCCAVT             | MAPPCCAV | PCCA Vector Table                          |
| PDAB               | MAPPDAB  | Parallel Data Access Block                 |
| PDS                | MAPPDS   | Partitioned DataSet directory entry        |
| PDS2               | MAPPDS   | Partitioned DataSet (extended) direntry    |
| PEL                | MAPPEL   | Parameter Element List (ENQ/DEQ/RESERVE)   |
| PMAR               | MAPPMAP  | Program Management Attribute Record        |
| PMARA              | MAPPMAP  | PMAR - load module extension               |
| PMARL              | MAPPMAP  | PMAR - program object extension            |
| PMARR              | MAPPMAP  | PMAR - internal extension                  |
| PRB                | MAPPRB   | Program Request Block                      |
| PRM_LIST_BUFFER    | MAPPRMLB | PaRMlib services LIST BUFFER               |
| PRM_MESSAGE_BUFFER | MAPPRMLB | PaRMlib services MESSAGE BUFFER            |
| PRM_READ_BUFFER    | MAPPRMLB | PaRMlib services BUFFER for member READ    |
| PSA                | MAPPSA   | Prefixed Storage Area                      |
| PSL                | MAPPSL   | Page Service List entry                    |
| PVT                | MAPPVT   | RSM Page Vector Table                      |
| PVTEXT             | MAPPVT   | RSM Page Vector Table EXTension            |
| PVTVVTAB           | MAPPVT   | RSM Page Vector VDAC TABle                 |
| QCB                | MAPQCB   | GRS Queue Control Block                    |
| QEL                | MAPQEL   | GRS Queue ELement                          |
| QHT                | MAPQHT   | GRS Queue Hash Table header                |
| QHTENT             | MAPQHT   | GRS Queue Hash Table ENTry                 |
| RB                 | MAPRB    | Request Block                              |
| RCTD               | MAPRCTD  | Region Control Task Data area              |
| RDW                | MAPDCB   | Record Descriptor Word                     |
| RMCT               | MAPRMCT  | System Resources Manager Control Table     |
| RMPL               | MAPRMPL  | Resource Manager Parameter List            |
| RMPLPT             | MAPRMPL  | PoinTer to RMPL                            |
| RMPLP2             | MAPRMPL  | Pointer to userparm for resmgr routine     |
| RPL                | MAPRPL   | Request Parameter List                     |
| RPL6               | MAPRPL   | RPL extension for LU 6.2                   |
| RQE                | MAPRQE   | EXCP Request Queue Element                 |
| RTMW               | MAPRT1W  | RTM1 save/Work area                        |
| RT1TRACK           | MAPRT1W  | RTM1 TRACKing area                         |
| RT1TRECC           | MAPRT1W  | RTM1 RECursion Control data                |
| RT1W               | MAPRT1W  | RTM1 Work area                             |
| SAVEAREA           | MAPSAVE  | Standard SAVE AREA                         |
| SCCB               | MAPSCCB  | Service Call Control Block                 |
| SCCBCP             | MAPSCCB  | SCCB CPu information entry                 |
| SCCBHSA            | MAPSCCB  | SCCB HSA information entry                 |
| SCCBMPF            | MAPSCCB  | SCCB MPF information entry                 |
| SCT                | MAPSCT   | Step Control Table                         |
| SCTX               | MAPSCTX  | Step Control Table eXtension               |
| SCVT               | MAPSCVT  | Secondary Communications Vector Table      |
| SCW                | MAPDCB   | Segment Control Word                       |
| SDW                | MAPDCB   | Segment Descriptor Word                    |
| SDWA               | MAPSDWA  | System Diagnostic Work Area                |
| SDWANRC1           | MAPSDWA  | SDWA Non-ReCordable extension 1            |
| SDWANRC2           | MAPSDWA  | SDWA Non-ReCordable extension 2            |
| SDWANRC3           | MAPSDWA  | SDWA Non-ReCordable extension 3            |
| SDWAPTRS           | MAPSDWA  | SDWA PoinTeRS extension block              |
| SDWARC1            | MAPSDWA  | SDWA ReCordable extension 1                |
| SDWARC2            | MAPSDWA  | SDWA ReCordable extension 2                |
| SDWARC3            | MAPSDWA  | SDWA ReCordable extension 3                |
| SIOT               | MAPSIOT  | Step Input/Output Table                    |
| SMCA               | MAPSMCA  | SMf Control tAble                          |
| SMDE               | MAPSMDA  | System Managed Directory Entry basic sect. |
| SMDE_FD            | MAPSMDA  | SMDE hfs File Descriptor section           |
| SMDE_NAME          | MAPSMDA  | SMDE NAME section                          |
| SMDE_NLST          | MAPSMDA  | SMDE NoteLiST section                      |
| SMDE_PNAME         | MAPSMDA  | SMDE Primary NAME section                  |
| SMDE_TOKEN         | MAPSMDA  | SMDE TOKEN section                         |
| SNAPDLIST          | MAPSNAP  | SNAP Dataspace LIST entry                  |
| SNAPHLIST          | MAPSNAP  | SNAP Header LIST entry                     |
| SNAPLIST           | MAPSNAP  | SNAP storage LIST entry                    |
| SRB                | MAPSRB   | Service Request Block                      |
| SSDR               | MAPSSDR  | SSOB ext.for Dynamic device Reconfiguration|
| SSL                | MAPSSL   | Short page Service List                    |
| SSOB               | MAPSSOB  | SubSystem Options Block                    |
| SSRB               | MAPSSRB  | Suspended Service Request Block            |
| STCB               | MAPSTCB  | Seconary Task Control Block                |
| SVCENTRY           | MAPSVCE  | SVC table ENTRY                            |
| SVCURT             | MAPSVCE  | SVC Update Recording Table entry           |
| SVRB               | MAPSVRB  | SuperVisor Request Block                   |
| SVT                | MAPSVT   | Supervisor Vector Table                    |
| SWAREQPL           | MAPEPAL  | SWAREQ Parameter List                      |
| S99RB              | MAPS99   | Dynalloc Request Block                     |
| S99RBP             | MAPS99   | Dynalloc Request Block Pointer             |
| S99RBX             | MAPS99   | Dynalloc Request Block eXtension           |
| S99TUFLD           | MAPS99   | Dynalloc request Text Unit FieLD           |
| S99TUNIT           | MAPS99   | Dynalloc request Text UNIT                 |
| S99TUPL            | MAPS99   | Dynalloc request Text Unit Pointer List    |
| TAXE               | MAPTAXE  | TSO Terminal Attention eXit Element        |
| TCB                | MAPTCB   | Task Control Block                         |
| TCBFIX             | MAPTCB   | TCB preFIX                                 |
| TCBXTNT2           | MAPTCB   | TCB eXTension                              |
| TCCW               | MAPTCCW  | EXCP Translation Control Block             |
| TCT                | MAPTCT   | SMF Timing Control Table                   |
| TIOENTRY           | MAPTIOT  | Task I/O Table Entry                       |
| TIOTHDR            | MAPTIOT  | Task I/O Table header                      |
| TIOTPOOL           | MAPTIOT  | Task I/O Table Pool entry                  |
| TQE                | MAPTQE   | Timer Queue Element                        |
| TTRN               | MAPPDS   | Track, Record, iNdicator field             |
| TTRX               | MAPPDS   | Track, Record, available field             |
| UCB                | MAPUCB   | Unit Control Block                         |
| UCBOCR             | MAPUCB   | UCB extension - Optical Character Reader   |
| UCBPDCTA           | MAPUCB   | UCB extension - Channel to channel Adapter |
| UCBUCS             | MAPUCB   | UCB extension - Universal Character Set    |
| UCB3540X           | MAPUCB   | UCB extension - 3540                       |
| UCB3800X           | MAPUCB   | UCB extension - 3800 printer               |
| UCM                | MAPUCM   | Unit Controle Module definition            |
| UCMEFEXT           | MAPUCM   | UCM individual device Entry Fixed EXTension|
| UCMEIL             | MAPUCM   | UCM Event Indication List                  |
| UCMEPEXT           | MAPUCM   | UCM indiv. device Entry Pageable EXTension |
| UCMFEXTA           | MAPUCM   | UCM Fixed EXTension bAse                   |
| UCMFSAVE           | MAPUCM   | UCM Fixed extension SAVE area              |
| UCMLIST            | MAPUCM   | UCM List of individual device entries      |
| UCMPEXTA           | MAPUCM   | UCM Pageable EXTension bAse                |
| UCMPRFX            | MAPUCM   | UCM MCS PReFiX area                        |
| UCM2EXT            | MAPUCM   | UCM OS/VS2 EXTension                       |
| VRA                | MAPVRA   | Variable Recording Area in SDWA            |
| VSL                | MAPVSL   | Virtual Subarea List entry                 |
| WQE                | MAPWQE   | WTO Queue Element                          |
| WQEMAJ             | MAPWQE   | Major WQE                                  |
| WQEMIN             | MAPWQE   | Minor WQE                                  |
| WQESYAR            | MAPWQE   | WQE saved SYstem id-ARray                  |
| WTOPL              | MAPWTOPL | Write To Operator Parameter List           |
| XSB                | MAPXSB   | eXtended Status Block                      |
| XSRB               | MAPSRB   | eXtended Service Request Block             |
