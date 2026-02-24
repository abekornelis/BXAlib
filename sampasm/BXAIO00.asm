BXAIO00  TITLE 'Dynamic module for VSAM I/O handling'                   00010000
*********************************************************************** 00020000
* Start create : 20-03-1989                                             00030000
* 1st delivery : 15-08-1989                                             00040000
* Designer     : AF Kornelis                                            00050000
* Programmer   : AF Kornelis                                            00060000
* Reason       : Untie logical record lay-outs from physical file       00070000
*                structure                                              00080000
*********************************************************************** 00090000
* Change 01    : 22-06-1990                                             00100000
* Programmer   : JB                                                     00110000
* Reason       : Add 2 logical record lay-outs: PDD and CSC             00120000
*              : Add supporting physical files: PDD and CSC             00130000
*********************************************************************** 00140000
* Change 02    : 31-10-1991                                             00150000
* Programmer   : JB                                                     00160000
* Reason       : Add 1 logical record lay-out: CCX                      00170000
*              : Add supporting physical file: CCX                      00180000
*********************************************************************** 00190000
* Change 03    : 31-05-1992                                             00200000
* Programmer   : JB                                                     00210000
* Reason       : Add 1 logical record lay-out: ACD                      00220000
*              : Add supporting physical file: ACD                      00230000
*********************************************************************** 00240000
* Change 04    : 31-05-1996                                             00250000
* Programmer   : JB                                                     00260000
* Reason       : Add 1 logical record lay-out: SVD                      00270000
*              : Add supporting physical file: SVD                      00280000
*              : These changes were never implemented                   00290000
*********************************************************************** 00300000
* Change 05    : Summer 2001                                            00310000
* Programmer   : Abe F. Kornelis                                        00320000
* Reason       : Remove warning errors from assembly                    00330000
*                Improve comments                                       00340000
*********************************************************************** 00350000
         EJECT                                                          00360000
*********************************************************************** 00370000
*                                                                       00380000
* When maintaining this program, please mind the following:             00390000
* - Never change any data or coding in the program at run-time. For     00400000
*   storing data, always use getmained areas. Otherwise reenterability  00410000
*   will be lost.                                                       00420000
* - When suballocating storage areas (whether getmained or not)         00430000
*   always allocate on a doubleword boundary.                           00440000
* - Remember never to use r12, since it contains information that the   00450000
*   PL/I estae/espie-routines need for error/exception handling.        00460000
* - Do not try to call this module recursively: it won't work.          00470000
* - Allocate all variable storage areas from subpool &sp (17). Since    00480000
*   applications get their storage from subpool 0, the chances of       00490000
*   destructive interference between BXAIO00 and application is         00500000
*   minimal. By taking all storage from the same subpool, the           00510000
*   chances of page-faults are minimized.                               00520000
* - Debugging is controlled by the &DBG global variable: if it          00530000
*   contains the value 1 then debugging code will be generated,         00540000
*   otherwise debugging code will be skipped.                           00550000
* - Optimization (speed and size of load) is controlled by &OPT         00560000
* - The program is reenterable. If it is to become refreshable, remove  00570000
*   the crashmem area and have the uaerr error-exit dump in stead of    00580000
*   using the crashmem area.                                            00590000
*                                                                       00600000
*******                                                                 00610000
*                                                                       00620000
* The following subjects still need to be taken care of:                00630000
* - IMS/LST conflicts                                                   00640000
* - Check RPL-status before issuing any vsam-request                    00650000
* - temporary modifications are marked by **!!                          00660000
*                                                                       00670000
*********************************************************************** 00680000
         EJECT                                                          00690000
*********************************************************************** 00700000
*                                                                       00710000
* The structure of control blocks used in this program is as follows:   00720000
*   ________                                                            00730000
*  |        |                                                           00740000
*  | Caller |                                                           00750000
*  | BXAIOxxx     ________                                              00760000
*  |--------|    |        |                                             00770000
*  |LNSUAPTR|--->|USERAREA|     ________                                00780000
*  |________|    |--------|    |        |                               00790000
*                |UAFDBPTR|--->|  FDB   |                               00800000
*                |________|    |--------|                               00810000
*                              |FDBNEXT |---> next FDB --> next FDB etc 00820000
*                              |--------|                               00830000
*                              | FDBACB |---> ACB ---> DDNAME ---> FILE 00840000
* LNSUAPTR is a pointer to     |--------|                               00850000
*    the USERAREA, where all   | FDBRPL |---> RPL ---> ACB        ____  00860000
*    caller-dependent data     |--------|     _______            | ME | 00870000
*    are to be found.          | FDBMAP |--->|  MME  |---------->|----| 00880000
*                              |________|    |-------|    ____   | ME | 00890000
* UAFDBPTR is the entry to                   |  MME  |-->| ME |  |----| 00900000
*    the chain of FDBs. Each FDB             |-------|   |----|  | .  | 00910000
*    contains information pertaining         |   .   |   | ME |  | .  | 00920000
*    to one physical dataset.                |   .   |   |----|  | .  | 00930000
*                                            |   .   |   | .  |  |____| 00940000
* FDBMAP is a pointer to a list of           |_______|   | .  |         00950000
*    Map-Master-Elements. Each MME                       | .  |         00960000
*    corresponds with one parameter version.             |____|         00970000
*    Thus, for each dataset there is one and only one                   00980000
*    MME-list, which is the same for all callers.                       00990000
*                                                                       01000000
* The MME in turn contains a pointer to a list of Map-Elements.         01010000
*    Each Map-Element specifies one block of data that may be           01020000
*    moved in one piece between the parameter (BXAIOPRM) and a          01030000
*    physical record.                                                   01040000
*                                                                       01050000
*********************************************************************** 01060000
         EJECT                                                          01070000
*********************************************************************** 01080000
*                                                                       01090000
* The program has been split up into the following sections:            01100000
*              each section has its own addressability.                 01110000
*                                                                       01120000
* - PHASE1   - housekeeping                                             01130000
*            - general check of parameter                               01140000
* - PHASE2   - evaluation of the requested function code                01150000
*            - setup of FDBs to reflect the request                     01160000
*            - phase2 includes the checkxx routines                     01170000
* - PHASE3   - execution of the requests                                01180000
*            - phase3 includes the rxx routines                         01190000
* - PHASE4   - waiting for completion of asynchronous i/o               01200000
*            - post-processing                                          01210000
*            - cleanup of resources no longer needed                    01220000
*            - return to caller                                         01230000
* - RCHECK   - second level routine that waits for vsam-i/o-completion  01240000
* - ERROR    - error handling routine                                   01250000
*            - error includes the error exits (for example: vserr)      01260000
* - RSETBASE - lowest-level subroutine, used for returning to a caller  01270000
*              which may or may not use a different base address for    01280000
*              its addressability.                                      01290000
* - RSNAP    - debugging help routine, linked as a separate subprogram. 01300000
*            - rsnap dumps control blocks that are both defined by this 01310000
*              program and currently in use.                            01320000
*                                                                       01330000
*********************************************************************** 01340000
         EJECT                                                          01350000
*                                                                       01360000
* The assembler program accepts as a JCL-parameter a specification      01370000
* for the variable SYSPARM. The value entered in the JCL will be        01380000
* passed to a global set symbol named &SYSPARM. The value specified     01390000
* in the JCL is passed as a single string. This macro decomposes the    01400000
* string into separate parameters. Then the parameters are checked      01410000
* and handled. 4 different keywords are allowed:                        01420000
* - DEBUG   : generate debugging code (rsnap routine, etc.)             01430000
* - NODEBUG : do not generate debugging code                            01440000
* - OPT     : generate a fully optimized program                        01450000
* - NOOPT   : generate a program with complete error checking           01460000
*                                                                       01470000
         MACRO                                                          01480000
         CHECKPRM                                                       01490000
*                                                                       01500000
         GBLB  &DBG,&OPT                                                01510000
&DBG     SETB  0                       * Default: no debug coding       01520000
&OPT     SETB  1                       * Default: full optimization     01530000
         AIF   ('.&SYSPARM' EQ '.').EXIT                                01540000
*                                                                       01550000
* First the SYSPARM string is to be split into substrings               01560000
*                                                                       01570000
         LCLC  &P(5)                   * Array to contain parms         01580000
         LCLA  &I,&N,&X                                                 01590000
&I       SETA  0                       * Character indec for &SYSPARM   01600000
&N       SETA  1                       * Next position to extract       01610000
&X       SETA  1                       * Parameter counter (array &P)   01620000
.LOOP1   ANOP                                                           01630000
&I       SETA  &I+1                    * Increment character index      01640000
         AIF   (&I GT K'&SYSPARM).LOOP1X       * End-of-string ??       01650000
         AIF   ('&SYSPARM'(&I,1) NE ',').LOOP1 * End-of-substring ??    01660000
&P(&X)   SETC  '&SYSPARM'(&N,&I-&N)            * Extract substring      01670000
&N       SETA  &I+1                    * Set ptr to start of substring  01680000
&X       SETA  &X+1                    * Increment substring counter    01690000
         AGO   .LOOP1                  * and go check next character    01700000
*                                                                       01710000
.LOOP1X  ANOP                                                           01720000
&P(&X)   SETC  '&SYSPARM'(&N,&I-1)     * Extract last substring         01730000
*                                                                       01740000
* Now check that keywords are valid                                     01750000
*                                      * &X now is count of parms       01760000
&I       SETA  0                       * Index into array P             01770000
.LOOP2   ANOP                                                           01780000
&I       SETA  &I+1                    * Increment parm index           01790000
         AIF   (&I GT &X).LOOP2X       * All parms checked ??           01800000
         AIF   ('.&P(&I)' EQ '.').LOOP2 * Skip empty parm               01810000
         AIF   ('.&P(&I)' EQ '.OPT').OPT                                01820000
         AIF   ('.&P(&I)' EQ '.NOOPT').NOOPT                            01830000
         AIF   ('.&P(&I)' EQ '.DEBUG').DEBUG                            01840000
         AIF   ('.&P(&I)' EQ '.NODEBUG').NODEBUG                        01850000
         MNOTE 4,'Invalid SYSPARM operand: &P(&I)'                      01860000
         AGO   .LOOP2                  * and go try next parm           01870000
*                                                                       01880000
.OPT     ANOP                                                           01890000
&OPT     SETB  1                                                        01900000
         MNOTE 0,'Optimized coding will be generated'                   01910000
         AGO   .LOOP2                                                   01920000
*                                                                       01930000
.NOOPT   ANOP                                                           01940000
&OPT     SETB  0                                                        01950000
         MNOTE 0,'Fault tolerant coding will be generated'              01960000
         AGO   .LOOP2                                                   01970000
*                                                                       01980000
.DEBUG   ANOP                                                           01990000
&DBG     SETB  1                                                        02000000
         MNOTE 0,'Debugging code will be included'                      02010000
         AGO   .LOOP2                                                   02020000
*                                                                       02030000
.NODEBUG ANOP                                                           02040000
&DBG     SETB  0                                                        02050000
         MNOTE 0,'Debugging code will be excluded'                      02060000
         AGO   .LOOP2                                                   02070000
*                                                                       02080000
.LOOP2X  ANOP                                                           02090000
.EXIT    ANOP                                                           02100000
*                                                                       02110000
         MEND                                                           02120000
*                                                                       02130000
         EJECT                                                          02140000
*                                                                       02150000
* The RSNAP-routine, which is available in debug mode only, may return  02160000
* an error code. If an error code is received, then the error handler   02170000
* should be invoked before continuing. Thus the error will be issued    02180000
* as it should.                                                         02190000
* In order not to have to code the whole protocol for each call to      02200000
* the snap routine an extended snap macro (ESNAP) has been provided.    02210000
* This macro will generate a call to the RSNAP-routine with full        02220000
* error handling.                                                       02230000
*                                                                       02240000
         MACRO                                                          02250000
         ESNAP                                                          02260000
*                                                                       02270000
         GBLB  &DBG,&ERR                                                02280000
         AIF   (NOT &DBG).ESNAP                                         02290000
*                                                                       02300000
         L     R15,=AL4(RSNAP)         * Retrieve entry-point of RSNAP  02310000
         BASR  R14,R15                 * Call the RSNAP-routine         02320000
         LTR   R15,R15                 * Error in RSNAP ??              02330000
         AIF   (&ERR).ESNAPER                                           02340000
         BE    *+14                    * No: skip error handling        02350000
         OI    UASTAT,UASNAPER         * Indicate snap is in error      02360000
         L     R3,=AL4(ERROR)          * Load address of error handler  02370000
         BASR  R14,R3                  * Issue error, then return here  02380000
*                                                                       02390000
         MEXIT ,                       * Macro complete                 02400000
*                                                                       02410000
.ESNAPER ANOP  ,                       * Snap error in error-handler    02420000
         BE    *+16                    * No: skip error handling        02430000
         OI    UASTAT,UASNAPER         * Indicate snap is in error      02440000
         L     R14,UAERRSAV            * Reload original return address 02450000
         B     ERROR                   * Restart error handler          02460000
*                                                                       02470000
.ESNAP   ANOP                                                           02480000
         MEND                                                           02490000
*                                                                       02500000
         EJECT                                                          02510000
         PRINT NOGEN                                                    02520000
*                                                                       02530000
* Register equates                                                      02540000
*                                                                       02550000
R0       EQU   0                       * Work register                  02560000
R1       EQU   1                       * Work register                  02570000
R2       EQU   2                       * Work register                  02580000
R3       EQU   3                       * Base register                  02590000
R4       EQU   4                       * Pointer to parameter area      02600000
R5       EQU   5                       * Pointer to current FDB         02610000
R6       EQU   6                       *                                02620000
R7       EQU   7                       *                                02630000
R8       EQU   8                       *                                02640000
R9       EQU   9                       *                                02650000
R10      EQU   10                      *                                02660000
R11      EQU   11                      * Data-area ptr (constants etc.) 02670000
R12      EQU   12                      * Reserved for pli-environment   02680000
R13      EQU   13                      * USERAREA pointer (see note)    02690000
R14      EQU   14                      * Return address                 02700000
R15      EQU   15                      * Entry point addr / return code 02710000
*                                                                       02720000
* Note: Since the save-area is placed first in the user-data area       02730000
*       R13 is a pointer to both of these areas.                        02740000
*                                                                       02750000
         SPACE 3                                                        02760000
*                                                                       02770000
* The global &DBG controls debug/nodebug assembling options             02780000
* - when &dbg = 1 then debugging is active.                             02790000
* The global &opt controls optimization.                                02800000
* - when &opt = 1 then full optimization takes place.                   02810000
* - when &opt = 0 then full fault tolerance will be generated.          02820000
*                                                                       02830000
         GBLB  &DBG,&OPT                                                02840000
* Check &SYSPARM to set &DBG and &OPT                                   02850000
         CHECKPRM                                                       02860000
*                                                                       02870000
         GBLB  &ERR                                                     02880000
&ERR     SETB  0                       * Not assembling error-routine   02890000
*                                                                       02900000
         SPACE 3                                                        02910000
*                                                                       02920000
         GBLA  &NOOFFDB,&AANTFIL,&MAXKEY,&SP                            02930000
&NOOFFDB SETA  8                       * Nr of fdbs to be allocated     02940000
&AANTFIL SETA  6                       * Max. nr of files               02950000
&MAXKEY  SETA  15                      * Length of longest key          02960000
&SP      SETA  17                      * Subpoolnr for storage requests 02970000
* The number 17 was chosen arbitrarily.                                 02980000
* Any number between 1 and 127 will do.                                 02990000
*                                                                       03000000
         SPACE 3                                                        03010000
*                                                                       03020000
* To keep the code reentrant, it is required that we have a workarea    03030000
* where code (to be modified) can be copied, before it is changed.      03040000
* Here we set up a global variable that contains the length we need.    03050000
* Whenever anything is moved into the workarea (uaworkar) make sure     03060000
* that it does not extend beyond the allocated area. If more room is    03070000
* needed for a workarea, increase the &WORKLV variable. If the &WORKLV  03080000
* is changed, always change it to a multiple of 8. Thus correct         03090000
* alignment is ensured for the data fields following the workarea.      03100000
*                                                                       03110000
         GBLA  &WORKLV                 * Var to contain required length 03120000
&WORKLV  SETA  160                     * Greatest length we expect      03130000
*                                                                       03140000
         SPACE 3                                                        03150000
*                                                                       03160000
         GBLC  &PRT                    * Controls print option          03170000
&PRT     SETC  'NOGEN'                 * Nogen is default               03180000
         AIF   (NOT &DBG).NOGEN        * When debugging then            03190000
&PRT     SETC  'GEN'                   *   generate full listing        03200000
.NOGEN   ANOP                                                           03210000
         PRINT &PRT                    * Set print option               03220000
*                                                                       03230000
         EJECT                                                          03240000
*                                                                       03250000
* Setup save area, and establish addressability. For a save-area        03260000
* storage must be obtained from the system. The address of this         03270000
* private save-area is saved for subsequent calls.                      03280000
*                                                                       03290000
BXAIO00  CSECT                                                          03300000
BXAIO00  AMODE 31                      * 31-bit addressing              03310000
BXAIO00  RMODE 24                      * Residency below 16m            03320000
*                                                                       03330000
PHASE1   EQU   *                                                        03340000
         USING BXAIO00,R15             * R15 assumed base               03350000
         B     BXAIO000                * Branch around text             03360000
         DC    AL1(23),CL23'BXAIO00 &SYSDATE &SYSTIME'                  03370000
CONSTADR DC    AL4(CONST)              * Address of data-area           03380000
BXAIO000 STM   R14,R12,SAVEDR14(R13)   * Save regs of calling module    03390000
         LR    R3,R15                  * Pick up base register          03400000
         DROP  R15                     * Switch from temporary          03410000
         USING PHASE1,R3               * to permanent base register     03420000
*                                                                       03430000
         L     R11,CONSTADR            * Get address of data-area       03440000
         USING CONST,R11               * and establish addressability   03450000
*                                                                       03460000
         XR    R6,R6                   * Provide for hex-zeroes         03470000
*                                                                       03480000
* Obtain address of parameter from caller. If invalid, issue error.     03490000
*                                                                       03500000
         AIF   (&OPT).GOTPARM                                           03510000
         LTR   R1,R1                   * Is a plist given ??            03520000
         BNE   GOTPARM                 * Yes, skip error                03530000
NOPARM   LA    R15,026                 * Indicate error number          03540000
         L     R14,=AL4(EXIT)          * Let error return to exit       03550000
         L     R3,=AL4(ERROR)          * Get address of error handler   03560000
         BR    R3                      * Execute it, then exit          03570000
*                                                                       03580000
GOTPARM  TM    4(R1),X'80'             * Is the 2nd word the last one ? 03590000
         BNO   NOPARM                  * No: argument(s) invalid        03600000
.GOTPARM L     R4,0(R1)                * Get 1st plist element          03610000
         AIF   (&OPT).GOTPRM2                                           03620000
         LA    R4,0(R4)                * Nullify leading bits           03630000
         LTR   R4,R4                   * Is it valid ??                 03640000
         BZ    NOPARM                  * No: go issue error             03650000
.GOTPRM2 ANOP                                                           03660000
         USING DS83PARM,R4             * Use R4 to address parm area    03670000
         USING DSFDB,R5                * Use R5 to address current FDB  03680000
*                                                                       03690000
         L     R2,4(R1)                * Load address of second parm    03700000
         LA    R2,0(R2)                * Remove end-of-plist marker     03710000
         AIF   (&OPT).FASE110                                           03720000
         LTR   R2,R2                   * Is it valid ??                 03730000
         BZ    NOPARM                  * No: go issue error             03740000
*                                                                       03750000
.FASE110 USING DS83PRM2,R2             * Use R2 to address parm 2       03760000
         L     R1,LNSUAPTR             * Get address of USERAREA        03770000
         LTR   R1,R1                   * Is address valid ??            03780000
         BNZ   GOTM                    * If not allocated: get storage  03790000
*                                                                       03800000
         SPACE 3                                                        03810000
*                                                                       03820000
* Since the private save-area-pointer is invalid, this must be the      03830000
* first call. Therefore storage is to be obtained for the USERAREA      03840000
* (including the new save-area). Storage for run-time FDBs is           03850000
* obtained at the same time.                                            03860000
*                                                                       03870000
GETM     GETMAIN RC,                   * Conditional request (register)*03880000
               SP=&SP,                 *  from our private subpool     *03890000
               LV=L'USERAREA           *  for allocating the USERAREA   03900000
         LTR   R15,R15                 * Storage allocated ??           03910000
         BZ    GETMOK                  * Yes: skip error                03920000
         LA    R15,069                 * Load error code                03930000
         L     R14,=AL4(EXIT)          * Let error return to EXIT       03940000
         L     R3,=AL4(ERROR)          * Get address of error handler   03950000
         BR    R3                      * Execute it, then goto exit     03960000
*                                                                       03970000
GETMOK   EQU   *                                                        03980000
         ST    R1,LNSUAPTR             * Save area address              03990000
*                                                                       04000000
         SPACE 3                                                        04010000
*                                                                       04020000
* R1 now points to our private save-area.                               04030000
*                                                                       04040000
GOTM     EQU   *                                                        04050000
         ST    R13,SAVEPREV(R1)        * Set backward pointer           04060000
         C     R6,SAVEPLI(R13)         * PLI uses 1st word of savearea  04070000
         BNE   ENVIRPLI                * For PLI env.: no forward ptr   04080000
         ST    R1,SAVENEXT(R13)        * Set forward ptr (non-PLI env.) 04090000
ENVIRPLI LR    R13,R1                  * Point to new savearea          04100000
         USING DSUSERAR,R13            * Address USERAREA & savearea    04110000
*                                                                       04120000
* In the UAERR routine R11 is used to determine whether R13 points to   04130000
* our own USERAREA or somewhere different. Therefore R11 is to be saved 04140000
* in its proper place. Thus this USERAREA will be recognizable.         04150000
*                                                                       04160000
         ST    R11,SAVEDR11(R13)       * Mark this save-area as our own 04170000
*                                                                       04180000
* Copy data we will need from parm 2 to the USERAREA                    04190000
*                                                                       04200000
         LCLC  &LM                     * Length modifier                04210000
&LM      SETC  'L''UASELECT'           * Default: full length           04220000
         AIF   (NOT &OPT).FASE120      * When optimizing:               04230000
&LM      SETC  '&AANTFIL'              *  copy only the needed bytes    04240000
.FASE120 MVC   UASELECT(&LM),LNSFILES  * Logical data-group selectors   04250000
         MVC   UAVERSI,LNSVERSI        * Parameter 1 version nr         04260000
         DROP  R2                      * End addressability to ds83prm2 04270000
*                                                                       04280000
         SPACE 3                                                        04290000
*                                                                       04300000
* Increment call-count and initialize return- and reasoncode to zero    04310000
*                                                                       04320000
         AIF   (&OPT AND (NOT &DBG)).FASE130                            04330000
         L     R1,UACALLNR             * Retrieve call-count            04340000
         LA    R1,1(R1)                * Increment call-count by one    04350000
         ST    R1,UACALLNR             * Store call-count in USERAREA   04360000
.FASE130 MVI   UARETCD,C'0'            * Set returncode                 04370000
         STH   R6,UAREASN              * Set reasoncode to H'0'         04380000
         MVC   UAKEY,LNSKEY            * Copy key from parm             04390000
*                                                                       04400000
         SPACE 3                                                        04410000
*                                                                       04420000
* Check select/deselect codes for each logical file section             04430000
*                                                                       04440000
         AIF   (&OPT).FASE140                                           04450000
         LA    R7,UASELECT             * First byte to be checked       04460000
         LA    R8,1                    * Increment value for loop       04470000
         LA    R9,UASELECT+L'UASELECT-1 * Last byte to be checked       04480000
LOOP0    CLI   0(R7),C'0'              * Valid deselect code ??         04490000
         BE    LOOP0NX                 * Yes: check next selector       04500000
         CLI   0(R7),C'1'              * Valid select code ??           04510000
         BE    LOOP0NX                 * Yes: check next selector       04520000
         LA    R15,003                 * Load error message nr          04530000
         L     R3,=AL4(ERROR)          * Get address of error handler   04540000
         BASR  R14,R3                  * Execute it, then continue      04550000
         MVI   0(R7),C'0'              * Default to deselect section    04560000
LOOP0NX  BXLE  R7,R8,LOOP0             * Loop to try next selector      04570000
*                                                                       04580000
.FASE140 ANOP                                                           04590000
*                                                                       04600000
* First we must map the individual requests for logical file sections   04610000
* (UASELECT) onto physical file requests (UAFILES).                     04620000
* Mapping is now 1 to 1, but this may be changed in future.             04630000
* The bytes of UAFILES must always correspond 1 to 1 with the           04640000
* FDBNR field of each FDB in the FDB-chain. If two files are always     04650000
* to be treated identically then they should be given the same value    04660000
* for their FDBNR-fields.                                               04670000
*                                                                       04680000
         AIF   (NOT &OPT).MAPPIN0                                       04690000
         MVC   UAFILES(&LM),UASCCDI    * Copy options (XLATE = 1 to 1)  04700000
         AGO   .MAPPINX                                                 04710000
*                                                                       04720000
.MAPPIN0 ANOP                                                           04730000
MAPPING0 MVC   UAFILES(&LM),=&NOOFFDB.C'0' * Prefill with zeroes        04740000
         CLI   UASCCDI,C'1'            * 1st logical section requested? 04750000
         BNE   MAPPING1                * No                             04760000
         MVI   UAFILES+0,C'1'          * Map section 1 to FDBNR 0       04770000
*                                                                       04780000
MAPPING1 CLI   UASCPDI,C'1'            * 2nd logical section requested? 04790000
         BNE   MAPPING2                * No                             04800000
         MVI   UAFILES+1,C'1'          * Map section 2 to FDBNR 1       04810000
*                                                                       04820000
MAPPING2 CLI   UASCCXI,C'1'            * 3rd logical section requested? 04830000
         BNE   MAPPING3                * No                             04840000
         MVI   UAFILES+2,C'1'          * Map section 3 to FDBNR 2       04850000
*                                                                       04860000
MAPPING3 CLI   UASPDDI,C'1'            * 4th logical section requested? 04870000
         BNE   MAPPING4                * No                             04880000
         MVI   UAFILES+3,C'1'          * Map section 4 to FDBNR 3       04890000
*                                                                       04900000
MAPPING4 CLI   UASCSCI,C'1'            * 5th logical section requested? 04910000
         BNE   MAPPING5                * No                             04920000
         MVI   UAFILES+4,C'1'          * Map section 5 to FDBNR 4       04930000
*                                                                       04940000
MAPPING5 CLI   UASACDI,C'1'            * 6th logical section requested? 04950000
         BNE   MAPPING9                * No                             04960000
         MVI   UAFILES+5,C'1'          * Map section 6 to FDBNR 5       04970000
*                                                                       04980000
MAPPING9 EQU   *                                                        04990000
         AIF   (&OPT).MAPPINX                                           05000000
         CLC   UAFILES,=&NOOFFDB.C'0'  * Still all zeroes ??            05010000
         BNE   MAPPINGX                * No: carry on                   05020000
         LA    R15,004                 * Load error number              05030000
         L     R14,=AL4(EXIT)          * Get return address for error   05040000
         L     R3,=AL4(ERROR)          * Get address of error handler   05050000
         BR    R3                      * Execute it, then goto exit     05060000
*                                                                       05070000
.MAPPINX ANOP                                                           05080000
*                                                                       05090000
MAPPINGX EQU   *                                                        05100000
*                                                                       05110000
         SPACE 3                                                        05120000
*                                                                       05130000
* Phase 1 of the program is now done. Change base register for phase 2  05140000
*                                                                       05150000
         L     R3,=AL4(PHASE2)         * Load address of next phase     05160000
         AIF   (&OPT).FASE1ND                                           05170000
         BR    R3                      * And go execute it              05180000
*                                                                       05190000
.FASE1ND DROP  R3                      * End of phase 1                 05200000
FASE1END EQU   *                                                        05210000
*                                                                       05220000
         EJECT                                                          05230000
         USING PHASE2,R3                                                05240000
PHASE2   EQU   *                                                        05250000
*                                                                       05260000
* Now the mapping from logical data groups in the parameter onto        05270000
* physical VSAM files has taken place, the function code in the         05280000
* parameter is to be translated into request bits in the FDBREQ field   05290000
* of each file concerned. This is done by checking the function code    05300000
* against a table of supported function codes. The table also contains  05310000
* for each supported function code the address of a checking routine.   05320000
*                                                                       05330000
* Now run-time FDBs have been set up. Before we can set them according  05340000
* to the current request we must look up the requested function code in 05350000
* the table of supported opcodes.                                       05360000
*                                                                       05370000
         L     R7,=AL4(OPCODES)        * Starting address of table      05380000
         LA    R8,L'OPC                * Length of each element         05390000
         L     R9,=AL4(OPCODEND)       * Ending address of table        05400000
         USING DSOPC,R7                * Address table by DSECT         05410000
LOOP1    CLC   LNSFCODE,OPCFCOD        * Is it this element ??          05420000
         BE    LOOP1EX                 * Yes: terminate inner loop      05430000
         BXLE  R7,R8,LOOP1             * Try next element               05440000
*                                      * No valid function-code found   05450000
         B     LOOP250                 * Skip to exit handling for err  05460000
LOOP1EX  EQU   *                       * Seek opcode is now done        05470000
         ST    R7,UAOPCADR             * Save address in userarea       05480000
*                                                                       05490000
         AIF   (&OPT).LOOPA                                             05500000
*                                                                       05510000
* FDBs are to be generated on first call                                05520000
*                                                                       05530000
         CLC   UAFDBPTR,=F'0'          * FDBs allocated ??              05540000
         BE    LOOPA                   * No: go force allocation        05550000
.LOOPA   ANOP                                                           05560000
*                                                                       05570000
         TM    OPCMASK,FDBOPEN         * Is this an open-request ??     05580000
         BNO   LOOP2INI                * No: go initiate loop 2         05590000
*                                                                       05600000
* An open request is to be processed. Allocate run-time FDBs            05610000
* from the defaults chain when necessary.                               05620000
*                                                                       05630000
LOOPA    LA    R5,=AL4(CCDFDB)         * Point to root of default FDBs  05640000
LOOPA1   L     R5,FDBNEXT              * Get next default FDB           05650000
         LTR   R5,R5                   * Is it valid ??                 05660000
         BZ    LOOP2INI                * No: we're done                 05670000
         AIF   (NOT &OPT).LOOPA1                                        05680000
*                                                                       05690000
* Optimized version is to check whether the FDB is to be opened.        05700000
* If not, then it should not be allocated. In test version              05710000
* however, all FDBs are to be allocated, or no errors will be           05720000
* generated for calls against unopened files.                           05730000
*                                                                       05740000
         XR    R1,R1                   * Clear register                 05750000
         IC    R1,FDBNR                * to contain FDB-group-number    05760000
         LA    R6,UAFILES(R1)          * Get addr of file group switch  05770000
         CLI   0(R6),C'1'              * Switch is on ??                05780000
         BNE   LOOPA1                  * No: try next default FDB       05790000
.LOOPA1  ANOP                                                           05800000
*                                                                       05810000
* This FDB is to be activated. If no runtime-fdb exists, then a         05820000
* new one will have to be allocated.                                    05830000
*                                                                       05840000
         AIF   (&OPT).LOOPA2                                            05850000
         L     R10,=AL4(SEEKSPC)       * Get address of seekspace table 05860000
         LA    R6,FDBDDNAM             * Point DDNAME in default FDB    05870000
         TRT   FDBDDNAM,0(R10)         * Find addr of first blank       05880000
         BNZ   LOOPA105                * If no spaces, use full length  05890000
         LA    R1,L'FDBDDNAM(R6)       * Point beyond DDNAME            05900000
LOOPA105 SR    R1,R6                   * Used length of DDNAME          05910000
         BCTR  R1,R0                   * Decrement count by one for CLC 05920000
*                                                                       05930000
.LOOPA2  LA    R9,UAFDBPTR             * Point to root of FDBs          05940000
LOOPA2   L     R10,0(R9) =FDBNEXT      * Point to next FDB              05950000
         LTR   R10,R10                 * Is it valid ??                 05960000
         BZ    LOOPA2EX                * No: exit                       05970000
         LR    R9,R10                  * Copy address of next FDB       05980000
         AIF   (&OPT).LOOPA21                                           05990000
         EX    R1,LOOPACLC             * Compare DDNAMEs                06000000
         AGO   .LOOPA22                                                 06010000
*                                                                       06020000
.LOOPA21 CLC   FDBDDLOC(3,R9),FDBDDNAM * DDNAME base is three chars     06030000
.LOOPA22 BNE   LOOPA2                  * Not =: try next default FDB    06040000
         B     LOOPA1                  * Equal: dont allocate a new FDB 06050000
*                                                                       06060000
LOOPA2EX EQU   *                       * Allocate new FDB               06070000
         GETMAIN RC,                   * Conditional storage request   *06080000
               SP=&SP,                 *    from our own subpool       *06090000
               LV=L'FDB                *    for allocating an FDB       06100000
         LTR   R15,R15                 * Storage allocated ??           06110000
         BZ    LOOPA120                * Yes: add it to the chain       06120000
         LA    R15,069                 * Set error code                 06130000
         L     R14,=AL4(EXIT)          * Get return addr for error rout 06140000
         L     R3,=AL4(ERROR)          * Get address of error handler   06150000
         BR    R3                      * And execute it                 06160000
*                                                                       06170000
LOOPA120 MVC   0(L'FDB,R1),FDB         * Copy default FDB to new area   06180000
         MVC   0(4,R1),0(R9) = FDBNEXT * Copy next-ptr from prev FDB    06190000
         ST    R1,0(R9)      = FDBNEXT * Let prev FDB point to new one  06200000
         AIF   (&OPT).LOOP2IN                                           06210000
         B     LOOPA1                  * Check remaining default FDBs   06220000
*                                                                       06230000
LOOPACLC CLC   FDBDDLOC(0,R9),FDBDDNAM * Compare DDNAME with default    06240000
*                                                                       06250000
         SPACE 3                                                        06260000
.LOOP2IN ANOP                                                           06270000
*                                                                       06280000
* Now that we have the opcode-element to be used we must loop           06290000
* through all run-time FDBs. Use their FDBNR-value as an index          06300000
* in UAFILES to determine whether this file is to be processed for      06310000
* the current request. If it is to be processed, set the FDBREQ-bits    06320000
* to indicate the actions phase 3 is to take.                           06330000
*                                                                       06340000
LOOP2INI LA    R5,UAFDBPTR             * Point to entry of FDB-chain    06350000
LOOP2    L     R5,FDBNEXT              * Make next FDB the current one  06360000
         LTR   R5,R5                   * Does it point to nowhere ??    06370000
         BZ    LOOP2EX                 * If no next FDB, then exit loop 06380000
         MVI   FDBREQ,FDBNOREQ         * Reset all request bits         06390000
         MVI   FDBRETCD,X'00'          * Reset returncode to zero       06400000
         XR    R1,R1                   * Clear register                 06410000
         STH   R1,FDBREASN             * Reset reasoncode for this FDB  06420000
         IC    R1,FDBNR                * Load relative file nr to use   06430000
         LA    R6,UAFILES(R1)          * Point to file switch           06440000
         CLI   0(R6),C'1'              * Indicator in parm = 1 ??       06450000
         BNE   LOOP2                   * No: go try next one            06460000
*                                                                       06470000
* Set the request bits associated with this opcode. If a checking       06480000
* routine is specified for the opcode, execute it.                      06490000
*                                                                       06500000
         OC    FDBREQ,OPCMASK          * Set request bits               06510000
LOOP250  L     R8,OPCROUT              * Get exit routine address       06520000
         AIF   (&OPT).LOOP210                                           06530000
         LTR   R8,R8                   * Check on zero                  06540000
         BZ    LOOP2                   * If zero, skip execution        06550000
.LOOP210 BASR  R14,R8                  * Go execute exit routine        06560000
         L     R7,UAOPCADR             * Reload opcode-element address  06570000
         B     LOOP2                   * And go try next FDB            06580000
*                                                                       06590000
LOOP2EX  EQU   *                                                        06600000
*                                                                       06610000
         SPACE 3                                                        06620000
*                                                                       06630000
* Phase 2 is now done. Go proceed to phase 3.                           06640000
*                                                                       06650000
         L     R3,=AL4(PHASE3)         * Get entry point of next phase  06660000
         BR    R3                      * And go execute it              06670000
*                                                                       06680000
         EJECT                                                          06690000
*                                                                       06700000
* Checking routines to evalute the validity of the request              06710000
* first are listed the check-routines that combine requests             06720000
* explicitly. These execute the elementary checks that are listed       06730000
* thereafter. The elementary requests may in turn invoke other          06740000
* elementary request checking routines for implicit open requests.      06750000
*                                                                       06760000
         SPACE 3                                                        06770000
*                                                                       06780000
* CHECKSN: request to skip, then to read sequential. The request may    06790000
* imply open input as well. The open request will be forced by the      06800000
* execution of the checksk routine.                                     06810000
*                                                                       06820000
CHECKSN  EQU   *                                                        06830000
         ST    R14,UALV1SAV            * Save return address            06840000
         BAS   R14,CHECKSK             * Execute check-rout for skip    06850000
         L     R14,UALV1SAV            * Retrieve return address        06860000
         B     CHECKRS                 * Execute check-rout for read    06870000
*                                      *         which returns to R14   06880000
*                                                                       06890000
         SPACE 3                                                        06900000
         AIF   (NOT &DBG).CHECKWN      * Allow WN in test mode only     06910000
*                                                                       06920000
* CHECKWN: request to write, then to read either sequential or random.  06930000
* Depending on the random/sequential status different elementary        06940000
* check-routines will be executed. If the file is not open, it does not 06950000
* matter which write-checker is executed: both will generate an abend.  06960000
*                                                                       06970000
CHECKWN  EQU   *                       * Temporarily not supported      06980000
         ST    R14,UALV1SAV            * Save return address            06990000
         TM    FDBSTAT,FDBACRND        * Access is currently random ??  07000000
         BO    CHECKWNR                * Yes: use random check-routines 07010000
         BAS   R14,CHECKWS             * Execute check-rout for skip    07020000
         L     R14,UALV1SAV            * Retrieve return address        07030000
         B     CHECKRS                 * Execute check-rout for read    07040000
*                                      *         which returns to R14   07050000
*                                                                       07060000
* For a random WN-operation we must juggle the key values, otherwise    07070000
* either the write will detect a key mismatch or the read will read     07080000
* the record just written.                                              07090000
*                                                                       07100000
CHECKWNR EQU   *                                                        07110000
         XR    R7,R7                   * Clear register                 07120000
         IC    R7,FDBKEYLV             * to contain key length          07130000
         LA    R8,LNSKEY(R7)           * Load address of data area      07140000
         BCTR  R7,R0                   * Decrement length by 1 for MVCs 07150000
         EX    R7,CHECKMV1             * Save key for read operation    07160000
         EX    R7,CHECKMV2             * Copy key of current record     07170000
         BAS   R14,CHECKWR             * Execute check-rout for write   07180000
*                                                                       07190000
* Reset key in parameter to reflect the value to be used for reading    07200000
*                                                                       07210000
         XR    R7,R7                   * Clear register                 07220000
         IC    R7,FDBKEYLV             * to contain key length          07230000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  07240000
         EX    R7,CHECKMV3             * Reset key for read operation   07250000
         BAS   R14,CHECKRR             * Execute check-rout for read    07260000
*                                                                       07270000
* Before exiting the key of the parm must be set to match the one in    07280000
* the record because the write will be executed first.                  07290000
*                                                                       07300000
         XR    R7,R7                   * Clear register                 07310000
         IC    R7,FDBKEYLV             * to contain key length          07320000
         LA    R8,LNSKEY(R7)           * Load address of data area      07330000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  07340000
         EX    R7,CHECKMV2             * Copy key of current record     07350000
         L     R14,UALV1SAV            * Retrieve return address        07360000
         BR    R14                     * Return to mainline of phase2   07370000
*                                                                       07380000
.CHECKWN ANOP                                                           07390000
*                                                                       07400000
         SPACE 3                                                        07410000
         AIF   (NOT &DBG).CHECKDN      * Allow DN in test mode only     07420000
*                                                                       07430000
* CHECKDN: request to delete, then to read either sequential or random. 07440000
* Depending on the random/sequential status different elementary        07450000
* check-routines will be executed. If the file is not open, the         07460000
* delete-checker will generate an abend.                                07470000
*                                                                       07480000
CHECKDN  EQU   *                       * Temporarily not supported      07490000
         ST    R14,UALV1SAV            * Save return address            07500000
         TM    FDBSTAT,FDBACRND        * Access is currently random ??  07510000
         BO    CHECKDNR                * Yes: use random check-routines 07520000
         BAS   R14,CHECKDR             * Execute check-rout for delete  07530000
         L     R14,UALV1SAV            * Retrieve return address        07540000
         B     CHECKRS                 * Execute check-rout for read    07550000
*                                      *         which returns to R14   07560000
*                                                                       07570000
* For a random DN-operation we must juggle the key values, otherwise    07580000
* either the delete will detect a key mismatch or the read will find    07590000
* a deleted record.                                                     07600000
*                                                                       07610000
CHECKDNR EQU   *                                                        07620000
         XR    R7,R7                   * Clear register                 07630000
         IC    R7,FDBKEYLV             * to contain key length          07640000
         LA    R8,LNSKEY(R7)           * Load address of data area      07650000
         BCTR  R7,R0                   * Decrement length by 1 for MVCs 07660000
         EX    R7,CHECKMV1             * Save key for read operation    07670000
         EX    R7,CHECKMV2             * Copy key of current record     07680000
         BAS   R14,CHECKDR             * Execute check-rout for delete  07690000
*                                                                       07700000
* Reset key in parameter to reflect the value to be used for reading    07710000
*                                                                       07720000
         XR    R7,R7                   * Clear register                 07730000
         IC    R7,FDBKEYLV             * to contain key length          07740000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  07750000
         EX    R7,CHECKMV3             * Reset key for read operation   07760000
         BAS   R14,CHECKRR             * Execute check-rout for read    07770000
*                                                                       07780000
* Before exiting the key of the parm must be set to match the one in    07790000
* the record because the delete will be executed first.                 07800000
*                                                                       07810000
         XR    R7,R7                   * Clear register                 07820000
         IC    R7,FDBKEYLV             * to contain key length          07830000
         LA    R8,LNSKEY(R7)           * Load address of data area      07840000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  07850000
         EX    R7,CHECKMV2             * Copy key of current record     07860000
         L     R14,UALV1SAV            * Retrieve return address        07870000
         BR    R14                     * Return to mainline of phase2   07880000
*                                                                       07890000
.CHECKDN ANOP                                                           07900000
*                                                                       07910000
         SPACE 3                                                        07920000
*                                                                       07930000
* CHECKOI: to open the file for input, it must be currently closed.     07940000
* If it is open, then a warning is issued. In the process of            07950000
* opening a read of the version control record is to be enforced.       07960000
* The required FDBREQ-bits are set, but the key must be set to zeroes.  07970000
*                                                                       07980000
CHECKOI  EQU   *                       * Open input request             07990000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            08000000
         BNO   CHECKOX                 * No: set key for version record 08010000
         NI    FDBREQ,FDBNOOI          * Reset open input request bit   08020000
         TM    FDBSTAT,FDBUPDAT        * Is the file open for update ?? 08030000
         BNO   CHECKOI2                * No: go issue warning           08040000
         LA    R15,019                 * Load error nr                  08050000
         L     R3,=AL4(ERROR)          * Get address of error handler   08060000
         BR    R3                      * Execute it, return to caller   08070000
*                                                                       08080000
CHECKOI2 LA    R15,005                 * Load error nr                  08090000
         L     R3,=AL4(ERROR)          * Get address of error handler   08100000
         BR    R3                      * Execute it, return to caller   08110000
*                                                                       08120000
         SPACE 3                                                        08130000
*                                                                       08140000
* CHECKOU: to open the file for update, it must be currently closed.    08150000
* If it is open, then a warning is issued. This routine is executed     08160000
* only for explicit open-update requests.                               08170000
*                                                                       08180000
CHECKOU  EQU   *                       * Open update request            08190000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            08200000
         BNO   CHECKOX                 * No: set key for version record 08210000
         NI    FDBREQ,FDBNOOU          * Reset open update request bits 08220000
         TM    FDBSTAT,FDBUPDAT        * Is the file open for update ?? 08230000
         BO    CHECKOU8                * Yes: go issue warning          08240000
         LA    R15,030                 * Load error nr                  08250000
         L     R3,=AL4(ERROR)          * Get address of error handler   08260000
         BR    R3                      * Execute it, return to caller   08270000
*                                                                       08280000
CHECKOU8 LA    R15,005                 * Load error nr                  08290000
         L     R3,=AL4(ERROR)          * Get address of error handler   08300000
         BR    R3                      * Execute it, return to caller   08310000
*                                                                       08320000
         SPACE 3                                                        08330000
*                                                                       08340000
* CHECKOX routine contains coding for both open-checking routines.      08350000
*                                                                       08360000
CHECKOX  MVC   UAKEY,FDBLKEY           * Copy key of version record     08370000
         XC    UALRECAD,UALRECAD       * Set compare record addr to 0   08380000
         XC    UALRECLV,UALRECLV       * Set compare record length to 0 08390000
         CLI   UAKEY,X'FF'             * First byte of version key ok?? 08400000
         BNE   CHECKOX3                * Yes: continue                  08410000
         NI    FDBREQ,FDBNORX          * Reset read request             08420000
         MVC   UAKEY,=&MAXKEY.C'0'     * And reset start-key to zeroes  08430000
*                                                                       08440000
CHECKOX3 EQU   *                                                        08450000
         TM    FDBREQ,FDBOPRND         * Open is random ??              08460000
         BO    CHECKOX5                * Yes: go read if necessary      08470000
         TM    FDBREQ,FDBREAD          * Read required ??               08480000
         BO    CHECKSN                 * Yes: execute skip-read checker 08490000
         B     CHECKSK                 * No: execute skip-checker       08500000
*                                                                       08510000
CHECKOX5 TM    FDBREQ,FDBREAD          * Read required ??               08520000
         BO    CHECKRR                 * Y: execute read random checker 08530000
         BR    R14                     * No: accept open request        08540000
*                                                                       08550000
         SPACE 3                                                        08560000
*                                                                       08570000
* CHECKSK: to skip to a position in the file, it must be open for       08580000
* sequential processing. For skipping at least the first four digits    08590000
* of the key must be valid.                                             08600000
*                                                                       08610000
CHECKSK  EQU   *                       * Skip request                   08620000
         L     R10,=AL4(NUMTAB)        * Get addr of TRT-table for key  08630000
         TRT   UAKEY(4),0(R10)         * Check that key is numeric      08640000
         BZ    CHECKSK2                * Yes: skip the error            08650000
         NI    FDBREQ,FDBNOSK          * Reset skip request bit         08660000
         LA    R15,037                 * Load error nr                  08670000
         L     R3,=AL4(ERROR)          * Get address of error handler   08680000
         BR    R3                      * Execute it, return to caller   08690000
*                                                                       08700000
CHECKSK2 EQU   *                                                        08710000
         AIF   (&OPT).CHEKSK3          * Optimized mode: always open    08720000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            08730000
         BO    CHECKSK3                * Yes: skip error                08740000
         TM    FDBREQ,FDBOPEN          * Is file to be opened ??        08750000
         BO    CHECKSK3                * Yes: skip error                08760000
         NI    FDBREQ,FDBNOSK          * Reset skip-request bit         08770000
         LA    R15,031                 * Load error nr                  08780000
         L     R3,=AL4(ERROR)          * Get address of error handler   08790000
         BR    R3                      * Execute it, return to caller   08800000
*                                                                       08810000
.CHEKSK3 ANOP                                                           08820000
*                                                                       08830000
CHECKSK3 TM    FDBSTAT,FDBACRND        * File is open, is sequential ?? 08840000
         BNOR  R14                     * Yes: accept SK-request         08850000
         NI    FDBREQ,FDBNOSK          * Reset skip-request bit         08860000
         LA    R15,036                 * Load error number              08870000
         L     R3,=AL4(ERROR)          * Get address of error handler   08880000
         BR    R3                      * Execute it, return to caller   08890000
*                                                                       08900000
         SPACE 3                                                        08910000
*                                                                       08920000
* CHECKRS: to read a record sequentially, the file must be open for     08930000
* sequential processing. Reading past end of file will cause a          08940000
* warning message to be issued, and the request to be ignored.          08950000
*                                                                       08960000
CHECKRS  EQU   *                       * Read sequential request        08970000
         AIF   (&OPT).CHEKRS5          * Optimized: file always open    08980000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            08990000
         BO    CHECKRS5                * Yes: skip this error           09000000
         TM    FDBREQ,FDBOPEN          * Is file to be opened ??        09010000
         BNO   CHECKRS2                * No: issue error                09020000
         TM    FDBREQ,FDBOPRND         * Open random request ??         09030000
         BNOR  R14                     * No: ok, yes: error             09040000
*                                                                       09050000
CHECKRS2 NI    FDBREQ,FDBNORX          * Reset read request bit         09060000
         LA    R15,032                 * Load error nr                  09070000
         L     R3,=AL4(ERROR)          * Get address of error handler   09080000
         BR    R3                      * Execute it, return to caller   09090000
*                                                                       09100000
.CHEKRS5 ANOP                                                           09110000
*                                                                       09120000
CHECKRS5 EQU   *                                                        09130000
         TM    FDBSTAT,FDBACRND        * Access is random ??            09140000
         BNO   CHECKRS6                * No: go check EOF-condition     09150000
         ST    R14,UALV2SAV            * Save return address            09160000
         LA    R15,007                 * Load error number              09170000
         L     R3,=AL4(ERROR)          * Get address of error handler   09180000
         BASR  R14,R3                  * Execute it, then return here   09190000
         L     R14,UALV2SAV            * Reload correct return address  09200000
         B     CHECKRR                 * And default to read random     09210000
*                                                                       09220000
CHECKRS6 TM    FDBSTAT,FDBEOF          * End-of-file condition raised?? 09230000
         BNOR  R14                     * No: accept RS-request          09240000
         TM    FDBREQ,FDBSKIP          * Was a skip requested as well ? 09250000
         BOR   R14                     * Yes: accept RS-request         09260000
         NI    FDBREQ,FDBNORX          * Reset read request             09270000
         LA    R15,038                 * Load error nr                  09280000
         L     R3,=AL4(ERROR)          * Get address of error handler   09290000
         BR    R3                      * Execute it, return to caller   09300000
*                                                                       09310000
         SPACE 3                                                        09320000
*                                                                       09330000
* CHECKRR: to read a record randomly, the file must be open for         09340000
* random processing, and the full key must be given.                    09350000
*                                                                       09360000
CHECKRR  EQU   *                       * Read random request            09370000
         L     R10,=AL4(NUMTAB)        * Get addr of TRT-table for key  09380000
         XR    R7,R7                   * Clear register                 09390000
         IC    R7,FDBKEYLV             * to contain length of key       09400000
         BCTR  R7,R0                   * Decrement by one for TRT       09410000
         EX    R7,CHECKTRT             * Check that key is numeric      09420000
         BZ    CHECKRR2                * Yes: skip the error            09430000
         NI    FDBREQ,FDBNORX          * Reset read request bit         09440000
         LA    R15,039                 * Load error nr                  09450000
         L     R3,=AL4(ERROR)          * Get address of error handler   09460000
         BR    R3                      * Execute it, return to caller   09470000
*                                                                       09480000
* Optimized version cannot skip open checking: when the file is not     09490000
* open yet, the FDBACRND-bit still is zero, causing an erroneous        09500000
* error 008 on any call with opcode RI or RU.                           09510000
*                                                                       09520000
CHECKRR2 EQU   *                                                        09530000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            09540000
         BO    CHECKRR4                * Yes: skip error                09550000
         TM    FDBREQ,FDBOPEN          * Is file to be opened ??        09560000
         BNO   CHECKRR3                * Yes: skip error                09570000
         TM    FDBREQ,FDBOPRND         * Is file to be opened random ?? 09580000
         BOR   R14                     * Yes: accept the request        09590000
*                                                                       09600000
CHECKRR3 NI    FDBREQ,FDBNORX          * Reset read-request bit         09610000
         LA    R15,032                 * Load error nr                  09620000
         L     R3,=AL4(ERROR)          * Get address of error handler   09630000
         BR    R3                      * Execute it, return to caller   09640000
*                                                                       09650000
CHECKRR4 TM    FDBSTAT,FDBACRND        * Is it open for random ??       09660000
         BOR   R14                     * Yes: accept the request        09670000
         ST    R14,UALV2SAV            * Save return address            09680000
         LA    R15,008                 * Load error number              09690000
         L     R3,=AL4(ERROR)          * Get address of error handler   09700000
         BASR  R14,R3                  * Execute it, then return here   09710000
         L     R14,UALV2SAV            * Reload original return address 09720000
         B     CHECKRS                 * Try to read sequantial         09730000
*                                                                       09740000
         SPACE 3                                                        09750000
*                                                                       09760000
* CHECKWS: to rewrite a record sequentially, the file must be open      09770000
* for update in sequential mode, and the record to be updated must      09780000
* have been read just before the write request.                         09790000
*                                                                       09800000
CHECKWS  EQU   *                       * Write sequential request       09810000
         TM    FDBSTAT,FDBACRND        * Access is random ??            09820000
         BNO   CHECKWX                 * No: skip this error            09830000
         ST    R14,UALV2SAV            * Save return address            09840000
         LA    R15,009                 * Load error nr                  09850000
         L     R3,=AL4(ERROR)          * Get address of error handler   09860000
         BASR  R14,R3                  * Execute it, then return here   09870000
         L     R14,UALV2SAV            * Reload return address          09880000
         B     CHECKWX                 * Default to 'WR'-processing     09890000
*                                                                       09900000
         SPACE 3                                                        09910000
*                                                                       09920000
* CHECKWR: to rewrite a record randomly, the file must be open          09930000
* for update in random mode, and the record to be updated must          09940000
* have been read just before the write request.                         09950000
*                                                                       09960000
CHECKWR  EQU   *                       * Write random request           09970000
         TM    FDBSTAT,FDBACRND        * Access is random ??            09980000
         BO    CHECKWX                 * Yes: skip this error           09990000
         ST    R14,UALV2SAV            * Save return address            10000000
         LA    R15,010                 * Load error nr                  10010000
         L     R3,=AL4(ERROR)          * Get address of error handler   10020000
         BASR  R14,R3                  * Execute it, then return here   10030000
         L     R14,UALV2SAV            * Reload return address          10040000
*                                      * And default to 'WS'-processing 10050000
         SPACE 3                                                        10060000
*                                                                       10070000
* CHECKWX: to rewrite a record, whether random or sequential, it is     10080000
* required that the record to be updated has been read just before      10090000
* the write request. this checking is done here for both modes.         10100000
*                                                                       10110000
CHECKWX  EQU   *                                                        10120000
         TM    FDBSTAT,FDBUPDAT        * Is the file open for update ?? 10130000
         BO    CHECKWX1                * Yes: skip this error           10140000
         NI    FDBREQ,FDBNOWX          * Reset write request bit        10150000
         LA    R15,033                 * Load error nr                  10160000
         L     R3,=AL4(ERROR)          * Get address of error handler   10170000
         BR    R3                      * Execute it, return to caller   10180000
*                                                                       10190000
CHECKWX1 TM    FDBLREQ,FDBREAD         * Previous operation was read ?? 10200000
         BO    CHECKWX2                * Yes: skip this error           10210000
         NI    FDBREQ,FDBNOWX          * Reset write request bit        10220000
         LA    R15,041                 * Load error nr                  10230000
         L     R3,=AL4(ERROR)          * Get address of error handler   10240000
         BR    R3                      * Execute it, return to caller   10250000
*                                                                       10260000
CHECKWX2 TM    FDBSTAT,FDBEOF          * Previous read succcessful??    10270000
         BNO   CHECKWX3                * Yes: skip this error           10280000
         NI    FDBREQ,FDBNOWX          * Reset write request bit        10290000
         LA    R15,041                 * Load error nr                  10300000
         L     R3,=AL4(ERROR)          * Get address of error handler   10310000
         BR    R3                      * Execute it, return to caller   10320000
*                                                                       10330000
CHECKWX3 XR    R7,R7                   * Clear register                 10340000
         IC    R7,FDBKEYLV             * to contain length of key       10350000
         LA    R8,LNSKEY(R7)           * Load start addr of data area   10360000
         BCTR  R7,R0                   * Decrement length by 1 for TRT  10370000
         EX    R7,CHECKCLC             * Check that key is still equal  10380000
         BE    CHECKWX4                * Yes: skip this error           10390000
CHECKWXR NI    FDBREQ,FDBNOWX          * Reset write request bit        10400000
         LA    R15,043                 * Load error nr                  10410000
         L     R3,=AL4(ERROR)          * Get address of error handler   10420000
         BR    R3                      * Execute it, return to caller   10430000
*                                                                       10440000
CHECKWX4 EQU   *                                                        10450000
         EX    R7,CHECKCLK             * Check that keys are equal      10460000
         BER   R14                     * It is ok, accept the request   10470000
         B     CHECKWXR                * Wrong: issue error             10480000
*                                                                       10490000
         SPACE 3                                                        10500000
*                                                                       10510000
* CHECKIR: to insert a record, the file must be open for update.        10520000
* An insert is not required to follow an unsuccessful read.             10530000
* The key, however must be numeric.                                     10540000
*                                                                       10550000
CHECKIR  EQU   *                       * Insert request                 10560000
         L     R10,=AL4(NUMTAB)        * Get addr of TRT-table for key  10570000
         XR    R7,R7                   * Clear register                 10580000
         IC    R7,FDBKEYLV             * to contain length of key       10590000
         LA    R8,LNSKEY(R7)           * Load address of data area      10600000
         BCTR  R7,R0                   * Decrement length by 1 for TRT  10610000
         EX    R7,CHECKTRT             * Check that key is numeric      10620000
         BZ    CHECKIR2                * Ok, then skip the error        10630000
         NI    FDBREQ,FDBNOIR          * Reset insert request bit       10640000
         LA    R15,040                 * Load error nr                  10650000
         L     R3,=AL4(ERROR)          * Get address of error handler   10660000
         BR    R3                      * Execute it, return to caller   10670000
*                                                                       10680000
CHECKIR2 EQU   *                                                        10690000
         EX    R7,CHECKCLK             * Check that keys are equal      10700000
         BE    CHECKIR3                * Ok, then skip the error        10710000
         NI    FDBREQ,FDBNOIR          * Reset insert request bit       10720000
         LA    R15,045                 * Load error nr                  10730000
         L     R3,=AL4(ERROR)          * Get address of error handler   10740000
         BR    R3                      * Execute it, return to caller   10750000
*                                                                       10760000
CHECKIR3 EQU   *                                                        10770000
         EX    R7,CHECKCLZ             * Is this the version record ??  10780000
         BNE   CHECKIR4                * No: ok, skip the error         10790000
         NI    FDBREQ,FDBNOIR          * Reset insert request bit       10800000
         LA    R15,047                 * Load error nr                  10810000
         L     R3,=AL4(ERROR)          * Get address of error handler   10820000
         BR    R3                      * Execute it, return to caller   10830000
*                                                                       10840000
CHECKIR4 TM    FDBSTAT,FDBUPDAT        * Is the file open for update ?? 10850000
         BOR   R14                     * Yes: request is ok             10860000
         NI    FDBREQ,FDBNOIR          * Reset request bit for insert   10870000
         LA    R15,034                 * Load error nr                  10880000
         L     R3,=AL4(ERROR)          * Get address of error handler   10890000
         BR    R3                      * Execute it, return to caller   10900000
*                                                                       10910000
         SPACE 3                                                        10920000
*                                                                       10930000
* CHECKDR: to delete a record, the file must be open for update and     10940000
* the record must have been read just before this delete request.       10950000
*                                                                       10960000
CHECKDR  EQU   *                       * Delete request                 10970000
         TM    FDBSTAT,FDBUPDAT        * Is the file open for update ?? 10980000
         BO    CHECKDR2                * Yes: skip this error           10990000
         NI    FDBREQ,FDBNODR          * Reset delete request bit       11000000
         LA    R15,035                 * Load error nr                  11010000
         L     R3,=AL4(ERROR)          * Get address of error handler   11020000
         BR    R3                      * Execute it, return to caller   11030000
*                                                                       11040000
CHECKDR2 TM    FDBLREQ,FDBREAD         * Previous operation was read ?? 11050000
         BO    CHECKDR3                * Yes: skip this error           11060000
         NI    FDBREQ,FDBNODR          * Reset delete request bit       11070000
         LA    R15,042                 * Load error nr                  11080000
         L     R3,=AL4(ERROR)          * Get address of error handler   11090000
         BR    R3                      * Execute it, return to caller   11100000
*                                                                       11110000
CHECKDR3 TM    FDBSTAT,FDBEOF          * Previous read reached eof ??   11120000
         BNO   CHECKDR4                * No: skip this error            11130000
         NI    FDBREQ,FDBNODR          * Reset delete request bit       11140000
         LA    R15,042                 * Load error nr                  11150000
         L     R3,=AL4(ERROR)          * Get address of error handler   11160000
         BR    R3                      * Execute it, return to caller   11170000
*                                                                       11180000
CHECKDR4 XR    R7,R7                   * Clear register                 11190000
         IC    R7,FDBKEYLV             * to contain length of key       11200000
         LA    R8,LNSKEY(R7)           * Load address of data area      11210000
         BCTR  R7,R0                   * Decrement length by 1 for TRT  11220000
         EX    R7,CHECKCLC             * Check that key is still equal  11230000
         BE    CHECKDR5                * Yes: skip this error           11240000
CHECKDRR NI    FDBREQ,FDBNODR          * Reset delete request bit       11250000
         LA    R15,044                 * Load error nr                  11260000
         L     R3,=AL4(ERROR)          * Get address of error handler   11270000
         BR    R3                      * Execute it, then return        11280000
*                                                                       11290000
CHECKDR5 EQU   *                                                        11300000
         EX    R7,CHECKCLK             * Check that keys are equal      11310000
         BNE   CHECKDRR                * Wrong: issue error             11320000
*                                                                       11330000
CHECKDR6 EQU   *                                                        11340000
         EX    R7,CHECKCLZ             * Is it the version record ??    11350000
         BNER  R14                     * It is ok, accept the request   11360000
         NI    FDBREQ,FDBNODR          * Reset delete request bit       11370000
         LA    R15,048                 * Load error nr                  11380000
         L     R3,=AL4(ERROR)          * Get address of error handler   11390000
         BR    R3                      * Execute it, then return        11400000
*                                                                       11410000
         SPACE 3                                                        11420000
*                                                                       11430000
* CHECKCA: to close the file, it must be open.                          11440000
* If not open, a warning is issued and the request is ignored.          11450000
*                                                                       11460000
CHECKCA  EQU   *                       * Close request                  11470000
         AIF   (&OPT).CHEKCA           * File always open (optimized)   11480000
         TM    FDBSTAT,FDBINPUT        * Is the file open ??            11490000
         BOR   R14                     * Yes: return & continue         11500000
         NI    FDBREQ,FDBNOCA          * Reset close request            11510000
         LA    R15,006                 * Load error nr                  11520000
         L     R3,=AL4(ERROR)          * Get address of error handler   11530000
         BR    R3                      * Execute it, return to caller   11540000
         AGO   .CHEKCA9                                                 11550000
.CHEKCA  ANOP                                                           11560000
         BR    R14                     * Optimized: return immediate    11570000
.CHEKCA9 ANOP                                                           11580000
*                                                                       11590000
         SPACE 3                                                        11600000
         AIF   (NOT &DBG).CHECKSD      * Checksd only in test mode      11610000
*                                                                       11620000
* CHECKSD: no checking is required. A snapdump is produced by calling   11630000
* RSNAP. No further action is required.                                 11640000
*                                                                       11650000
CHECKSD  EQU   *                       * Request to produce a snap-dump 11660000
         ESNAP ,                       * Call RSNAP-routine             11670000
         AIF   (&OPT).CHEKSD5                                           11680000
         L     R3,=AL4(RSETBASE)       * Load new base address          11690000
         L     R14,=AL4(EXIT)          * Take shortcut                  11700000
         BR    R3                      * To end the program             11710000
         AGO   .CHEKSD9                                                 11720000
.CHEKSD5 ANOP                                                           11730000
         L     R3,=AL4(PHASE4)         * Load new base address          11740000
         L     R14,=AL4(EXIT)          * Retrieve address of exit       11750000
         BR    R14                     * Take shortcut                  11760000
.CHEKSD9 ANOP                                                           11770000
*                                                                       11780000
.CHECKSD ANOP                                                           11790000
*                                                                       11800000
         SPACE 3                                                        11810000
*                                                                       11820000
* CHECKXX: routine forces an error since the requested function         11830000
* is not known or not supported.                                        11840000
*                                                                       11850000
CHECKXX  EQU   *                       * Invalid function-code in parm  11860000
         LA    R15,027                 * Load error number              11870000
         L     R14,=AL4(EXIT)          * Get fast exit address          11880000
         L     R3,=AL4(ERROR)          * Get address of error handler   11890000
         BR    R3                      * Execute it, return to exit     11900000
*                                                                       11910000
         SPACE 3                                                        11920000
*                                                                       11930000
CHECKCLC CLC   FDBLKEY(0),0(R8)        * Comp last key with key in parm 11940000
CHECKCLK CLC   UAKEY(0),0(R8)          * Compare keys in parameter      11950000
CHECKCLZ CLC   UAKEY(0),=&MAXKEY.C'0'  * Version record has key zero    11960000
*                                                                       11970000
CHECKTRT TRT   UAKEY(0),0(R10)         * Check that key is numeric      11980000
*                                                                       11990000
CHECKMV1 MVC   FDBXKEY(0),UAKEY        * Save key for read operation    12000000
CHECKMV2 MVC   UAKEY(0),0(R8)          * Cpy key of current rec to parm 12010000
CHECKMV3 MVC   UAKEY(0),FDBXKEY        * Restore key for read operation 12020000
*                                                                       12030000
         SPACE 3                                                        12040000
*                                                                       12050000
         DROP  R3                      * Drop base register for phase 2 12060000
FASE2END EQU   *                                                        12070000
*                                                                       12080000
         EJECT                                                          12090000
         USING PHASE3,R3               * And reestablish addressability 12100000
PHASE3   EQU   *                                                        12110000
*                                                                       12120000
* The FDBREQ field of all FDBs have now been set.                       12130000
* Now we must process the FDBs one by one according to their request    12140000
* bit settings. Thus all requested I/O handlers shall be executed.      12150000
* For asynchronous processing to be effective, it is essential that     12160000
* as many requests overlap as possible. This is achieved by looping     12170000
* through all FDBs for each possible asynchronous request. Thus the     12180000
* requested files will be handled more in parallel, especially with     12190000
* combined opcodes: SN, WN, DN, and get sequential with implied open.   12200000
*                                                                       12210000
* Remarks on optimized coding:                                          12220000
* Since the capability to handle more than one file (FDB) at a time     12230000
* is currently not being used, we need to loop through the FDBs only    12240000
* once. Therefore the repeated loop-logic is skipped when optimizing.   12250000
* While the opcodes WN and DN are not being used (yet), the order       12260000
* of handling the request bits can be changed so that a read-request    12270000
* is recognized earlier. Thus a few unsuccessful compares can be        12280000
* avoided for each read request. Additionally, after executing a        12290000
* request that cannot be followed by another (combined) request         12300000
* we skip to the end of phase3 at once.                                 12310000
*                                                                       12320000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    12330000
LOOP3    L     R5,FDBNEXT              * Make next FDB the current one  12340000
         LTR   R5,R5                   * If it is zero, we're through   12350000
         BZ    LOOP3EX                 * If no next FDB, then exit loop 12360000
         CLI   FDBREQ,FDBNOREQ         * Anything to do for this file ? 12370000
         BE    LOOP3                   * No: try next FDB               12380000
*                                                                       12390000
* If an insert is not requested while the RPL is still in insert        12400000
* status, then the RPL must be reset to normal                          12410000
*                                                                       12420000
         TM    FDBSTAT,FDBRPLIR        * Is RPL in insert mode??        12430000
         BNO   LOOP3E                  * No: skip resetting the RPL     12440000
         TM    FDBREQ,FDBINSRT         * Is insert requested ??         12450000
         BO    LOOP3E                  * Yes: leave the RPL as it is    12460000
         L     R2,FDBRPL               * Retrieve RPL-address           12470000
         LA    R6,FDBREC               * Address of record in buffer    12480000
         MODCB RPL=(R2),               * Reset current RPL from insert *12490000
               AREA=(S,0(R6)),         *  specify the correct data area*12500000
               OPTCD=(UPD,LOC),        *  updating, locate mode        *12510000
               MF=(G,UAWORKAR,MODCNILV) * use UAWORKAR to build plist   12520000
         LTR   R15,R15                 * Modcb was ok ??                12530000
         BZ    LOOP3D                  * Yes: skip error                12540000
         ST    R15,UAVSAMRC            * Save retcode for error handler 12550000
         LA    R15,063                 * Load error number              12560000
         L     R3,=AL4(ERROR)          * Get address of error handler   12570000
         BASR  R14,R3                  * Execute it, then return here   12580000
         B     LOOP3E                  * Skip resetting the RPL-status  12590000
*                                                                       12600000
LOOP3D   NI    FDBSTAT,FDBRPLNI        * Reset RPL-status to non-insert 12610000
*                                                                       12620000
         SPACE 3                                                        12630000
*                                                                       12640000
LOOP3E   EQU   *                                                        12650000
*                                                                       12660000
* Open is to be executed first, because it may have been implied by     12670000
* another request, which can be executed only after opening.            12680000
*                                                                       12690000
         TM    FDBREQ,FDBOPEN          * File is to be opened ??        12700000
         BNO   LOOP3SK                 * No: skip open routine          12710000
         BAS   R14,ROP                 * Execute open routine           12720000
*                                                                       12730000
* Skip is to be executed after open (which may have been implied by     12740000
* a skip request), since a sequential open forces a skip request.       12750000
* Moreover skip should be executed before read, since open (and         12760000
* therefore skip) may have been implied by a read sequential request.   12770000
* Furthermore skip should be executed first, or it shall be impossible  12780000
* to support a combined skip-then-read request.                         12790000
*                                                                       12800000
         PRINT GEN                                                      12810000
         GBLC  &TARGET                 * Target of branch instructions  12820000
&TARGET  SETC  'LOOP3'                 * Normal process: loop thru FDBs 12830000
         AIF   (NOT &OPT).LOOP3SK      * When optimizing, then          12840000
&TARGET  SETC  'LOOPRXT'               * go test read-request           12850000
.LOOP3SK ANOP                                                           12860000
*                                                                       12870000
LOOP3SK  TM    FDBREQ,FDBSKIP          * Skip to specified key ??       12880000
         BNO   &TARGET                 * No: skip skip routine          12890000
         BAS   R14,RSK                 * Execute skip routine           12900000
         B     &TARGET                 * Check next FDB                 12910000
*                                                                       12920000
LOOP3EX  EQU   *                                                        12930000
*                                                                       12940000
         SPACE 3                                                        12950000
*                                                                       12960000
* Write is to be executed before read, or it will be impossible to      12970000
* support a combined write-then-read request.                           12980000
*                                                                       12990000
&TARGET  SETC  'LOOPWX'                * Normal process: loop thru FDBs 13000000
         AIF   (NOT &OPT).LOOPWX       * When optimizing, then          13010000
&TARGET  SETC  'LOOPDRT'               * go test for delete-request     13020000
         AGO   .LOOPWXT                * and omit FDB-loop logic        13030000
.LOOPWX  ANOP                                                           13040000
*                                                                       13050000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    13060000
LOOPWX   L     R5,FDBNEXT              * Make next FDB the current one  13070000
         LTR   R5,R5                   * If it is zero, we're through   13080000
         BZ    LOOPWXEX                * If no next FDB, then exit loop 13090000
*                                                                       13100000
.LOOPWXT ANOP                                                           13110000
LOOPWXT  TM    FDBREQ,FDBWRITE         * Write record specified ??      13120000
         BNO   &TARGET                 * No: skip write routine         13130000
         BAS   R14,RWX                 * Execute write routine          13140000
*                                                                       13150000
         AIF   (NOT &OPT).LOOPWXU      * When optimizing:               13160000
         B     LOOPCAEX                * Skip remainder of phase3       13170000
*                                                                       13180000
.LOOPWXU AIF   (&OPT).LOOPWXX          * Opcode WN only in test mode    13190000
*                                                                       13200000
* If the write operation is to be followed by a read, then the saved    13210000
* key is to be restored into the parameter area.                        13220000
*                                                                       13230000
         TM    FDBREQ,FDBREAD          * Read is to follow this write?? 13240000
         BNO   &TARGET                 * No: continue with next FDB     13250000
         TM    FDBSTAT,FDBACRND        * Access is random ??            13260000
         BNO   &TARGET                 * No: key not required           13270000
         XR    R7,R7                   * Clear register                 13280000
         IC    R7,FDBKEYLV             * to contain key length          13290000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  13300000
         EX    R7,LOOPWXMV             * and restore saved key          13310000
         B     &TARGET                 * Go check next FDB              13320000
*                                                                       13330000
LOOPWXMV MVC   UAKEY(0),FDBXKEY        * Restore extra key into parm    13340000
*                                                                       13350000
.LOOPWXX ANOP                                                           13360000
LOOPWXEX EQU   *                                                        13370000
*                                                                       13380000
         SPACE 3                                                        13390000
*                                                                       13400000
* Delete is to be executed before read, or it will be impossible to     13410000
* support a combined delete-then-read request.                          13420000
*                                                                       13430000
&TARGET  SETC  'LOOPDR'                * Normal process: loop thru FDBs 13440000
         AIF   (NOT &OPT).LOOPDR       * When optimizing, then          13450000
&TARGET  SETC  'LOOPIRT'               * go test for insert-request     13460000
         AGO   .LOOPDRT                * and omit FDB-loop logic        13470000
.LOOPDR  ANOP                                                           13480000
*                                                                       13490000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    13500000
LOOPDR   L     R5,FDBNEXT              * Make next FDB the current one  13510000
         LTR   R5,R5                   * If it is zero, we're through   13520000
         BZ    LOOPDREX                * If no next FDB, then exit loop 13530000
*                                                                       13540000
.LOOPDRT ANOP                                                           13550000
LOOPDRT  TM    FDBREQ,FDBDEL           * Delete record specified ??     13560000
         BNO   &TARGET                 * No: skip delete routine        13570000
         BAS   R14,RDR                 * Execute delete routine         13580000
*                                                                       13590000
         AIF   (NOT &OPT).LOOPDRU      * When optimizing:               13600000
         B     LOOPCAEX                * Proceed to end of phase3       13610000
.LOOPDRU AIF   (&OPT).LOOPDRX          * DN only allowed in test mode   13620000
*                                                                       13630000
* If the delete operation is to be followed by a read, then the saved   13640000
* key is to be restored into the parameter area.                        13650000
*                                                                       13660000
         TM    FDBREQ,FDBREAD          * Read is to follow this write?? 13670000
         BNO   LOOPDR                  * No: continue with next FDB     13680000
         TM    FDBSTAT,FDBACRND        * Access is random ??            13690000
         BNO   LOOPDR                  * No: key not required           13700000
         XR    R7,R7                   * Clear register                 13710000
         IC    R7,FDBKEYLV             * to contain key length          13720000
         BCTR  R7,R0                   * Decrement length by 1 for MVC  13730000
         EX    R7,LOOPDRMV             * and restore saved key          13740000
         B     LOOPDR                  * Go check next FDB              13750000
*                                                                       13760000
LOOPDRMV MVC   UAKEY(0),FDBXKEY        * Restore extra key into parm    13770000
*                                                                       13780000
.LOOPDRX ANOP                                                           13790000
LOOPDREX EQU   *                                                        13800000
*                                                                       13810000
         SPACE 3                                                        13820000
*                                                                       13830000
* Read is to be executed after open, skip, write, and delete since      13840000
* these requests may be either implied or they need to be supported     13850000
* as a combined operation.                                              13860000
*                                                                       13870000
&TARGET  SETC  'LOOPRX'                * Normal process: loop thru FDBs 13880000
         AIF   (NOT &OPT).LOOPRX       * When optimizing, then          13890000
&TARGET  SETC  'LOOPWXT'               * go test for write-request      13900000
         AGO   .LOOPRXT                * and omit FDB-loop logic        13910000
.LOOPRX  ANOP                                                           13920000
*                                                                       13930000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    13940000
LOOPRX   L     R5,FDBNEXT              * Make next FDB the current one  13950000
         LTR   R5,R5                   * If it is zero, we're through   13960000
         BZ    LOOPRXEX                * If no next FDB, then exit loop 13970000
*                                                                       13980000
.LOOPRXT ANOP                                                           13990000
LOOPRXT  TM    FDBREQ,FDBREAD          * Read record specified ??       14000000
         BNO   &TARGET                 * No: skip read routine          14010000
         BAS   R14,RRX                 * Execute read routine           14020000
*                                                                       14030000
         AIF   (&OPT).LOOPRXU          * When optimizing: drop-through  14040000
         B     &TARGET                 * And go check next FDB          14050000
.LOOPRXU ANOP  ,                       * To check for re-read request   14060000
*                                                                       14070000
* If a read request could not be satisfied from the current data buffer 14080000
* then the request bit is set for restart read. A skip request has been 14090000
* started: thus a skip will occur. Subsequently the read will be        14100000
* satisfiable.                                                          14110000
*                                                                       14120000
LOOPRXEX EQU   *                                                        14130000
&TARGET  SETC  'LOOPRYEX'              * Normal process: loop thru FDBs 14140000
         AIF   (NOT &OPT).LOOPRY       * When optimizing, then          14150000
&TARGET  SETC  'LOOPCAEX'              * no more requests to be handled 14160000
.LOOPRY  ANOP                                                           14170000
*                                                                       14180000
         TM    UASTAT,UARQREAD         * Restart read processing ??     14190000
         BNO   &TARGET                 * No: carry on                   14200000
         NI    UASTAT,UARQNORX         * Reset restart request          14210000
*                                                                       14220000
         AIF   (&OPT).LOOPRYX                                           14230000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    14240000
LOOPRY   L     R5,FDBNEXT              * Make next FDB the current one  14250000
         LTR   R5,R5                   * If it is zero, we're through   14260000
         BZ    LOOPRYEX                * If no next FDB, then exit loop 14270000
         TM    FDBREQ,FDBREAD2         * Read record specified ??       14280000
         BNO   LOOPRY                  * No: skip read routine          14290000
.LOOPRYX NI    FDBREQ,FDBNOIR          * Reset reread (=insert) request 14300000
         BAS   R14,RRX                 * And re-execute read routine    14310000
*                                                                       14320000
&TARGET  SETC  'LOOPRY'                * Normal process: loop thru FDBs 14330000
         AIF   (NOT &OPT).LOOPRZ       * When optimizing, then          14340000
&TARGET  SETC  'LOOPCAEX'              * there are no more requests     14350000
.LOOPRZ  ANOP                                                           14360000
         B     &TARGET                 * And go check next FDB          14370000
*                                                                       14380000
LOOPRYEX EQU   *                                                        14390000
*                                                                       14400000
         SPACE 3                                                        14410000
*                                                                       14420000
* Insert is currently not combined with any other request, so we        14430000
* just leave it trailing behind, as the last asynchronous request.      14440000
*                                                                       14450000
&TARGET  SETC  'LOOPIR'                * Normal process: loop thru FDBs 14460000
         AIF   (NOT &OPT).LOOPIR       * When optimizing, then          14470000
&TARGET  SETC  'LOOPCAT'               * go test for close-request      14480000
         AGO   .LOOPIRT                * and omit FDB-loop logic        14490000
.LOOPIR  ANOP                                                           14500000
*                                                                       14510000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    14520000
LOOPIR   L     R5,FDBNEXT              * Make next FDB the current one  14530000
         LTR   R5,R5                   * If it is zero, we're through   14540000
         BZ    LOOPIREX                * If no next FDB, then exit loop 14550000
*                                                                       14560000
.LOOPIRT ANOP   **!!                                                    14570000
LOOPIRT  TM    FDBREQ,FDBINSRT         * Insert record specified ??     14580000
         BNO   &TARGET                 * No: skip insert routine        14590000
         BAS   R14,RIR                 * Execute insert routine         14600000
*                                                                       14610000
         AIF   (NOT &OPT).LOOPIRU      * When optimizing:               14620000
&TARGET  SETC  'LOOPCAEX'              * Skip remainder of phase3       14630000
.LOOPIRU B     &TARGET                 * And go check next FDB          14640000
*                                                                       14650000
LOOPIREX EQU   *                                                        14660000
*                                                                       14670000
         SPACE 3                                                        14680000
*                                                                       14690000
* Finally close requests need to be executed if requested.              14700000
* Close is a synchronous request.                                       14710000
*                                                                       14720000
&TARGET  SETC  'LOOPCA'                * Normal process: loop thru FDBs 14730000
         AIF   (NOT &OPT).LOOPCA       * When optimizing, then          14740000
&TARGET  SETC  'LOOPCAEX'              * go test for insert-request     14750000
         AGO   .LOOPCAT                * and omit FDB-loop logic        14760000
.LOOPCA  ANOP                                                           14770000
*                                                                       14780000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    14790000
LOOPCA   L     R5,FDBNEXT              * Make next FDB the current one  14800000
         LTR   R5,R5                   * If it is zero, we're through   14810000
         BZ    LOOPCAEX                * If no next FDB, then exit loop 14820000
*                                                                       14830000
.LOOPCAT ANOP                                                           14840000
LOOPCAT  TM    FDBREQ,FDBCLOSE         * Close this file ??             14850000
         BNO   &TARGET                 * No: skip close routine         14860000
         BAS   R14,RCA                 * Execute close routine          14870000
*                                                                       14880000
         AIF   (&OPT).LOOPCAX                                           14890000
         B     &TARGET                 * And go check next FDB          14900000
.LOOPCAX ANOP                                                           14910000
*                                                                       14920000
LOOPCAEX EQU   *                                                        14930000
*                                                                       14940000
         PRINT &PRT                    * Set print option               14950000
*                                                                       14960000
         SPACE 3                                                        14970000
*                                                                       14980000
* Phase 3 is done. Continue with phase 4                                14990000
*                                                                       15000000
         L     R3,=AL4(PHASE4)         * Get start address of phase 4   15010000
         BR    R3                      * And go execute it              15020000
*                                                                       15030000
         EJECT                                                          15040000
*                                                                       15050000
* ROP processes any open requests: sequential / random                  15060000
*                                  input / update                       15070000
*                                                                       15080000
ROP      EQU   *                       * Process open request           15090000
         ST    R14,UALV1SAV            * Save R14 level 1               15100000
*                                                                       15110000
* If any last request is still present in the FDB, it is invalidated    15120000
* by the open request, so we wipe it out.                               15130000
*                                                                       15140000
         MVI   FDBLREQ,FDBNOREQ        * Blank last request issued      15150000
         MVI   FDBLKEY,X'40'           * and the associated key         15160000
         MVC   FDBLKEY+1(&MAXKEY-1),FDBLKEy * Wipe remainder of key-fld 15170000
*                                                                       15180000
* If a VSAM resource does not yet exist, go allocate one.               15190000
*                                                                       15200000
         TM    UAVRPSTA,UAVEXIST       * Has VRP been allocated ??      15210000
         BO    ROP0                    * Yes: skip allocation           15220000
         BAS   R14,RBLDVRP             * Go allocate VRP                15230000
*                                                                       15240000
* Before we allocate an ACB we must put the correct DDNAME in the FDB.  15250000
* In the location of the first blank an I or a U is to be inserted,     15260000
* depending on open for input or for update respectively.               15270000
*                                                                       15280000
ROP0     EQU   *                       * Append I/U to DDNAME           15290000
         L     R10,=AL4(SEEKSPC)       * Get addr of seek-space table   15300000
         TRT   FDBDDNAM,0(R10)         * Get addr of 1st blank in field 15310000
         BZ    ROP1                    * If no spaces, dont change name 15320000
*                                                                       15330000
* R1 now contains the address of the first blank position in the        15340000
* DDNAME. This is the address where an I or a U is to be inserted       15350000
*                                                                       15360000
         MVI   0(R1),C'I'              * Default to input processing    15370000
         TM    FDBREQ,FDBOPENU         * Open file for update ??        15380000
         BNO   ROP1                    * No: leave it with the 'I'      15390000
         MVI   0(R1),C'U'              * Use 'U' for update processing  15400000
*                                                                       15410000
* The open options input/update and sequential/random are tested and    15420000
* translated into an offset in a table that contains the addresses of   15430000
* the default ACBs for each option combination. The difference between  15440000
* LSR or private pools is reflected in the table as well.               15450000
*                                                                       15460000
ROP1     MVI   UAWORK,X'00'            * Clear to calc offset in ACBTAB 15470000
         CLI   UAPOOLNR,X'0F'          * LSR pools allocated ??         15480000
         BNH   ROP1NSR                 * Yes: stick to offset 0         15490000
         OI    UAWORK,X'10'            * No: add 16 to offset for       15500000
*                                      *            private pools       15510000
ROP1NSR  TM    FDBREQ,FDBOPENU         * Open file for update ??        15520000
         BNO   ROP1INP                 * No: stick to offset 0          15530000
         OI    UAWORK,X'08'            * Yes: add 8 to offset for updat 15540000
ROP1INP  TM    FDBREQ,FDBOPRND         * Open file random ??            15550000
         BNO   ROP1SEQ                 * No: stick to offset 0          15560000
         OI    UAWORK,X'04'            * Yes: add 4 to offset for rand. 15570000
ROP1SEQ  EQU   *                                                        15580000
*                                                                       15590000
* The offset to be used is in the UAWORK field now.                     15600000
* Before building the ACB and RPL we must allocate storage for them     15610000
*                                                                       15620000
         GETMAIN RC,                   * Conditional request for ACB   *15630000
               SP=&SP,                 *    from our own subpool       *15640000
               LV=IFGACBLV+IFGRPLLV    *    long enough for ACB + RPL   15650000
         LTR   R15,R15                 * Getmain was ok??               15660000
         BZ    ROP1GOTM                * No: go issue error             15670000
         OI    FDBSTAT,FDBERROR        * Indicate error status          15680000
         LA    R15,023                 * Error number                   15690000
         L     R3,=AL4(ERROR)          * Get address of error handler   15700000
         BASR  R14,R3                  * Execute it, then return here   15710000
         B     ROP99                   * Skip rest of open processing   15720000
*                                                                       15730000
ROP1GOTM ST    R1,FDBACB               * Save address of area for ACB   15740000
         LR    R7,R1                   * Copy addr where ACB is to go   15750000
         LA    R1,IFGACBLV(R1)         * Point to RPL-part of area      15760000
         ST    R1,FDBRPL               * And save address for RPL       15770000
*                                                                       15780000
         XR    R1,R1                   * Clear register                 15790000
         IC    R1,UAWORK               * Get offset for ACBTAB          15800000
         L     R15,=AL4(ACBTAB)        * Get address of ACBTAB          15810000
         L     R2,0(R15,R1)            * Get addr of plist from ACBTAB  15820000
         XR    R6,R6                   * Clear register                 15830000
         IC    R6,UAPOOLNR             * to contain shrpool-id          15840000
         LR    R3,R2                   * Addr of gencb plist to base    15850000
         BASR  R10,R3                  * Go build plist, retaddr in R10 15860000
         L     R3,=AL4(PHASE3)         * Restore our own base register  15870000
*                                      *    no retcode in R15 !!!!      15880000
         LA    R2,UAWORKAR             * Point to generated plist       15890000
         GENCB BLK=ACB,                * Generate the ACB              *15900000
               MF=(E,(R2))             *    using the plist in uaworkar 15910000
         LTR   R15,R15                 * Has ACB been built ok ??       15920000
         BZ    ROP2                    * Yes: skip error handling       15930000
*                                                                       15940000
ROP1ERR  OI    FDBSTAT,FDBERROR        * Indicate error status          15950000
         ST    R15,UAVSAMRC            * Save returncode from VSAM      15960000
         LA    R15,049                 * Load error number and          15970000
         L     R3,=AL4(ERROR)          * Get address of error handler   15980000
         BASR  R14,R3                  * Execute it, then return here   15990000
         B     ROP99                   * Skip remainder of open process 16000000
*                                                                       16010000
* The ACB has been built successfully,                                  16020000
* now generate a default RPL for this ACB.                              16030000
*                                                                       16040000
* The index for the table with addresses of default RPLs is equal to    16050000
* the index used with the ACBs, with the exclusion of the difference    16060000
* between LSR and private pools, so we can simply reuse the same byte   16070000
* after wiping the LSR/private bit.                                     16080000
*                                                                       16090000
ROP2     EQU   *                                                        16100000
         L     R9,FDBRPL               * Retrieve address for RPL       16110000
         NI    UAWORK,X'0F'            * Remove superfluous index bits  16120000
         XR    R1,R1                   * Clear register                 16130000
         IC    R1,UAWORK               * Get offset for RPLTAB          16140000
         L     R15,=AL4(RPLTAB)        * Get address of RPLTAB          16150000
         L     R2,0(R15,R1)            * Get addr of plist from RPLTAB  16160000
         L     R7,FDBACB               * Reload addr of ACB to be used  16170000
         LH    R8,FDBRECLV             * Get record length for RPL      16180000
         XR    R6,R6                   * Clear register                 16190000
         IC    R6,FDBKEYLV             * to contain key length          16200000
         LR    R3,R2                   * Addr of gencb plist to base    16210000
         BASR  R10,R3                  * Go build plist, retaddr in R10 16220000
         L     R3,=AL4(PHASE3)         * Restore our own base register  16230000
*                                      *    no retcode in R15 !!!!      16240000
         LA    R2,UAWORKAR             * Point to generated plist       16250000
         GENCB BLK=RPL,                * Generate the RPL              *16260000
               MF=(E,(R2))             *    using the plist in UAWORKAR 16270000
         LTR   R15,R15                 * Has RPL been built ok ??       16280000
         BZ    ROP3                    * Yes: skip error handling       16290000
*                                                                       16300000
ROP2ERR  OI    FDBSTAT,FDBERROR        * Indicate error status          16310000
         ST    R15,UAVSAMRC            * Save VSAM's retcd in USERAREA  16320000
         LA    R15,050                 * Error number                   16330000
         L     R3,=AL4(ERROR)          * Get address of error handler   16340000
         BASR  R14,R3                  * Execute it, then return here   16350000
         B     ROP99                   * Skip rest of open processing   16360000
*                                                                       16370000
* The RPL has been built successfully, so we save its address and       16380000
* length in the FDB. Then we can try to open the file.                  16390000
* Increment IO-call counter, then open file (synchronous I/O)           16400000
*                                                                       16410000
ROP3     EQU   *                                                        16420000
         AIF   (&OPT).ROP9                                              16430000
         L     R2,UAIOCNT              * Load total I/O-count           16440000
         LA    R2,1(R2)                * Increment by one               16450000
         ST    R2,UAIOCNT              * And store updated value        16460000
*                                                                       16470000
.ROP9    ANOP                                                           16480000
         L     R2,=AL4(VSAMOPEN)       * Get address of list-form open  16490000
         MVC   UAWORKAR(VSAMOPLV),0(R2) * copy to work-area             16500000
         LA    R9,UAWORKAR             * And point to modifiable copy   16510000
         L     R2,FDBACB               * Reload address of ACB          16520000
         OPEN  ((R2)),                 * Open the ACB just generated   *16530000
               MF=(E,(R9))             *    using the copy of the plist 16540000
         LTR   R15,R15                 * Was open successfull ??        16550000
         BZ    ROP9                    * Yes: skip error handling       16560000
         OI    FDBSTAT,FDBERROR        * Indicate error status          16570000
         ST    R15,UAVSAMRC            * Save returncode for dumping    16580000
         LA    R15,051                 * Error number                   16590000
         L     R3,=AL4(ERROR)          * Get address of error handler   16600000
         BASR  R14,R3                  * Execute it, then return here   16610000
         B     ROP99                   * Skip remainder of open process 16620000
*                                                                       16630000
* The file has been opened successfully. Now set the FDBSTAT bits       16640000
* to reflect the current status.                                        16650000
*                                                                       16660000
ROP9     EQU   *                                                        16670000
         OI    FDBSTAT,FDBINPUT        * Indicate file is open          16680000
         TM    FDBREQ,FDBOPENU         * Open for update ??             16690000
         BNO   ROP9INP                 * No: skip setting update bit    16700000
         OI    FDBSTAT,FDBUPDAT        * Yes: set update bit            16710000
*                                                                       16720000
ROP9INP  TM    FDBREQ,FDBOPRND         * Open for random access ??      16730000
         BNO   ROP99                   * No: skip setting random bit    16740000
         OI    FDBSTAT,FDBACRND        * Yes: set random bit            16750000
*                                                                       16760000
* The open request uses the request bit associated with a close request 16770000
* to distinguish between random and sequential open requests. Since the 16780000
* open request has been processed now, the random/sequential option bit 16790000
* must be reset. Otherwise it will be interpreted as a close request    16800000
* and the file would be closed in the very same call as it was opened.  16810000
*                                                                       16820000
ROP99    EQU   *                                                        16830000
         NI    FDBREQ,FDBNOCA          * Reset random/close request     16840000
         L     R14,UALV1SAV            * Reload return address          16850000
         BR    R14                     * And return to caller           16860000
*                                                                       16870000
         EJECT                                                          16880000
*                                                                       16890000
* RSK processes any skip requests: sequential                           16900000
*                                  input / update                       16910000
*                                                                       16920000
RSK      EQU   *                       * Process skip request           16930000
         ST    R14,UALV1SAV            * Save R14 level 1               16940000
*                                                                       16950000
* A skip request cannot be preceded by an asynchronous request.         16960000
* Therefore, if the ECB is in use, we have run into an error.           16970000
*                                                                       16980000
         L     R0,FDBECB               * Get old ECB                    16990000
         LTR   R0,R0                   * Check that the ECB is free     17000000
         BZ    RSK10                   * If it is zero, skip error      17010000
         LA    R15,011                 * Load error number              17020000
         L     R3,=AL4(ERROR)          * Get address of error handler   17030000
         BASR  R14,R3                  * Execute it, then return here   17040000
         ST    R3,UABASSAV             * Save current base register     17050000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    17060000
         BASR  R14,R3                  * And go wait for I/O-completion 17070000
*                                                                       17080000
* If the file is in error status, no processing can take place          17090000
*                                                                       17100000
RSK10    TM    FDBSTAT,FDBERROR        * Check for problems             17110000
         BO    RSK99                   * File is in error: abort skip   17120000
*                                                                       17130000
* For skip processing, use as many numbers as are given in key field    17140000
* of the parameter, with a maximum of the actual key length and a       17150000
* minimum of four numbers.                                              17160000
*                                                                       17170000
         L     R10,=AL4(NUMTAB)        * Get addr of TRT-table for key  17180000
         XR    R1,R1                   * Clear register                 17190000
         IC    R1,FDBKEYLV             * Get length of key              17200000
         BCTR  R1,R0                   * Decrement length by 1 for TRT  17210000
         EX    R1,RSKTRT               * Find first nonnumeric byte     17220000
         BZ    RSK11                   * If all numbers use full length 17230000
*                                                                       17240000
* R1 now contains the address of the first non-numeric position in the  17250000
* key. This is the address +1 of the last byte to be used.              17260000
*                                                                       17270000
         LA    R2,UAKEY                * Get start address of key       17280000
         SR    R1,R2                   * Difference = nr of used bytes  17290000
         LR    R2,R1                   * And put key len in right reg.  17300000
         B     RSK12                   * Skip default length setting    17310000
*                                                                       17320000
RSK11    XR    R2,R2                   * Clear register                 17330000
         IC    R2,FDBKEYLV             * Pick up total key length       17340000
*                                                                       17350000
* R2 now contains the number of key-bytes to be used in this skip       17360000
* operation. Before skipping, the RPL must be changed to contain the    17370000
* required (generic or full) key length.                                17380000
*                                                                       17390000
RSK12    EQU   *                                                        17400000
         LR    R10,R2                  * Load keylen-value to be used   17410000
         L     R2,FDBRPL               * Retrieve address of RPL        17420000
         CLM   R10,1,FDBSKKLV          * Is skip-key length ok ??       17430000
         BE    RSK20                   * Yes: no modcb required.        17440000
         MODCB RPL=(R2),               * Modify current RPL to reflect *17450000
               KEYLEN=(S,0(R10)),      *    correct key length         *17460000
               MF=(G,UAWORKAR,MODCBKLV) * use UAWORKAR to build plist   17470000
         LTR   R15,R15                 * Modcb was ok ??                17480000
         BZ    RSK19                   * Yes: proceed to point          17490000
         ST    R15,UAVSAMRC            * Save VSAM retcode              17500000
         LA    R15,020                 * Indicate error code            17510000
         L     R3,=AL4(ERROR)          * Get address of error handler   17520000
         BASR  R14,R3                  * Execute it, then return here   17530000
         B     RSK20                   * And try to position            17540000
*                                                                       17550000
RSK19    EQU   *                       * Modcb was ok.                  17560000
         STC   R10,FDBSKKLV            * Save current skip key-length   17570000
*                                                                       17580000
* Now request VSAM to start the skip, which is executed asynchronously. 17590000
*                                                                       17600000
RSK20    EQU   *                                                        17610000
         POINT RPL=(R2)                * Execute asynchronous point     17620000
         LTR   R15,R15                 * Point started correctly ??     17630000
         BZ    RSK90                   * Yes: complete the request      17640000
         ST    R15,UAVSAMRC            * Save VSAM retcode              17650000
         LA    R15,052                 * Load error number              17660000
         L     R3,=AL4(ERROR)          * Get address of error handler   17670000
         BASR  R14,R3                  * Execute it, then return here   17680000
         B     RSK99                   * Skip remainder of skip-process 17690000
*                                                                       17700000
* Before returning to the mainline, we must set an unused bit in the    17710000
* ECB because the ECB is used to check whether a check is required      17720000
* before issuing another VSAM request or returning to the caller.       17730000
* Normally the requested VSAM routine should set the busy bit in the    17740000
* ECB, but sometimes VSAM is too slow and a check is skipped where it   17750000
* should not have been skipped. Therefore we must set a bit in the ECB  17760000
* ourselves.                                                            17770000
*                                                                       17780000
RSK90    EQU   *                                                        17790000
         OI    FDBECB,X'01'            * Indicate I/O is in progress    17800000
         NI    FDBSTAT,FDBNOEOF        * Point should reset eof-status  17810000
*                                                                       17820000
RSK99    L     R14,UALV1SAV            * Reload return address          17830000
         BR    R14                     * And return to caller           17840000
*                                                                       17850000
         SPACE 3                                                        17860000
*                                                                       17870000
RSKTRT   TRT   UAKEY(0),0(R10)         * Check nr of numeric characters 17880000
*                                      *       in key                   17890000
         EJECT                                                          17900000
*                                                                       17910000
* RRX processes any read requests: sequential / random                  17920000
*                                  input / update                       17930000
*                                                                       17940000
RRX      EQU   *                       * Process read request           17950000
         ST    R14,UALV1SAV            * Save R14 level 1               17960000
*                                                                       17970000
* If the ECB is in use, some operation must have been requested,        17980000
* which must finish before we can proceed.                              17990000
*                                                                       18000000
         L     R1,FDBECB               * Load current contents of ECB   18010000
         LTR   R1,R1                   * Check that ECB is free (zero)  18020000
         BZ    RRX20                   * Yes: go start read             18030000
*                                                                       18040000
* Another request is being processed by VSAM. If this situation is      18050000
* unexpected, issue a warning. Before proceeding wait for the I/O       18060000
* in progress to complete.                                              18070000
*                                                                       18080000
RRX10    EQU   *                                                        18090000
         TM    FDBREQ,FDBSKIP          * Was a skip requested ??        18100000
         BO    RRX18                   * Yes: skip the warning message  18110000
         AIF   (NOT &OPT).RRX18                                         18120000
         TM    FDBREQ,FDBWRITE         * Was a write requested ??       18130000
         BO    RRX18                   * Yes: skip the warning message  18140000
         TM    FDBREQ,FDBDEL           * Was a delete requested ??      18150000
         BO    RRX18                   * Yes: skip the warning message  18160000
*                                                                       18170000
.RRX18   ANOP                                                           18180000
         LA    R15,012                 * Load error number              18190000
         L     R3,=AL4(ERROR)          * Get address of error routine   18200000
         BASR  R14,R3                  * Execute it, then return here   18210000
*                                                                       18220000
RRX18    EQU   *                                                        18230000
         ST    R3,UABASSAV             * Save current base register     18240000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    18250000
         BASR  R14,R3                  * Go wait for I/O completion     18260000
*                                                                       18270000
* If an error condition is raised, no reading should be done.           18280000
*                                                                       18290000
RRX20    TM    FDBSTAT,FDBERROR        * Check for problems             18300000
         BO    RRX99                   * On error: quit                 18310000
*                                                                       18320000
* For random read (RR) a get must be issued to retrieve the record.     18330000
* For sequential read (RS) the next record is to be made current.       18340000
* If there's no next record in the buffer, then a skip                  18350000
* must be enforced to retrieve the next control interval.               18360000
*                                                                       18370000
         TM    FDBSTAT,FDBACRND        * Access is random ??            18380000
         BO    RRX50                   * Get a record                   18390000
*                                                                       18400000
* Access is sequential, check on eof-condition                          18410000
*                                                                       18420000
         TM    FDBSTAT,FDBEOF          * End-of-file ??                 18430000
         BNO   RRX30                   * No: go find next record in buf 18440000
         NI    FDBREQ,FDBNORX          * Reset read request bit         18450000
         TM    FDBREQ,FDBSKIP          * Skip was requested also ??     18460000
         BO    RRX99                   * Yes: skip caused eof !!        18470000
         LA    R15,038                 * Set error number               18480000
         L     R3,=AL4(ERROR)          * Get address of error handler   18490000
         BASR  R14,R3                  * Issue warning, return here     18500000
         B     RRX99                   * And skip issuing the read      18510000
*                                                                       18520000
* If the current record (according to FDB) is not valid, then the next  18530000
* record to be read is the first record in the current control interval 18540000
* otherwise the next record is to be found by incrementing the record   18550000
* pointer with the record length. If the next record lies beyond the    18560000
* current buffer, then a skip is to be forced.                          18570000
*                                                                       18580000
RRX30    EQU   *                       * Locate next sequential record  18590000
         L     R2,FDBREC               * Get address of current record  18600000
         LTR   R6,R2                   * Is it valid ??                 18610000
         BNE   RRX32                   * No: add record length          18620000
*                                      * Yes: use first record in buf   18630000
         MVC   FDBREC,FDBSBUF          * Copy addr of first rec in buf  18640000
         B     RRX99                   * And we're done                 18650000
*                                                                       18660000
RRX32    EQU   *                       * Addr of old record saved in R6 18670000
         AH    R2,FDBRECLV             * Get addr of next record in buf 18680000
         ST    R2,FDBREC               * Store address of next record   18690000
         C     R2,FDBEBUF              * New address < end-of-buffer    18700000
         BL    RRX99                   * Yes: new record addr is valid  18710000
*                                                                       18720000
* Address of new record lies beyond end-of-buffer: force a skip         18730000
* to the next control-interval.                                         18740000
*                                                                       18750000
         MVC   UAKEY,0(R6)             * Move key from buf to USERAREA  18760000
         XR    R1,R1                   * Clear register                 18770000
         IC    R1,FDBKEYLV             * to contain key length          18780000
         BCTR  R1,R0                   * Minus one to address last byte 18790000
         XR    R2,R2                   * Clear register                 18800000
         IC    R2,UAKEY(R1)            * Get last byte of key           18810000
         LA    R2,1(R2)                * Increment last byte of key     18820000
         STC   R2,UAKEY(R1)            * Store new last byte of key     18830000
         LA    R1,1(R1)                * Reset reg to full key length   18840000
*                                                                       18850000
* The UAKEY-field now contains the key of the last record in the        18860000
* current buffer + binary 1. Since the search key is the lowest         18870000
* possible key in the next control-interval the subsequent point        18880000
* will retrieve the next control-interval.                              18890000
*                                                                       18900000
         L     R2,FDBRPL               * Retrieve address of RPL        18910000
         CLM   R1,1,FDBSKKLV           * Skip-key-length is ok ??       18920000
         BE    RRX35                   * Yes: no modcb required         18930000
         LR    R10,R1                  * Load keylen-value to be used   18940000
         MODCB RPL=(R2),               * Modify current RPL to         *18950000
               KEYLEN=(S,0(R10)),      *    correct key length         *18960000
               MF=(G,UAWORKAR)         *    use UAWORKAR to build plist 18970000
*                                                                       18980000
         LTR   R15,R15                 * Modcb was ok ??                18990000
         BZ    RRX34                   * Yes: proceed to point          19000000
         ST    R15,UAVSAMRC            * Save VSAM retcode              19010000
         LA    R15,020                 * Indicate error code            19020000
         L     R3,=AL4(ERROR)          * Get address of error handler   19030000
         BASR  R14,R3                  * Execute it, then return here   19040000
         NI    FDBREQ,FDBNORX          * Reset read request bit         19050000
         B     RRX99                   * Exit read routine              19060000
*                                                                       19070000
RRX34    EQU   *                       * Modcb was ok                   19080000
         STC   R10,FDBSKKLV            * Save skip key-length           19090000
*                                                                       19100000
* Now request VSAM to start the skip, which is executed asynchronously. 19110000
*                                                                       19120000
RRX35    EQU   *                                                        19130000
         POINT RPL=(R2)                * Execute asynchronous point     19140000
         LTR   R15,R15                 * Point started correctly ??     19150000
         BZ    RRX40                   * Yes: complete the request      19160000
         ST    R15,UAVSAMRC            * Save VSAM retcode              19170000
         LA    R15,052                 * Load error number              19180000
         L     R3,=AL4(ERROR)          * Get address of error handler   19190000
         BASR  R14,R3                  * Execute it, then return here   19200000
         NI    FDBREQ,FDBNORX          * Reset read request             19210000
         B     RRX99                   * Skip remainder of read-process 19220000
*                                                                       19230000
RRX40    EQU   *                                                        19240000
         OI    FDBREQ,FDBREAD2         * Request re-read and indicate   19250000
*                                      *         skip-request           19260000
         OI    UASTAT,UARQREAD         * Signal restart read request    19270000
         B     RRX90                   * Postpone further reading till  19280000
*                                      *    RRX is executed again       19290000
*                                                                       19300000
* A get will have to be issued, so that VSAM may locate the correct     19310000
* control-interval.                                                     19320000
*                                                                       19330000
RRX50    EQU   *                                                        19340000
         L     R2,FDBRPL               * Retrieve address of RPL        19350000
         GET   RPL=(R2)                * Ask VSAM to start a read       19360000
         LTR   R15,R15                 * Has I/O been started ??        19370000
         BZ    RRX90                   * Yes: skip error handling       19380000
         ST    R15,UAVSAMRC            * Save VSAM retcode              19390000
         LA    R15,053                 * Load error number              19400000
         L     R3,=AL4(ERROR)          * Get address of error handler   19410000
         BASR  R14,R3                  * Execute it, then return here   19420000
         B     RRX99                   * Skip remainder of read-process 19430000
*                                                                       19440000
RRX90    EQU   *                       * Async. request is accepted     19450000
         OI    FDBECB,X'01'            * Indicate I/O is in progress    19460000
*                                                                       19470000
RRX99    EQU   *                                                        19480000
         L     R14,UALV1SAV            * Reload return address          19490000
         BR    R14                     * And return to caller           19500000
*                                                                       19510000
         SPACE 3                                                        19520000
*                                                                       19530000
RRXCLC   CLC   UAKEY(0),0(R2)          * Compare requested key with     19540000
*                                      *            record key          19550000
         EJECT                                                          19560000
*                                                                       19570000
* RWX processes any write requests: sequential / random                 19580000
*                                           update                      19590000
*                                                                       19600000
RWX      EQU   *                       * Process write request          19610000
         ST    R14,UALV1SAV            * Save R14 level 1               19620000
*                                                                       19630000
* If the ECB is in use, we have run into an error, since no             19640000
* asynchronous I/O-requests may precede a write request.                19650000
*                                                                       19660000
         L     R0,FDBECB               * Get old ECB                    19670000
         LTR   R0,R0                   * Check that the ECB is free     19680000
         BZ    RWX10                   * If it is zero, skip error      19690000
         LA    R15,013                 * Load error number              19700000
         L     R3,=AL4(ERROR)          * Get address of error handler   19710000
         BASR  R14,R3                  * Execute it, then return here   19720000
         ST    R3,UABASSAV             * Save current base register     19730000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    19740000
         BASR  R14,R3                  * And go wait for I/O-completion 19750000
*                                                                       19760000
* If an error condition is raised for the file, no I/O must be started. 19770000
*                                                                       19780000
RWX10    TM    FDBSTAT,FDBERROR        * Check for problems             19790000
         BO    RWX99                   * On error: quit                 19800000
*                                                                       19810000
* Compare old and new keys to make sure that the key will not be        19820000
* changed by the update request.                                        19830000
*                                                                       19840000
         XR    R1,R1                   * Clear register                 19850000
         IC    R1,FDBKEYLV             * Get key length                 19860000
         LA    R8,LNSKEY(R1)           * Load address of data area      19870000
         BCTR  R1,R0                   * Decrement to length-1 for CLC  19880000
         LA    R2,FDBLKEY              * Get key-addr of previous read  19890000
         EX    R1,RWXCLC               * Compare old and new key        19900000
         BE    RWX20                   * If equal skip error handling   19910000
*                                                                       19920000
RWXERR30 LA    R15,043                 * Load error code                19930000
         L     R3,=AL4(ERROR)          * Get address of error handler   19940000
         BASR  R14,R3                  * Execute it, then return here   19950000
         B     RWX99                   * Skip remainder of write-logic  19960000
*                                                                       19970000
RWX20    EQU   *                                                        19980000
         L     R2,FDBREC               * Get addr of record within buf  19990000
         EX    R1,RWXCLC               * Compare buffer-key and new key 20000000
         BNE   RWXERR30                * If not equal then abend        20010000
*                                                                       20020000
* The key has not changed. Assemble the record from the data in the     20030000
* parameter in a work area prior to the actual update.                  20040000
*                                                                       20050000
         BAS   R14,RASM                * Go assemble new record         20060000
*                                                                       20070000
* Since no put is used to update the record, we must tell VSAM that     20080000
* the contents of the buffer have changed by marking the buffer for     20090000
* output. Thus the buffer will be rewritten, before its slot will be    20100000
* used to accommodate another buffer.                                   20110000
*                                                                       20120000
         TM    FDBSTAT,FDBBUFUP        * Buffer marked for output ?     20130000
         BO    RWX99                   * Yes: no mrkbfr required        20140000
         L     R2,FDBRPL               * Get address of RPL             20150000
         MRKBFR MARK=OUT,              * Mark buffer for output        *20160000
               RPL=(R2)                *    for current RPL             20170000
         LTR   R15,R15                 * Mrkbfr was ok ??               20180000
         BZ    RWX90                   * If zero, conclude write logic  20190000
         ST    R15,UAVSAMRC            * Save VSAM retcode              20200000
         LA    R15,059                 * Load error number              20210000
         L     R3,=AL4(ERROR)          * Get address of error handler   20220000
         BASR  R14,R3                  * Execute it, then return here   20230000
         B     RWX99                   * Skip remainder of write-logic  20240000
*                                                                       20250000
RWX90    EQU   *                       * Asynchronous request accepted  20260000
         OI    FDBECB,X'01'            * Indicate I/O is in progress    20270000
         OI    FDBSTAT,FDBBUFUP        * Indicate buffer marked         20280000
*                                      *        for output              20290000
RWX99    EQU   *                                                        20300000
         L     R14,UALV1SAV            * Reload return address          20310000
         BR    R14                     * And return to caller           20320000
*                                                                       20330000
         SPACE 3                                                        20340000
*                                                                       20350000
RWXCLC   CLC   0(0,R2),0(R8)           * Compare read and write keys    20360000
*                                                                       20370000
         EJECT                                                          20380000
*                                                                       20390000
* RIR processes any insert requests: sequential / random                20400000
*                                            update                     20410000
*                                                                       20420000
RIR      EQU   *                       * Process insert request         20430000
         ST    R14,UALV1SAV            * Save R14 level 1               20440000
*                                                                       20450000
* Since no other requests may accompany an insert request it is an      20460000
* error if the ECB is currently in use.                                 20470000
*                                                                       20480000
         L     R0,FDBECB               * Get old ECB                    20490000
         LTR   R0,R0                   * Check that the ECB is free     20500000
         BZ    RIR10                   * If it is zero, skip error      20510000
         LA    R15,014                 * Load error number              20520000
         L     R3,=AL4(ERROR)          * Get address of error handler   20530000
         BASR  R14,R3                  * Execute it, then return here   20540000
         ST    R3,UABASSAV             * Save current base register     20550000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    20560000
         BASR  R14,R3                  * And go wait for I/O-completion 20570000
*                                                                       20580000
* If the file is in error status, no I/O should be requested.           20590000
*                                                                       20600000
RIR10    TM    FDBSTAT,FDBERROR        * Check for problems             20610000
         BO    RIR99                   * On error: quit                 20620000
*                                                                       20630000
* First we must rebuild the record from the parameter in a work area    20640000
*                                                                       20650000
         BAS   R14,RASM                * Assemble complete record       20660000
         TM    FDBSTAT,FDBRPLIR        * Has RPL been reset to NUP ??   20670000
         BO    RIR20                   * Yes: skip changing UPD to NUP  20680000
*                                                                       20690000
* RPL is not in insert status, so it must be changed before we can      20700000
* request VSAM to insert this record into the file.                     20710000
*                                                                       20720000
         L     R2,FDBRPL               * Get address of RPL             20730000
         L     R6,FDBWAREA             * Get addr of record in workarea 20740000
         LH    R7,FDBRECLV             * Get length of record           20750000
         MODCB RPL=(R2),               * Modify RPL to insert mode     *20760000
               AREA=(S,0(R6)),         *     specifying record area    *20770000
               AREALEN=(S,0(R7)),      *     and record length         *20780000
               OPTCD=(NUP,MVE),        *     non-update move mode      *20790000
               MF=(G,UAWORKAR,MODCBILV) *    build plist in UAWORKAR    20800000
         LTR   R15,R15                 * RPL changed without error ?    20810000
         BZ    RIR19                   * Yes: skip error                20820000
         ST    R15,UAVSAMRC            * Save VSAM retcode              20830000
         LA    R15,061                 * Set error number               20840000
         L     R3,=AL4(ERROR)          * Get address of error handler   20850000
         BASR  R14,R3                  * Execute it, then return here   20860000
         B     RIR99                   * Skip remainder of insert-logic 20870000
*                                                                       20880000
RIR19    EQU   *                                                        20890000
         OI    FDBSTAT,FDBRPLIR        * Indicate RPL status            20900000
*                                                                       20910000
* The RPL is in insert status right now. If we ask vsam to put the      20920000
* record, VSAM will try to insert it. Splitting control-intervals       20930000
* and control-areas, when not enough free space is available will be    20940000
* taken care off by VSAM.                                               20950000
*                                                                       20960000
RIR20    EQU   *                                                        20970000
         L     R2,FDBRPL               * Get plist-address              20980000
         PUT   RPL=(R2)                * Have VSAM insert new record    20990000
         LTR   R15,R15                 * Request accepted by VSAM ?     21000000
         BZ    RIR90                   * Yes: skip error handling       21010000
         ST    R15,UAVSAMRC            * Save VSAM retcode              21020000
         LA    R15,054                 * Load error number              21030000
         L     R3,=AL4(ERROR)          * Get address of error handler   21040000
         BASR  R14,R3                  * Execute it, then return here   21050000
         B     RIR99                   * Skip remainder of insert-logic 21060000
*                                                                       21070000
RIR90    EQU   *                       * Asynchronous request accepted  21080000
         OI    FDBECB,X'01'            * Indicate I/O is in progress    21090000
*                                                                       21100000
RIR99    L     R14,UALV1SAV            * Reload return address          21110000
         BR    R14                     * And return to caller           21120000
*                                                                       21130000
         EJECT                                                          21140000
*                                                                       21150000
* RDR processes any delete requests: sequential / random                21160000
*                                            update                     21170000
*                                                                       21180000
RDR      EQU   *                       * Process delete request         21190000
         ST    R14,UALV1SAV            * Save R14 level 1               21200000
*                                                                       21210000
* No other I/Os are allowed to accompany a delete request. Therefore    21220000
* if the ECB is in use, we have run into an error.                      21230000
*                                                                       21240000
         L     R0,FDBECB               * Get old ECB                    21250000
         LTR   R0,R0                   * Check that the ECB is free     21260000
         BZ    RDR10                   * If it is zero, skip error      21270000
         LA    R15,015                 * Load error number              21280000
         L     R3,=AL4(ERROR)          * Get address of error handler   21290000
         BASR  R14,R3                  * Execute it, then return here   21300000
         ST    R3,UABASSAV             * Save current base register     21310000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    21320000
         BASR  R14,R3                  * And go wait for I/O-completion 21330000
*                                                                       21340000
* No delete requests should be initiated if an error condition exists.  21350000
*                                                                       21360000
RDR10    TM    FDBSTAT,FDBERROR        * Check for problems             21370000
         BO    RDR99                   * On error: quit                 21380000
*                                                                       21390000
* Compare old and new key values to prevent inadvertent deletion of     21400000
* the wrong record.                                                     21410000
*                                                                       21420000
         XR    R1,R1                   * Clear register                 21430000
         IC    R1,FDBKEYLV             * Get key length                 21440000
         LA    R8,LNSKEY(R1)           * Load address of data area      21450000
         BCTR  R1,R0                   * Decrement to length-1 for CLC  21460000
         LA    R2,FDBLKEY              * Get key-addr of previous read  21470000
         EX    R1,RDRCLC               * Compare old and new key        21480000
         BE    RDR20                   * If equal skip error handling   21490000
*                                                                       21500000
RDRERR29 LA    R15,044                 * Load error code                21510000
         L     R3,=AL4(ERROR)          * Get address of error handler   21520000
         BASR  R14,R3                  * Execute it, then return here   21530000
         B     RDR99                   * Skip remainder of delete-logic 21540000
*                                                                       21550000
RDR20    EQU   *                                                        21560000
         L     R2,FDBREC               * Get addr of record in buffer   21570000
         EX    R1,RDRCLC               * Compare buffer-key and new key 21580000
         BNE   RDRERR29                * If not equal then abend        21590000
*                                                                       21600000
* Since VSAM assumes move mode for delete requests, we must rebuild     21610000
* the record in a work area before we can issue a delete request.       21620000
*                                                                       21630000
         BAS   R14,RASM                * Assemble complete record       21640000
*                                                                       21650000
* Change the RPL to move mode, and specify where our record buffer      21660000
* is located.                                                           21670000
*                                                                       21680000
         L     R2,FDBRPL               * Get address of RPL             21690000
         L     R6,FDBWAREA             * Get addr of record in workarea 21700000
         LH    R7,FDBRECLV             * Get length of record           21710000
         MODCB RPL=(R2),               * Modify RPL to delete mode     *21720000
               AREA=(S,0(R6)),         *     specifying record area    *21730000
               AREALEN=(S,0(R7)),      *     and record length         *21740000
               OPTCD=(MVE),            *     changing to move mode     *21750000
               MF=(G,UAWORKAR,MODCBDLV) *    build plist in UAWORKAR    21760000
         LTR   R15,R15                 * RPL changed without error ?    21770000
         BZ    RDR29                   * Yes: skip error                21780000
         ST    R15,UAVSAMRC            * Save retcode for error handler 21790000
         LA    R15,062                 * Set error number               21800000
         L     R3,=AL4(ERROR)          * Get address of error handler   21810000
         BASR  R14,R3                  * Execute it, then return here   21820000
         B     RDR99                   * And abort delete-processing    21830000
*                                                                       21840000
RDR29    EQU   *                                                        21850000
         OI    FDBSTAT,FDBRPLDR        * Indicate RPL status            21860000
*                                                                       21870000
* Now that the RPL is in delete status we can start the request to      21880000
* remove the record from the file.                                      21890000
*                                                                       21900000
         L     R2,FDBRPL               * Get address of RPL             21910000
         ERASE RPL=(R2)                * Delete this record             21920000
         LTR   R15,R15                 * Request issued to VSAM ??      21930000
         BZ    RDR90                   * Yes, we're done; skip error    21940000
         ST    R15,UAVSAMRC            * Save VSAM retcode              21950000
         LA    R15,055                 * Load error number              21960000
         L     R3,=AL4(ERROR)          * Get address of error handler   21970000
         BASR  R14,R3                  * Execute it, then return here   21980000
         B     RDR99                   * Skip remainder of delete-logic 21990000
*                                                                       22000000
RDR90    EQU   *                       * Asynchronous request accepted  22010000
         OI    FDBECB,X'01'            * Indicate I/O is in progress    22020000
*                                                                       22030000
RDR99    EQU   *                                                        22040000
         L     R14,UALV1SAV            * Reload return address          22050000
         BR    R14                     * And return to caller           22060000
*                                                                       22070000
         SPACE 3                                                        22080000
*                                                                       22090000
RDRCLC   CLC   0(0,R2),0(R8)           * Compare read and write keys    22100000
*                                                                       22110000
         EJECT                                                          22120000
*                                                                       22130000
* RCA processes any close request: sequential / random                  22140000
*                                  input / update                       22150000
*                                                                       22160000
RCA      EQU   *                       * Process close request          22170000
         ST    R14,UALV1SAV            * Save R14 level 1               22180000
         AIF   (NOT &DBG).RCA08        * Warning in test mode only      22190000
*                                                                       22200000
* If the last request was not an update for record with key all zeroes  22210000
* then the file version record has not been updated.                    22220000
*                                                                       22230000
         TM    FDBSTAT,FDBUPDAT        * File open in update mode ??    22240000
         BNO   RCA08                   * No: skip this check            22250000
         TM    FDBLREQ,FDBWRITE        * Last request was a write ??    22260000
         BNO   RCA05                   * No: issue warning              22270000
         XR    R1,R1                   * Clear register                 22280000
         IC    R1,FDBKEYLV             * To contain key length          22290000
         BCTR  R1,R0                   * Decrement by one for CLC       22300000
         EX    R1,RCACLC               * Key all zeroes ??              22310000
         BE    RCA08                   * Yes: ok                        22320000
*                                                                       22330000
RCA05    EQU   *                                                        22340000
         LA    R15,021                 * Load error number              22350000
         L     R3,=AL4(ERROR)          * Get address of error handler   22360000
         BASR  R14,R3                  * Execute it, then return here   22370000
.RCA08   ANOP                                                           22380000
*                                                                       22390000
* No error checking is done; if the file is in error it should be       22400000
* closed. However, if the ECB is in use, we have run into a rather      22410000
* serious error, because no other I/Os should accompany a close req     22420000
*                                                                       22430000
RCA08    L     R0,FDBECB               * Get old ECB                    22440000
         LTR   R0,R0                   * Check that the ECB is free     22450000
         BZ    RCA10                   * If it is zero, skip error      22460000
         LA    R15,016                 * Load error number              22470000
         L     R3,=AL4(ERROR)          * Get address of error handler   22480000
         BASR  R14,R3                  * Execute it, then return here   22490000
         ST    R3,UABASSAV             * Save current base register     22500000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    22510000
         BASR  R14,R3                  * And go wait for I/O-completion 22520000
*                                                                       22530000
* Increment IO-call counter, then close file (synchronous I/O)          22540000
*                                                                       22550000
RCA10    EQU   *                                                        22560000
         AIF   (&OPT).RCA10                                             22570000
         L     R2,UAIOCNT              * Load total io-count            22580000
         LA    R2,1(R2)                * Increment by one               22590000
         ST    R2,UAIOCNT              * And store updated value        22600000
*                                                                       22610000
.RCA10   ANOP                                                           22620000
         L     R2,=AL4(CLOSE)          * Point to list-form of close    22630000
         MVC   UAWORKAR(CLOSELV),0(R2) * Copy close-plist to work-area  22640000
         LA    R9,UAWORKAR             * Point to this modifiable copy  22650000
         L     R2,FDBACB               * Retrieve ACB-address           22660000
         CLOSE ((R2)),                 * Close the file                *22670000
               MF=(E,(R9))             *    using copy of default plist 22680000
         LTR   R15,R15                 * Close was ok ??                22690000
         BZ    RCA19                   * Yes: free storage areas        22700000
         OI    FDBSTAT,FDBERROR        * Set error-status for this file 22710000
         LA    R15,060                 * Indicate error number          22720000
         L     R3,=AL4(ERROR)          * Get address of error handler   22730000
         BASR  R14,R3                  * Execute it, then return here   22740000
         B     RCA90                   * And skip remainder of close    22750000
*                                                                       22760000
RCA19    EQU   *                                                        22770000
         NI    FDBSTAT,X'00'           * Reset status to closed         22780000
*                                                                       22790000
* Now that the file has been closed, the storage areas for ACB, RPL,    22800000
* and workarea should be returned to the system, because they were      22810000
* allocated dynamically.                                                22820000
*                                                                       22830000
RCA20    L     R2,FDBWAREA             * Retrieve address of workarea   22840000
         LTR   R2,R2                   * Does a workarea exist ??       22850000
         BZ    RCA30                   * No: skip freeing workarea      22860000
         LH    R6,FDBRECLV             * Retrieve length of area        22870000
         FREEMAIN RC,                  * Conditional freemain request  *22880000
               SP=&SP,                 *    from our own subpool       *22890000
               LV=(R6),                *    specifying length of area  *22900000
               A=(R2)                  *    and address of workarea     22910000
         LTR   R15,R15                 * Freemain was ok??              22920000
         BZ    RCA29                   * Yes: continue                  22930000
         LA    R15,024                 * Load error number              22940000
         L     R3,=AL4(ERROR)          * Get address of error handler   22950000
         BASR  R14,R3                  * Execute it, then return here   22960000
         XR    R15,R15                 * Simulate correct freemain      22970000
*                                                                       22980000
RCA29    EQU   *                                                        22990000
         ST    R15,FDBWAREA            * Reset address-field in FDB     23000000
*                                                                       23010000
RCA30    EQU   *                       * Remove ACB and RPL             23020000
         L     R2,FDBACB               * Retrieve address of ACB        23030000
         LTR   R2,R2                   * Does an ACB exist ??           23040000
         BZ    RCA50                   * No: skip freeing ACB/RPL-area  23050000
         FREEMAIN RC,                  * Conditionally free ACB/RPL    *23060000
               SP=&SP,                 *    from our private subpool   *23070000
               LV=IFGACBLV+IFGRPLLV,   *    specifying its length      *23080000
               A=(R2)                  *    and address                 23090000
         LTR   R15,R15                 * Freemain was ok??              23100000
         BZ    RCA39                   * Yes: continue                  23110000
         LA    R15,022                 * Load error number              23120000
         L     R3,=AL4(ERROR)          * Get address of error handler   23130000
         BASR  R14,R3                  * Execute it, then return here   23140000
         XR    R15,R15                 * Simulate correct freemain      23150000
*                                                                       23160000
RCA39    EQU   *                                                        23170000
         ST    R15,FDBRPL              * Reset ptr-field in FDB for RPL 23180000
         ST    R15,FDBACB              * Reset ptr-field in FDB for ACB 23190000
*                                                                       23200000
* The file has been closed, all dynamic storage areas associated with   23210000
* FDB have been freed. Before we can free the FDB-storage it must       23220000
* be removed from the FDB-chain.                                        23230000
*                                                                       23240000
RCA50    EQU   *                                                        23250000
         LR    R6,R5                   * Save address of current FDB    23260000
         LA    R5,UAFDBPTR             * Set ptr to start of FDB-chain  23270000
*                                                                       23280000
RCA52    C     R6,FDBNEXT              * Next FDB is the closed one ??  23290000
         BE    RCA55                   * Yes: go remove closed FDB      23300000
         L     R5,FDBNEXT              * Get addr of next FDB in chain  23310000
         LTR   R5,R5                   * Valid ??                       23320000
         BNZ   RCA52                   * Yes: it points to closed FDB?? 23330000
         B     RCA90                   * No: we're done                 23340000
*                                                                       23350000
RCA55    EQU   *                                                        23360000
         MVC   FDBNEXT,0(R6)           * Copy next field of closed FDB  23370000
*                                                                       23380000
* Closed FDB has now been removed from the FDB-chain.                   23390000
*                                                                       23400000
         FREEMAIN RC,                  * Conditionally free FDB-storage*23410000
               SP=&SP,                 *    from our private subpool   *23420000
               LV=L'FDB,               *    specifying both its length *23430000
               A=(R6)                  *    and its address             23440000
         LTR   R15,R15                 * Freemain was ok??              23450000
         BZ    RCA90                   * Yes: continue                  23460000
         LA    R15,025                 * Load error number              23470000
         L     R3,=AL4(ERROR)          * Get address of error handler   23480000
         BASR  R14,R3                  * Execute it, then return here   23490000
*                                                                       23500000
RCA90    EQU   *                                                        23510000
         L     R14,UALV1SAV            * Reload return address          23520000
         BR    R14                     * And return to caller           23530000
*                                                                       23540000
         SPACE 3                                                        23550000
*                                                                       23560000
RCACLC   CLC   FDBLKEY(0),=&MAXKEY.C'0' * Compare last key with zeros   23570000
RCACLCDD CLC   FDBDDLOC(0,R9),FDBDDNAM  * Compare FDBDDNAM-fields       23580000
*                                                                       23590000
         EJECT                                                          23600000
*                                                                       23610000
* RBLDVRP allocates a VSAM resource pool (VRP) tailored for either      23620000
*                    sequential or random processing                    23630000
*                                                                       23640000
RBLDVRP  EQU   *                       * Allocate VSAM resource pool    23650000
         ST    R14,UALV2SAV            * Save R14 level 2               23660000
*                                                                       23670000
* Now we will try to allocate a VSAM resource pool. If the requested    23680000
* shrpool number is too high, we skip the allocation and VSAM will      23690000
* have to use private pools.                                            23700000
*                                                                       23710000
         MVI   UAPOOLNR,X'00'          * Default shrpool-nr to be used  23720000
*                                                                       23730000
RBLDVRP2 EQU   *                                                        23740000
         CLI   UAPOOLNR,X'0F'          * Is the shrpool-nr low enough?? 23750000
         BH    RBLDVRP8                * No: use private pools          23760000
*                                                                       23770000
* Before inserting the shrpool-nr to be used into the plist that        23780000
* defines our bldvrp-request, the default plist must be copied to       23790000
* a location where we can modify it.                                    23800000
*                                                                       23810000
         L     R2,=AL4(BLDVRPD)        * Get address of bldvrp plist    23820000
         MVC   UAWORKAR(BLDVRDLV),0(R2) *Copy plist to be modified      23830000
         LA    R2,UAWORKAR             * And point to modifiable plist  23840000
*                                                                       23850000
         USING DSBLDVRP,R2             * Address plist by DSECT         23860000
         LA    R1,BLDVRPHD             * Point to header entry          23870000
         ST    R1,BLDVRPTR             * Insert header address in plist 23880000
         OI    BLDVRPTR,X'80'          * and mark end-of-plist          23890000
         MVC   BLDVRPNR,UAPOOLNR       * Copy shrpool-nr to be used     23900000
         DROP  R2                      * Drop addressability of plist   23910000
         BLDVRP MF=(E,(R2))            * Build vsam resource pool       23920000
         LTR   R15,R15                 * Check return code              23930000
         BZ    RBLDVRP5                * If ok: go allocate index pool  23940000
*                                                                       23950000
* If bldvrp was unsuccessful because a resource pool with the specified 23960000
* pool number already existed, then we should try another shrpool nr.   23970000
*                                                                       23980000
         CH    R15,=H'4'               * Double shrpool number ??       23990000
         BE    RBLDVRP3                * Yes: try next shrpool-nr       24000000
         CH    R15,=H'32'              * Shrpool exists in other amode? 24010000
         BNE   RBLDVRP8                * No: issue error message        24020000
*                                                                       24030000
* The shrpool number we used already exists, increment shrpoolnr and    24040000
* retry. If the shrpoolnr exceeds 15, then there are no free shrpool    24050000
* numbers and we must use private buffering in stead of LSR.            24060000
*                                                                       24070000
RBLDVRP3 EQU   *                                                        24080000
         XR    R1,R1                   * Clear register                 24090000
         IC    R1,UAPOOLNR             * to contain shrpool-nr          24100000
         LA    R1,1(R1)                * Increment shrpool number by 1  24110000
         STC   R1,UAPOOLNR             * And save it in the USERAREA    24120000
         B     RBLDVRP2                * Now go try allocate a shrpool  24130000
*                                                                       24140000
* The data resource pool has been built successfully.                   24150000
*                                                                       24160000
RBLDVRP5 EQU   *                                                        24170000
         OI    UAVRPSTA,UAVEXIST       * Indicate VRP now exists        24180000
*                                                                       24190000
* Now we must try to allocate the index pool. If it fails, it does not  24200000
* matter much, the only difference is that VSAM will be a bit slower.   24210000
* Before inserting the shrpool-nr to be used into the plist that        24220000
* defines our bldvrp-request, the default plist must be copied to       24230000
* a location where we can modify it. (same as above)                    24240000
*                                                                       24250000
         L     R2,=AL4(BLDVRPI)        * Get address of bldvrp plist    24260000
         MVC   UAWORKAR(BLDVRILV),0(R2) *Copy plist to be modified      24270000
         LA    R2,UAWORKAR             * and point to modifiable plist  24280000
         USING DSBLDVRP,R2             * Address plist by dsect         24290000
         LA    R1,BLDVRPHD             * Point to header entry          24300000
         ST    R1,BLDVRPTR             * Insert header address in plist 24310000
         OI    BLDVRPTR,X'80'          * and mark end-of-plist          24320000
         MVC   BLDVRPNR,UAPOOLNR       * Copy shrpool-nr to be used     24330000
         DROP  R2                      * Drop addressability of plist   24340000
*                                                                       24350000
* In stead of using the execute form of the bldvrp-macro, the SVC       24360000
* itself is coded. This is because the execute form of the bldvrp       24370000
* for lsr,index contains a bug, resulting in a returncode 4 in R15.     24380000
* Reason: the plist is modified incorrectly by the generated code.      24390000
* By coding the SVC in stead of the macro this problem is circumvented  24400000
*                                                                       24410000
*        BLDVRP MF=(E,UAWORKAR)        * Build VSAM resource pool       24420000
         LR    R1,R2                   * Set parm pointer for bldvrp    24430000
         SVC   19 = BLDVRP MF=(E,...)  * Build VSAM resource pool       24440000
         LTR   R15,R15                 * Check return code              24450000
         BZ    RBLDVRP9                * If ok: we're done              24460000
         ST    R15,UAVSAMRC            * Save VSAM returncode           24470000
         LA    R15,080                 * Load error code                24480000
         L     R3,=AL4(ERROR)          * Get address of error handler   24490000
         BASR  R14,R3                  * Execute it, then return here   24500000
         B     RBLDVRP9                * Then exit                      24510000
*                                                                       24520000
* Bldvrp encountered a serious error                                    24530000
*                                                                       24540000
RBLDVRP8 OI    UAVRPSTA,UAVERROR       * Indicate error status          24550000
         MVI   UAPOOLNR,X'10'          * Indicate private pools in use  24560000
         ST    R15,UAVSAMRC            * Save VSAM returncode           24570000
         LA    R15,017                 * Load error code                24580000
         L     R3,=AL4(ERROR)          * Get address of error handler   24590000
         BASR  R14,R3                  * Execute it, then return here   24600000
*                                      * And exit rbldvrp-routine       24610000
*                                                                       24620000
* The resource pool now is allocated successfully or VSAM will default  24630000
* to the use of private pools. In either case the VRP-status bits will  24640000
* have to be set.                                                       24650000
*                                                                       24660000
RBLDVRP9 EQU   *                                                        24670000
         L     R14,UALV2SAV            * Reload return address          24680000
         BR    R14                     * And return to caller (ROP)     24690000
*                                                                       24700000
         EJECT                                                          24710000
*                                                                       24720000
* RASM assembles a complete record in a workarea from the appropriate   24730000
* key and data fields in the parameter                                  24740000
*                                                                       24750000
RASM     EQU   *                       * Assemble a complete record     24760000
         ST    R14,UALV2SAV            * Save R14 level 2               24770000
*                                                                       24780000
* If we are processing a write request, we must assemble the record     24790000
* in the existing record area in the buffer. Otherwise we are           24800000
* processing either a delete or an insert request, both of which        24810000
* require the record to be assembled in a work-area.                    24820000
*                                                                       24830000
         TM    FDBREQ,FDBWRITE         * Is this a write request ??     24840000
         BNO   RASM05                  * No: go find work-area          24850000
         L     R2,FDBREC               * Get address of record          24860000
         B     RASM10                  * And skip finding work-area     24870000
*                                                                       24880000
* Get the address of the workarea to be used. If the address is zero    24890000
* then no area exists and one will have to be allocated.                24900000
*                                                                       24910000
RASM05   L     R2,FDBWAREA             * Get address of work-area       24920000
         LTR   R2,R2                   * Does it exist ??               24930000
         BNZ   RASM10                  * If it exists: skip getmain     24940000
         LH    R2,FDBRECLV             * Get required length            24950000
         GETMAIN RC,                   * Conditionally request storage *24960000
               SP=&SP,                 *    from our own subpool       *24970000
               LV=(R2)                 *    long enough for a record    24980000
         LTR   R15,R15                 * Request was ok ??              24990000
         BZ    RASM09                  * Yes: skip error                25000000
*                                                                       25010000
* A workarea for assembling the record can not be allocated. Therefore  25020000
* the insert or delete request we are processing must be aborted. This  25030000
* is done by giving the error routine the level1 return address. Thus   25040000
* error will return to the main-line (phase3) after issuing the error.  25050000
*                                                                       25060000
         LA    R15,070                 * Load error number              25070000
         L     R14,UALV1SAV            * Get return address to mainline 25080000
         L     R3,=AL4(ERROR)          * Get address of error handler   25090000
         BR    R3                      * Execute it, return to mainline 25100000
*                                                                       25110000
RASM09   EQU   *                                                        25120000
         ST    R1,FDBWAREA             * Save addr of allocated storage 25130000
         LR    R2,R1                   * Set pointer for assembly       25140000
*                                                                       25150000
         SPACE 3                                                        25160000
*                                                                       25170000
* Whether we are assembling in a work-area or in the buffer, R2         25180000
* now points to the area to be used for assembly. Before we can start   25190000
* moving data, we must first find the map-master-element for the        25200000
* parameter version that is requested.                                  25210000
*                                                                       25220000
RASM10   EQU   *                                                        25230000
         XR    R0,R0                   * Clear reg for 0 compare value  25240000
         L     R6,FDBMAP               * Get start addr of MME-list     25250000
         USING DSMME,R6                * And use DSECT for addressing   25260000
*                                                                       25270000
         AIF   (&OPT).RASM20           * Currently only 1 version / FDB 25280000
RASM12   CLC   UAVERSI,MMEVERS         * Is this the version we seek ?? 25290000
         BE    RASM20                  * Yes: go use map                25300000
         CH    R0,MMEREM               * Are there more MMEs in list ?  25310000
         BNE   RASM15                  * Yes: skip error                25320000
         LA    R15,028                 * Load error number              25330000
         L     R3,=AL4(ERROR)          * Get address of error handler   25340000
         BASR  R14,R3                  * Execute it, then return here   25350000
         B     RASM90                  * Skip remainder of assembly     25360000
*                                                                       25370000
RASM15   LA    R6,L'MME(R6)            * Address next MME               25380000
         B     RASM12                  * And check this MME             25390000
.RASM20  ANOP                                                           25400000
*                                                                       25410000
* R2 will continuously point to the start of the assembly-area.         25420000
* R6 now points to the map-master-element to be used. R7 will be used   25430000
* for addressing the consecutive map-elements to be used.               25440000
* According to the list of map-elements associated with this MME        25450000
* the data will have to be moved. R8 is used as destination pointer     25460000
* while R10 is used as source pointer. Depending on the amount of data  25470000
* associated with a map element either MVC or MVCL will be used.        25480000
*                                                                       25490000
RASM20   EQU   *                                                        25500000
         L     R7,MMEMAP               * Get start addr of map to use   25510000
         USING DSME,R7                 * And use DSECT for addressing   25520000
*                                                                       25530000
RASM22   LA    R10,BXAIOPRM            * Get start address of parm      25540000
         AH    R10,MEPRMOFS            * Add offset within parm         25550000
         LR    R8,R2                   * Get start address of record    25560000
         AH    R8,MERECOFS             * And add offset,                25570000
*                                      *     giving data-start          25580000
         LH    R9,MEDATLV              * Get length to be used          25590000
         CLI   MEDATLV,X'00'           * Is data longer than 256 bytes? 25600000
         BNE   RASM24                  * Y: too long for MVC, use MVCL  25610000
         BCTR  R9,R0                   * Decrement length by 1 for MVC  25620000
         EX    R9,RASMMVC              * And move the data              25630000
         B     RASM29                  * Go loop to next map-element    25640000
*                                                                       25650000
RASM24   LR    R1,R11                  * Save data-area pointer         25660000
         LR    R11,R9                  * Length of target = l'source    25670000
         MVCL  R8,R10                  * Copy data: parm -> workarea    25680000
         LR    R11,R1                  * Restore data-area pointer      25690000
*                                                                       25700000
RASM29   EQU   *                                                        25710000
         AIF   (&OPT).RASM90           * One ME per parm currently      25720000
         CH    R0,MEREM                * Any more elements ??           25730000
         BE    RASM90                  * No: go finish RASM             25740000
         LA    R7,L'ME(R7)             * Point next map-element         25750000
         B     RASM22                  * And go move data               25760000
.RASM90  ANOP                                                           25770000
*                                                                       25780000
RASM90   EQU   *                                                        25790000
         L     R14,UALV2SAV            * Reload return address          25800000
         BR    R14                     * And return to caller           25810000
*                                                                       25820000
         SPACE 3                                                        25830000
*                                                                       25840000
RASMMVC  MVC   0(0,R8),0(R10)          * Move a small data segment      25850000
*                                                                       25860000
         DROP  R6                      * End of addressability of MME   25870000
         DROP  R7                      * End of addressability of ME    25880000
*                                                                       25890000
         DROP  R3                      * End of addressability phase 3  25900000
FASE3END EQU   *                                                        25910000
*                                                                       25920000
         EJECT                                                          25930000
         USING PHASE4,R3                                                25940000
PHASE4   EQU   *                                                        25950000
*                                                                       25960000
* All requests have now been started: now we must wait for them         25970000
* to end to obtain returncodes for the caller.                          25980000
* Thereafter we shall finish with some concluding processing.           25990000
*                                                                       26000000
         LA    R5,UAFDBPTR             * Point to entry of FDB-chain    26010000
LOOP4    L     R5,FDBNEXT              * Make next FDB the current one  26020000
         LTR   R5,R5                   * Points nowhere: we're through  26030000
         BZ    LOOP4EX                 * If no next FDB, then exit loop 26040000
         CLI   FDBREQ,FDBNOREQ         * Anything to do for this file ? 26050000
         BE    LOOP4                   * No: try next FDB               26060000
         ST    R3,UABASSAV             * Save current base register     26070000
         L     R3,=AL4(RCHECK)         * Get address of wait routine    26080000
         BASR  R14,R3                  * Wait for I/O completion        26090000
*                                                                       26100000
* If a record was retrieved, its data contents must be copied into      26110000
* the parameter area, so the application can access the data.           26120000
*                                                                       26130000
         TM    FDBREQ,FDBREAD          * Was a read operation executed? 26140000
         BNO   LOOP4C                  * No: skip disassembly           26150000
         TM    FDBSTAT,FDBEOF          * Did we reach end-of-file ??    26160000
         BO    LOOP4C                  * Yes: skip disassembly          26170000
         TM    FDBSTAT,FDBERROR        * Was error-status raised ??     26180000
         BO    LOOP4C                  * Yes: skip disassembly          26190000
*                                                                       26200000
* If the read was random then we must check for correct key value       26210000
*                                                                       26220000
         TM    FDBSTAT,FDBACRND        * Request was random             26230000
         BNO   LOOP4DIS                * No: no need to check key       26240000
         L     R2,FDBREC               * Get addr of record just read   26250000
         LTR   R2,R2                   * Is there such a record ??      26260000
         BE    LOOP4C                  * No: skip disassembly           26270000
         AIF   (&OPT).LUP4DIS          * No need to check key           26280000
         XR    R1,R1                   * Clear register                 26290000
         IC    R1,FDBKEYLV             * to contain key length          26300000
         BCTR  R1,R0                   * Decrement by one for CLC       26310000
         EX    R1,LOOP4CLC             * Compare with correct length    26320000
         BE    LOOP4DIS                * Keys equal: disassemble        26330000
         B     LOOP4C                  * Skip disassembly of            26340000
*                                      *      erroneous record          26350000
*                                                                       26360000
LOOP4CLC CLC   0(0,R2),UAKEY           * Compare key in record          26370000
*                                      *      to key in parm            26380000
*                                                                       26390000
.LUP4DIS ANOP                                                           26400000
*                                                                       26410000
LOOP4DIS EQU   *                                                        26420000
         BAS   R14,RDISM               * Disassemble record into parm   26430000
*                                                                       26440000
         AIF   (NOT &DBG).LOOP4C                                        26450000
*                                                                       26460000
* If the read was forced by an open request, all records must be        26470000
* equal (apart from differences in length).                             26480000
*                                                                       26490000
         TM    FDBREQ,FDBOPEN          * Was open requested             26500000
         BNO   LOOP4C                  * No: skip compare               26510000
*                                                                       26520000
* First we must find start address and length of record of current FDB  26530000
*                                                                       26540000
         L     R8,FDBREC               * Get address of record          26550000
         LTR   R8,R8                   * Is it valid ??                 26560000
         BE    LOOP4C                  * No: skip this record           26570000
*                                      *    (error has been issued      26580000
*                                      *           by RDISM)            26590000
         LH    R9,FDBRECLV             * Get record length              26600000
         XR    R6,R6                   * Clear register                 26610000
         IC    R6,FDBKEYLV             * to contain key length          26620000
         LA    R8,0(R6,R8)             * Get start of data beyond key   26630000
         SR    R9,R6                   * Get length of data without key 26640000
*                                                                       26650000
* Now retrieve addr+length of record of previous FDB before overwriting 26660000
* them with addr+length of record of current FDB                        26670000
*                                                                       26680000
         L     R6,UALRECAD             * Get address of previous record 26690000
         LH    R7,UALRECLV             * Get data length of prev. rec'd 26700000
         ST    R8,UALRECAD             * Save address of last record    26710000
         STH   R9,UALRECLV             * Save data length of last rec'd 26720000
*                                                                       26730000
* If there is no record of a previous FDB, then forego comparing        26740000
*                                                                       26750000
         LTR   R6,R6                   * Previous record is defined ??  26760000
         BZ    LOOP4C                  * No: skip comparing             26770000
*                                                                       26780000
* The records are to be compared, but only for a length that is         26790000
* equal to the shortest data length.                                    26800000
*                                                                       26810000
         CR    R7,R9                   * Compare lengths                26820000
         BL    LOOP4LOW                * R7 is the shorter one          26830000
         LR    R7,R9                   * Compare using shortest length  26840000
         B     LOOP4CMP                * Go compare                     26850000
LOOP4LOW LR    R9,R7                   * R7 is the shorter one          26860000
LOOP4CMP CLCL  R6,R8                   * Compare data areas (pad=x'00') 26870000
         BE    LOOP4C                  * Equal: ok                      26880000
         LA    R15,029                 * Load error number              26890000
         L     R3,=AL4(ERROR)          * Get address of error handler   26900000
         BASR  R14,R3                  * Execute it, then return here   26910000
*                                                                       26920000
.LOOP4C  ANOP                                                           26930000
*                                                                       26940000
* If RPL has been changed for insert, it must remain so because the     26950000
* next request may well be another insert. However, if the RPL has      26960000
* been changed for delete, then the next request cannot be another      26970000
* delete, and therefore the RPL should be reset to normal right away.   26980000
*                                                                       26990000
LOOP4C   EQU   *                                                        27000000
         TM    FDBSTAT,FDBRPLDR        * RPL changed for delete ??      27010000
         BNO   LOOP4E                  * No: go check next FDB          27020000
         TM    FDBSTAT,FDBRPLIR        * RPL changed for insert ??      27030000
         BO    LOOP4E                  * Yes: let it remain so          27040000
*                                                                       27050000
* RPL has been changed for delete, not for insert: change to normal.    27060000
*                                                                       27070000
         L     R2,FDBRPL               * Get address of changed plist   27080000
         LA    R6,FDBREC               * Record address within buffer   27090000
         MODCB RPL=(R2),               * Reset RPL from delete mode    *27100000
               OPTCD=(LOC),            *  LOC in stead of MVE option   *27110000
               AREA=(S,0(R6)),         *  address of data area         *27120000
               MF=(G,UAWORKAR,MODCNDLV) * using UAWORKAR to build plist 27130000
         LTR   R15,R15                 * Modcb was ok ??                27140000
         BE    LOOP4D                  * Yes: skip error                27150000
         ST    R15,UAVSAMRC            * Save VSAM retcode              27160000
         LA    R15,063                 * Load error number              27170000
         L     R3,=AL4(ERROR)          * Get address of error handler   27180000
         BASR  R14,R3                  * Execute it, then return here   27190000
         B     LOOP4E                  * Skip resetting the RPL-status  27200000
*                                                                       27210000
LOOP4D   EQU   *                                                        27220000
         NI    FDBSTAT,FDBRPLND        * Reset RPL-status to non-delete 27230000
*                                                                       27240000
* Post-processing for this FDB is complete: fill LREQ and LKEY fields   27250000
* unless the FDBRETCD field is greater than X'04' (I/O unsuccessful)    27260000
*                                                                       27270000
LOOP4E   EQU   *                                                        27280000
         CLI   FDBRETCD,X'00'          * FDB-return code worse          27290000
*                                      *     than warning?              27300000
         BNE   LOOP4F                  * Yes: don't fill LREQ and LKEY  27310000
         MVC   FDBLREQ,FDBREQ          * I/O was concluded ok, hence    27320000
         MVC   FDBLKEY,LNSKEY          * save request and key we used   27330000
*                                                                       27340000
LOOP4F   EQU   *                                                        27350000
         AIF   (&OPT).LOOP4EX          * Only one FDB can be active     27360000
         B     LOOP4                   * Go try next FDB                27370000
*                                                                       27380000
.LOOP4EX ANOP                                                           27390000
*                                                                       27400000
LOOP4EX  EQU   *                                                        27410000
*                                                                       27420000
         EJECT                                                          27430000
*                                                                       27440000
* All I/O has been completed: if all files have been closed then        27450000
* the complete USERAREA (including FDBs) should be freed.               27460000
*                                                                       27470000
         CLC   LNSFCODE,=CL2'CA'       * Was a close request processed? 27480000
         BNE   EXIT                    * No: some files must be open    27490000
*                                                                       27500000
         AIF   (&OPT).LOOP6                                             27510000
*                                                                       27520000
* When not optimizing all FDBs of unopened files are to be removed      27530000
* before we continue.                                                   27540000
*                                                                       27550000
         LA    R5,UAFDBPTR             * Point to start of FDB-chain    27560000
         XR    R6,R6                   * Set nr of open files to 0.     27570000
LOOP5    L     R5,FDBNEXT              * Point to next FDB in chain     27580000
         LTR   R5,R5                   * End of chain ??                27590000
         BE    LOOP5EX                 * Yes: end of this loop.         27600000
         TM    FDBSTAT,FDBINPUT        * File is open ??                27610000
         BNO   LOOP5                   * No: do not count this FDB      27620000
         LA    R6,1(R6)                * Increment open-file-counter    27630000
         B     LOOP5                   * And continue with next FDB     27640000
*                                                                       27650000
* R6 now contains the number of open files. If no files are open        27660000
* all FDBs are to be freed.                                             27670000
*                                                                       27680000
LOOP5EX  EQU   *                                                        27690000
         LTR   R6,R6                   * Any open files ??              27700000
         BNE   LOOP6EX                 * Yes: skip freemains of FDBs    27710000
*                                                                       27720000
* No open files: remove and free all FDBs                               27730000
*                                                                       27740000
LOOP6    L     R5,UAFDBPTR             * Point to first FDB in chain    27750000
         LTR   R5,R5                   * Is it valid ?                  27760000
         BE    LOOP6EX                 * No: we're done                 27770000
         MVC   UAFDBPTR,FDBNEXT        * Copy addr of next FDB in chain 27780000
         FREEMAIN RC,                  * Conditionally free unused FDB *27790000
               SP=&SP,                 *    from our own subpool       *27800000
               LV=L'FDB,               *    specifying length of FDB   *27810000
               A=(R5)                  *    and its starting address    27820000
         LTR   R15,R15                 * Freemain was ok ??             27830000
         BE    LOOP6                   * Yes: go free next FDB          27840000
         LA    R15,025                 * Load error number              27850000
         L     R3,=AL4(ERROR)          * Get address of error handler   27860000
         BASR  R14,R3                  * Execute it                     27870000
         B     LOOP6                   * Then go remove next FDB        27880000
*                                                                       27890000
LOOP6EX  EQU   *                                                        27900000
*                                                                       27910000
.LOOP6   ANOP                                                           27920000
*                                                                       27930000
* Close was requested, check whether all files are currently closed.    27940000
* If any file is still open, the USERAREA cannot be freed yet.          27950000
*                                                                       27960000
         CLC   UAFDBPTR,=F'0'          * Any files still open ??        27970000
         BNE   EXIT                    * Yes: skip freeing storage      27980000
*                                                                       27990000
* Remove the VSAM resource pool, unless private pools are being used.   28000000
*                                                                       28010000
         TM    UAVRPSTA,UAVEXIST       * Does a VRP exist ??            28020000
         BNO   DLVRPOK                 * No: go pretend dlvrp was ok.   28030000
         CLI   UAPOOLNR,X'0F'          * Is LSR active ??               28040000
         BH    FREEM                   * No: we are using private pools 28050000
*                                                                       28060000
* The plist for dlvrp-request is equal to the plist for the bldvrp-req. 28070000
* Before inserting the shrpool-nr to be used into the plist that        28080000
* defines our dlvrp-request, the default plist must be copied to        28090000
* a location where we can modify it.                                    28100000
*                                                                       28110000
DLVRP2   EQU   *                                                        28120000
         L     R2,=AL4(BLDVRPD)        * Get address of plist for dlvrp 28130000
         MVC   UAWORKAR(BLDVRDLV),0(R2) *Copy plist to be modified      28140000
         LA    R2,UAWORKAR             * Point to the modifiable plist  28150000
         USING DSBLDVRP,R2             * Establish addressability       28160000
         LA    R1,BLDVRPHD             * Point to header entry          28170000
         ST    R1,BLDVRPTR             * Insert address in plist        28180000
         OI    BLDVRPTR,X'80'          * Insert end-of-plist marker     28190000
         MVC   BLDVRPNR,UAPOOLNR       * Copy shrpool-nr to be used     28200000
         DROP  R2                      * Drop addressability to plist   28210000
         DLVRP MF=(E,(R2))             * Free the VSAM resource pool    28220000
         LTR   R15,R15                 * Free was successfull ??        28230000
         BZ    DLVRPOK                 * Yes: go free USERAREA          28240000
*                                                                       28250000
* An error occurred while executing dlvrp. Warning: the returncode from 28260000
* dlvrp may be incorrect (eg. X'0C' when shrpool-nr is invalid).        28270000
*                                                                       28280000
         OI    UAVRPSTA,UAVERROR       * Set error bit                  28290000
         ST    R15,UAVSAMRC            * Save VSAM retcode              28300000
         LA    R15,018                 * Load error number              28310000
         L     R3,=AL4(ERROR)          * Get address of error handler   28320000
         BASR  R14,R3                  * Execute it, then return here   28330000
         B     FREEM                   * Skip resetting VRP-indicators  28340000
*                                                                       28350000
DLVRPOK  NI    UAVRPSTA,UAVCLOSE       * Reset status to closed         28360000
         MVI   UAPOOLNR,X'00'          * Reset shrpool-nr to default    28370000
*                                                                       28380000
* Return the USERAREA to the system                                     28390000
*                                                                       28400000
FREEM    EQU   *                                                        28410000
         AIF   (NOT &DBG).FREEM                                         28420000
*                                                                       28430000
* If snap-file is opened, then it must be closed                        28440000
*                                                                       28450000
         TM    UASTAT,UASNAPOP         * Snap-file open ??              28460000
         BNO   FREEM1                  * No: skip closing the file      28470000
         L     R2,=AL4(CLOSE)          * Point to plist for close macro 28480000
         MVC   UAWORKAR(CLOSELV),0(R2) * Copy default close-plist       28490000
         LA    R9,UAWORKAR             * and point to modifiable plist  28500000
         L     R2,UASNAPTR             * Address snap control-block     28510000
         USING DSSNAP,R2               * Establish addressability       28520000
         LA    R2,SNAPDCB              * And point to the open DCB      28530000
         DROP  R2                      * Drop snapblock                 28540000
         CLOSE ((R2)),                 * Close snap-file               *28550000
               MF=(E,(R9))             *    using copy of default plist 28560000
         LTR   R15,R15                 * Close was ok ??                28570000
         BE    FREEMA                  * Yes: continue                  28580000
         LA    R15,078                 * Load error code                28590000
         L     R3,=AL4(ERROR)          * Retrieve address of error-rout 28600000
         BASR  R14,R3                  * and execute it                 28610000
         B     FREEM2                  * Skip remainder of snap-closing 28620000
*                                                                       28630000
FREEMA   NI    UASTAT,UASNAPCL         * Set status to closed           28640000
*                                                                       28650000
FREEM1   L     R2,UASNAPTR             * Get address of snap-block      28660000
         LTR   R2,R2                   * Valid ??                       28670000
         BZ    FREEM2                  * No: skip freemain              28680000
         FREEMAIN RC,                  * Conditionally free SNAPAREA   *28690000
               SP=&SP,                 *    from our private subpool   *28700000
               LV=L'SNAPAREA,          *    specifying correct length  *28710000
               A=(R2)                  *    and starting address        28720000
         LTR   R15,R15                 * Freemain was ok??              28730000
         BE    FREEM1A                 * Yes: skip error                28740000
         LA    R15,079                 * Load error code                28750000
         L     R3,=AL4(ERROR)          * Retrieve address of error-rout 28760000
         BASR  R14,R3                  * and execute it                 28770000
         B     FREEM2                  * Skip remainder of snap-closing 28780000
*                                                                       28790000
FREEM1A  XC    UASNAPTR,UASNAPTR       * Yes: wipe pointer              28800000
*                                                                       28810000
.FREEM   ANOP                                                           28820000
*                                                                       28830000
FREEM2   C     R13,=AL4(CRASHMEM+8)    * Using the emergency area ??    28840000
         BE    EXIT                    * Yes: skip freemain             28850000
         LH    R10,UAREASN             * Save retcode for application   28860000
         MVC   LNSRCODE,UARETCD        * Set returncode in parameter    28870000
         LR    R2,R13                  * Save address of USERAREA       28880000
         L     R13,SAVEPREV(R13)       * Reset R13 to previous savearea 28890000
         FREEMAIN RC,                  * Conditionally free USERAREA   *28900000
               SP=&SP,                 *    from our private subpool   *28910000
               A=(R2),                 *    specifying starting address*28920000
               LV=L'USERAREA           *    and full length             28930000
         LTR   R15,R15                 * Freemain was successfull ??    28940000
         BZ    FREEM10                 * Yes: last housekeeping         28950000
         LA    R15,025                 * Load error number              28960000
         L     R3,=AL4(ERROR)          * Get address of error handler   28970000
         BASR  R14,R3                  * Execute it, then return here   28980000
*                                      * USERAREA is now in crashmem !! 28990000
         LH    R10,UAREASN             * Save new returncode            29000000
         MVC   LNSRCODE,UARETCD        * Set new retcode in parameter   29010000
         L     R13,SAVEPREV(R13)       * Reset R13 to previous savearea 29020000
         XR    R15,R15                 * Simulate correct freemain      29030000
*                                                                       29040000
* Storage has been freed, since register 13 has already been reloaded   29050000
* we must skip reloading register 13, or we would skip one level of     29060000
* returning.                                                            29070000
*                                                                       29080000
FREEM10  EQU   *                                                        29090000
         L     R1,SAVEDR1(R13)         * Reload original plist-pointer  29100000
         L     R2,4(R1)                * Get address of 2nd parameter   29110000
         USING DS83PRM2,R2             * Address parameter 2 by R2      29120000
         ST    R15,LNSUAPTR            * Reset LNSUAPTR in parm         29130000
         DROP  R2                                                       29140000
         B     EXIT99                  * And go return to caller        29150000
*                                                                       29160000
EXIT     EQU   *                                                        29170000
         LH    R10,UAREASN             * Load retcode for application   29180000
         MVC   LNSRCODE,UARETCD        * Set returncode in parameter    29190000
         C     R13,=AL4(CRASHMEM+8)    * When using emergency memory    29200000
         BE    EXITUNLK                *    for our userarea            29210000
         C     R4,=AL4(CRASHMEM+8)     * or for our parameter           29220000
         BNE   EXIT90                  * then remove lock:              29230000
*                                                                       29240000
EXITUNLK L     R4,=AL4(CRASHMEM)       * Get address of lock-word       29250000
         XC    0(4,R4),0(R4)           * Remove lock                    29260000
*                                                                       29270000
EXIT90   L     R13,SAVEPREV(R13)       * Reset R13 to previous savearea 29280000
*                                                                       29290000
EXIT99   EQU   *                                                        29300000
         LR    R15,R10                 * Set correct reasoncode         29310000
*                                      *        for application         29320000
         L     R14,SAVEDR14(R13)       * Reload return-addr to caller   29330000
         LM    R0,R12,SAVEDR0(R13)     * Reload all regs for caller     29340000
         BSM   0,R14                   * And return to caller with      29350000
*                                      *           return code in R15   29360000
         EJECT                                                          29370000
*                                                                       29380000
* Rdism disassembles a record from the VSAM-I/O-buffer to the           29390000
* appropriate key- and data-fields in the parameter.                    29400000
*                                                                       29410000
RDISM    EQU   *                       * Assemble a complete record     29420000
         ST    R14,UALV2SAV            * Save R14 level 2               29430000
*                                                                       29440000
* Get the address of the last record read within the buffer.            29450000
*                                                                       29460000
         L     R6,FDBREC               * Get address of record in buf   29470000
         LTR   R6,R6                   * Check the address              29480000
         BNZ   RDISM10                 * If it exists: skip error       29490000
         LA    R15,057                 * Load error number              29500000
         L     R3,=AL4(ERROR)          * Get address of error handler   29510000
         BASR  R14,R3                  * Execute it, then return here   29520000
         B     RDISM90                 * Skip remainder of this routine 29530000
*                                                                       29540000
* First we must find the map to be used in the list of                  29550000
*       map-master-elements                                             29560000
*                                                                       29570000
RDISM10  EQU   *                                                        29580000
         XR    R0,R0                   * Clear reg for 0 compare value  29590000
         L     R6,FDBMAP               * Get start addr of mme-list     29600000
         USING DSMME,R6                * Use DSECT MME for addressing   29610000
*                                                                       29620000
         AIF   (&OPT).RDISM20          * Currently only 1 version / FDB 29630000
RDISM12  CLC   UAVERSI,MMEVERS         * Is this the version we seek ?? 29640000
         BE    RDISM20                 * Yes: go use map                29650000
         CH    R0,MMEREM               * Any more MMEs in list ?        29660000
         BNE   RDISM15                 * Yes: skip error                29670000
         LA    R15,028                 * Load error number              29680000
         L     R3,=AL4(ERROR)          * Get address of error handler   29690000
         BASR  R14,R3                  * Execute it, then return here   29700000
         B     RDISM90                 * Skip remainder of disassembly  29710000
*                                                                       29720000
RDISM15  LA    R6,L'MME(R6)            * Address next MME               29730000
         B     RDISM12                 * And check this MME             29740000
*                                                                       29750000
.RDISM20 ANOP                                                           29760000
*                                                                       29770000
* R6 now points to the map-master-element. R7 will be used for          29780000
* addressing the contiguous map-elements. R8 will be used as a source   29790000
* pointer, R10 will serve as a destination pointer. Depending on the    29800000
* amount of data being moved either MVC or MVCL will be used.           29810000
*                                                                       29820000
RDISM20  EQU   *                                                        29830000
         L     R7,MMEMAP               * Get start addr of map to use   29840000
         USING DSME,R7                 * And use DSECT for addressing   29850000
*                                                                       29860000
RDISM22  LA    R10,BXAIOPRM            * Get start address of parameter 29870000
         AH    R10,MEPRMOFS            * Add offset within parm         29880000
         L     R8,FDBREC               * Get start address of record    29890000
         AH    R8,MERECOFS             * Add offset, giving data-start  29900000
         LH    R9,MEDATLV              * Get length to be used          29910000
         CLI   MEDATLV,X'00'           * Is data longer than 256 bytes? 29920000
         BNE   RDISM24                 * Y: too long for MVC, use MVCL  29930000
         BCTR  R9,R0                   * Decrement length by 1 for MVC  29940000
         EX    R9,RDISMMVC             * Execute move with this length  29950000
         B     RDISM29                 * Go loop to next map-element    29960000
*                                                                       29970000
RDISM24  LR    R1,R11                  * Save data-area pointer         29980000
         LR    R11,R9                  * Length of target = l'source    29990000
         MVCL  R10,R8                  * Copy data from record to parm  30000000
         LR    R11,R1                  * Restore data-area pointer      30010000
*                                                                       30020000
RDISM29  EQU   *                                                        30030000
         AIF   (&OPT).RDISM30          * Currently only one ME per MME  30040000
         CH    R0,MEREM                * Any more elements ??           30050000
         BE    RDISM30                 * No: go finish RDISM            30060000
         LA    R7,L'ME(R7)             * Point next map-element         30070000
         B     RDISM22                 * And go move data               30080000
*                                                                       30090000
.RDISM30 ANOP                                                           30100000
*                                                                       30110000
RDISM30  EQU   *                       * Move key from rec to LNSKEY    30120000
         L     R8,FDBREC               * Get source address             30130000
         LA    R10,LNSKEY              * Get destination address        30140000
         XR    R9,R9                   * Clear register                 30150000
         IC    R9,FDBKEYLV             *       to contain key length    30160000
         BCTR  R9,R0                   * Decrement length by 1 for MVC  30170000
         EX    R9,RDISMMVC             * And move key to parm-area      30180000
*                                                                       30190000
RDISM90  EQU   *                                                        30200000
         L     R14,UALV2SAV            * Reload return address          30210000
         BR    R14                     * Return to caller               30220000
*                                                                       30230000
         SPACE 3                                                        30240000
*                                                                       30250000
RDISMMVC MVC   0(0,R10),0(R8)          * Move a small segment to parm   30260000
*                                                                       30270000
         DROP  R6                      * End of addressability of MME   30280000
         DROP  R7                      * End of addressability of ME    30290000
*                                                                       30300000
         DROP  R3                      * End of addressability phase 4  30310000
*                                                                       30320000
FASE4END EQU   *                                                        30330000
*                                                                       30340000
         EJECT                                                          30350000
         USING RCHECK,R3                                                30360000
*                                                                       30370000
* RCHECK issues a check macro against the current FDB (R5)              30380000
*                                                                       30390000
RCHECK   EQU   *                       * Wait for I/O completion        30400000
         ST    R14,UALV2SAV            * Save R14 level 2               30410000
*                                                                       30420000
* If the ECB is currently unused a check is quite useless.              30430000
*                                                                       30440000
         L     R1,FDBECB               * Load current contents of ECB   30450000
         LTR   R1,R1                   * See if any I/O is in progress  30460000
         BZ    RCHECK99                * No: return immediate           30470000
*                                                                       30480000
* Now we must wait until VSAM has completed the I/O and has executed    30490000
* all the exits required. First we will increment the IO-call counter.  30500000
*                                                                       30510000
         AIF   (&OPT).CHECK15                                           30520000
         L     R2,UAIOCNT              * Load total io-count            30530000
         LA    R2,1(R2)                * Increment by one               30540000
         ST    R2,UAIOCNT              * And store updated value        30550000
*                                                                       30560000
.CHECK15 L     R7,FDBRPL               * Get address of RPL to be used  30570000
         CHECK RPL=(R7)                * Wait until I/O & exits are     30580000
*                                      *              complete          30590000
RCHECK15 LTR   R15,R15                 * Check return code              30600000
         BZ    RCHECK30                * If ok: skip error handling     30610000
         ST    R15,UAVSAMRC            * Save retcode for error handler 30620000
         LA    R15,064                 * Load error code                30630000
         L     R3,=AL4(ERROR)          * Get address of error handler   30640000
         BASR  R14,R3                  * Execute it, then return here   30650000
*                                                                       30660000
* VSAM has completed the I/O and the exits. Check the ECB-returncode    30670000
* for errors.                                                           30680000
*                                                                       30690000
RCHECK30 EQU   *                                                        30700000
         NI    FDBECB,X'00'            * Wipe event bits in ECB         30710000
         L     R1,FDBECB               * Load returncode from ECB       30720000
         LTR   R1,R1                   * Test value of returncode       30730000
         BZ    RCHECK40                * Returncode zero: skip error    30740000
         OI    FDBSTAT,FDBERROR        * Indicate error status for file 30750000
         ST    R1,UAVSAMRC             * Save retcode for error handler 30760000
         LA    R15,065                 * Load error code                30770000
         L     R3,=AL4(ERROR)          * Get address of error handler   30780000
         BASR  R14,R3                  * Execute it, then return here   30790000
*                                                                       30800000
* If a get was executed, then the FDB is to be updated with the current 30810000
* buffer description.                                                   30820000
*                                                                       30830000
RCHECK40 EQU   *                                                        30840000
         USING IFGRPL,R7               * R7 still contains RPL-address  30850000
*                                                                       30860000
         CLI   RPLREQ,RPLGET           * Was a get executed ??          30870000
         BNE   RCHECK50                * No: skip updating the FDB      30880000
         NI    FDBSTAT,FDBBUFNU        * Buffer not marked for output   30890000
         CLI   FDBRETCD,X'00'          * File in error status ??        30900000
         BNE   RCHECK45                * Yes: do not update FDB         30910000
         L     R6,RPLPLHPT             * Get addr of placeholder        30920000
         USING IDAPLH,R6               * Address placeholder by DSECT   30930000
*                                                                       30940000
         CLC   FDBREC,PLHRECP          * Record pointer in FDB = PLH ?? 30950000
         BNE   RCHECK48                * No: issue error                30960000
         MVC   FDBSBUF,PLHRECP         * Copy current record pointer    30970000
         MVC   FDBEBUF,PLHFSP          * Copy free space pointer        30980000
         B     RCHECK90                * Get-request has been handled   30990000
*                                                                       31000000
         DROP  R6                      * End of addressability to PLH   31010000
         DROP  R7                      * End of addressability to RPL   31020000
*                                                                       31030000
* FDB  contains errorcode, therefore the FDBREC field must be           31040000
* reset to zero. Thus the next read request will cause a get,           31050000
* which may then retrieve a valid buffer.                               31060000
*                                                                       31070000
RCHECK45 XC    FDBREC,FDBREC           * Set current record to invalid  31080000
         B     RCHECK90                * And go return to mainline      31090000
*                                                                       31100000
RCHECK48 EQU   *                       * Record address mismatch        31110000
         LA    R15,073                 * Load error number              31120000
         L     R3,=AL4(ERROR)          * Get address of error handler   31130000
         BASR  R14,R3                  * Execute error, return here     31140000
         B     RCHECK90                * Checking complete              31150000
*                                                                       31160000
* If a point has been completed (seq. access) then the FDB must be      31170000
* updated to reflect the current buffer.                                31180000
*                                                                       31190000
RCHECK50 EQU   *                                                        31200000
         USING IFGRPL,R7               * R7 still contains RPL-address  31210000
*                                                                       31220000
         CLI   RPLREQ,RPLPOINT         * Was a skip executed ??         31230000
         BNE   RCHECK90                * No: skip updating the FDB      31240000
         NI    FDBSTAT,FDBBUFNU        * Buffer not marked for output   31250000
         CLI   FDBRETCD,X'00'          * File in error status ??        31260000
         BNE   RCHECK90                * Then do not update FDB         31270000
         L     R6,RPLPLHPT             * Get address of placeholder     31280000
         USING IDAPLH,R6               * Address placeholder by DSECT   31290000
*                                                                       31300000
         MVC   FDBSBUF,PLHRECP         * Copy current record pointer    31310000
         MVC   FDBEBUF,PLHFSP          * Copy free space pointer        31320000
         XC    FDBREC,FDBREC           * Invalidate current record ptr  31330000
*                                      *    (record not yet read)       31340000
         DROP  R6                      * End of addressability to PLH   31350000
         DROP  R7                      * End of addressability to RPL   31360000
*                                                                       31370000
RCHECK90 EQU   *                                                        31380000
         XR    R0,R0                   * Clear register to wipe ECB     31390000
         ST    R0,FDBECB               * ECB now available for reuse    31400000
*                                                                       31410000
RCHECK99 EQU   *                                                        31420000
         L     R14,UALV2SAV            * Reload return address          31430000
         L     R3,UABASSAV             * Retrieve caller's base address 31440000
         BR    R14                     * And return immmediate          31450000
*                                                                       31460000
         DROP  R3                                                       31470000
*                                                                       31480000
RCHEKEND EQU   *                                                        31490000
*                                                                       31500000
         EJECT                                                          31510000
*                                                                       31520000
&ERR     SETB  1                       * Assembling error-routine       31530000
         USING ERROR,R3                                                 31540000
*                                                                       31550000
* Error handler and error exit routines                                 31560000
* Since R10 is used as a pointer to the error, it should not be changed 31570000
* by any exit routine                                                   31580000
* No storing into memory may take place, before the error exit has      31590000
* been executed. Therefore the error exit should save both R14, which   31600000
* contains the return address to error, and R0, which contains the      31610000
* error's own return address.                                           31620000
*                                                                       31630000
ERROR    EQU   *                       * Entry to error routine         31640000
         L     R1,=AL4(ERRORTAB)       * Start of error table           31650000
         BCTR  R15,R0                  * Decrement error number         31660000
*                                      *       to get offset number     31670000
         SLA   R15,6                   * Multiply offset number         31680000
*                                      *       by element length        31690000
*                                      *       to get byte offset       31700000
         LA    R10,0(R15,R1)           * Get address of error element   31710000
         CR    R10,R1                  * Entry too low ??               31720000
         BL    ERRORXX                 * Yes: unidentified error        31730000
         C     R10,=AL4(ERRORTND)      * Entry too high ??              31740000
         BL    ERRORDO                 * No: start error handling       31750000
*                                                                       31760000
ERRORXX  L     R10,=AL4(ERRORTND)      * Default to unidentified error  31770000
         USING DSERR,R10               * Use register for addressing    31780000
*                                                                       31790000
ERRORDO  EQU   *                                                        31800000
         L     R15,ERRROUT             * Load error exit address        31810000
         LTR   R15,R15                 * Is an exit to be taken ??      31820000
         BZ    ERRORNOT                * If zero, skip exit             31830000
         LR    R1,R0                   * Save reasoncode that           31840000
*                                      *      may be present in R0      31850000
         LR    R0,R14                  * Copy return address            31860000
         BASR  R14,R15                 * Execute error exit             31870000
         B     ERRORFDB                * Exit must store R0 in uaerrsav 31880000
*                                      * (since user area may           31890000
*                                      *            not exist yet)      31900000
ERRORNOT EQU   *                                                        31910000
         ST    R14,UAERRSAV            * Save return address            31920000
*                                                                       31930000
ERRORFDB EQU   *                                                        31940000
         CLI   ERRFDBCD,X'00'          * Error for FDB ??               31950000
         BE    ERRORRCD                * No: continue with retcd/reasn  31960000
         CLC   ERRFDBCD,FDBRETCD       * More serious than last error?? 31970000
         BNH   ERRORRCD                * No: continue with retcd/reasn  31980000
         MVC   FDBRETCD,ERRFDBCD       * Copy error code                31990000
         MVC   FDBREASN,ERRREASN       * And reason code                32000000
*                                                                       32010000
ERRORRCD EQU   *                                                        32020000
         CLI   ERRRETCD,X'00'          * Error for USERAREA ??          32030000
         BE    ERRORWTO                * Yes: go check exit             32040000
         CLC   ERRRETCD,UARETCD        * Error more serious than last?  32050000
         BNH   ERRORWTO                * No: go take exit               32060000
         MVC   UARETCD,ERRRETCD        * Copy returncode                32070000
         MVC   UAREASN,ERRREASN        * And reasoncode                 32080000
*                                                                       32090000
ERRORWTO EQU   *                                                        32100000
         CLI   ERRTEXT,C' '            * Message exists ??              32110000
         BE    ERROREX                 * No: skip WTOs                  32120000
         L     R2,=AL4(ERRWTO)         * Get address of WTO plist       32130000
         MVC   UAWORKAR(ERRWTOLV),0(R2) *Copy default WTO-plist         32140000
         LA    R2,UAWORKAR             * Get addr of modifiable plist   32150000
         MVI   4(R2),C' '              * Set first blank                32160000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Clear WTO-message              32170000
         MVC   4(8,R2),=C'BXAIO - '    * Set message prefix             32180000
         MVC   12(L'ERRTEXT,R2),ERRTEXT *Set message text               32190000
         WTO   MF=(E,(R2))             * And execute WTO                32200000
         MVI   4(R2),C' '              * Set first blank                32210000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Clear WTO-message              32220000
         AIF   (&OPT AND (NOT &DBG)).ERROR10                            32230000
         L     R14,UACALLNR            * Retrieve call-count            32240000
         BAS   R1,TOHEX                * Convert to hexadecimal         32250000
         MVC   54(8,R2),4(R2)          * Copy call-count to message     32260000
         MVC   40(14,R2),=CL14'  Call-count: '                          32270000
*                                                                       32280000
.ERROR10 MVC   12(L'LNSPARM,R2),LNSPARM *Set message text               32290000
         MVC   4(8,R2),=C'PARM IS:'    * Set message prefix             32300000
         WTO   MF=(E,(R2))             * And execute WTO                32310000
*                                                                       32320000
ERROREX  EQU   *                                                        32330000
         ESNAP ,                       * Also execute snap-rout         32340000
         LH    R15,ERRREASN            * Load reasoncode                32350000
         L     R14,UAERRSAV            * Retrieve return/retry address  32360000
         L     R3,=AL4(RSETBASE)       * Get addr of rsetbase-routine   32370000
         BR    R3                      * To return to caller            32380000
*                                                                       32390000
         DROP  R10                     * End of addressability to       32400000
*                                      *           ERRORTAB             32410000
         EJECT                                                          32420000
*                                                                       32430000
* Routine for handling errors when the USERAREA may not exist           32440000
*                                                                       32450000
UAERR    EQU   *                       * Exit-routine of error-rout.    32460000
*                                                                       32470000
* R14 contains return address into error-routine, R0 contains           32480000
* error's return address in turn. R3 and R11 are sure to be valid.      32490000
* R13 may point to our USERAREA, or it may point to the caller's        32500000
* savearea. the parameter may or may not be addressable.                32510000
*                                                                       32520000
         C     R11,SAVEDR11(R13)       * Is USERAREA-pointer valid ??   32530000
         BE    UAERRSVE                * Yes: go save regs in USERAREA  32540000
*                                                                       32550000
* No USERAREA exists. therefore we shall use the emergency area         32560000
* provided in this program. First we must lock it to prevent            32570000
* concurrency errors to occur over and above the error detected.        32580000
*                                                                       32590000
         L     R2,=AL4(CRASHMEM)       * Get addr of emergency storage  32600000
*                                                                       32610000
UAERRLOK L     R15,0(R2)               * Get contents of lock-word      32620000
         LTR   R15,R15                 * Lock = zero ??                 32630000
         BNE   UAERRLOK                * No: storage is being used      32640000
         LA    R1,1                    * Get new lock-value             32650000
         CS    R15,R1,0(R2)            * Update lock in storage         32660000
         BNZ   UAERRLOK                * If locked by someone else:     32670000
*                                      *        go retry                32680000
         LA    R2,8(R2)                * Point beyond lock-word         32690000
         ST    R13,SAVEPREV(R2)        * Set pointer to prev. savearea  32700000
         LR    R13,R2                  * And establish new USERAREA     32710000
*                                                                       32720000
* R13 now points to our own USERAREA.                                   32730000
*                                                                       32740000
UAERRSVE ST    R0,UAERRSAV             * Save first-level return addr   32750000
         ST    R14,UAERXSAV            * Save error-exit return address 32760000
         ST    R11,SAVEDR11(R13)       * Mark this SAVEAREA as our own  32770000
*                                                                       32780000
* Now retrieve the address of the input parameter to check whether      32790000
* or not it is valid                                                    32800000
*                                                                       32810000
         L     R1,SAVEPREV(R13)        * Get addr of previous savearea  32820000
         LTR   R1,R1                   * Valid ??                       32830000
         BZ    UAERRPRM                * No: go use emergency storage   32840000
         L     R1,SAVEDR1(R1)          * Get original contents of R1    32850000
         LTR   R1,R1                   * Is it a valid plist pointer ?? 32860000
         BZ    UAERRPRM                * No: use emergency storage      32870000
         TM    4(R1),X'80'             * End-of-plist-marker is there ? 32880000
         BNO   UAERRPRM                * No: plist is in error          32890000
         L     R4,0(R1)                * Get first word of plist        32900000
         LA    R4,0(R4)                * Strip end-of-plist bits        32910000
         LTR   R4,R4                   * Valid address ??               32920000
         BNZ   UAERRRET                * Yes: parameter found, return   32930000
*                                                                       32940000
* No parameter to be found. Use CRASHMEM as a substitute                32950000
*                                                                       32960000
UAERRPRM EQU   *                                                        32970000
         LR    R4,R13                  * Copy USERAREA address          32980000
         C     R4,=AL4(CRASHMEM+8)     * Are we using CRASHMEM ??       32990000
         BE    UAERRRET                * Yes: go return to error        33000000
*                                                                       33010000
* Userarea was valid. Now try to gain control over CRASHMEM.            33020000
*                                                                       33030000
         L     R2,=AL4(CRASHMEM)       * Get addr of emergency storage  33040000
*                                                                       33050000
UAERRLOC L     R15,0(R2)               * Get contents of lock-word      33060000
         LTR   R15,R15                 * Lock = zero ??                 33070000
         BNE   UAERRLOC                * No: storage is being used      33080000
         LA    R1,1                    * Get new lock-value             33090000
         CS    R15,R1,0(R2)            * Update lock in storage         33100000
         BNZ   UAERRLOC                * If locked by someone else      33110000
*                                      *      go retry                  33120000
         LA    R4,8(R2)                * Point beyond lock-word         33130000
*                                                                       33140000
* Now both R4 and R13 are valid pointers to an input parameter          33150000
* and to a USERAREA.                                                    33160000
*                                                                       33170000
UAERRRET EQU   *                                                        33180000
         L     R14,UAERXSAV            * Reload return address          33190000
         BR    R14                     * And continue error proc.       33200000
*                                                                       33210000
         EJECT                                                          33220000
*                                                                       33230000
* Routine for analyzing logical errors during VSAM execution            33240000
*                                                                       33250000
LGERR    EQU   *                       * Exit to error routine          33260000
         ST    R0,UAERRSAV             * Save return address of error   33270000
         ST    R14,UAERXSAV            * Save return address to error   33280000
*                                                                       33290000
* First we must check the UAVSAMRC for its value. If it is 8 VSAM       33300000
* detected a logical error while executing a request. The reasoncode    33310000
* is to be extracted from the RPL. According to the reasoncode a        33320000
* specific error message should be issued. If the return code is 12     33330000
* a physical I/O-error occurred, and an appropriate error message       33340000
* should be issued. If the RPL-address is invalid, no error can be      33350000
* issued.                                                               33360000
*                                                                       33370000
         L     R2,FDBRPL               * Get address of RPL             33380000
         LTR   R2,R2                   * Is it valid ??                 33390000
         BZ    LGERREX                 * No: quit this exit-routine     33400000
         USING IFGRPL,R2               * Address RPL by R2              33410000
*                                                                       33420000
         CLC   UAVSAMRC,=F'8'          * Returncode = 8 ??              33430000
         BE    LGERR001                * Yes: handle the logical error  33440000
         CLC   UAVSAMRC,=F'12'         * Returncode = 12 ??             33450000
         BNE   LGERREX                 * No: quit this exit-rout.       33460000
         LA    R15,067                 * Load physical error number     33470000
         B     LGERRGO                 * And restart the error-handler  33480000
*                                                                       33490000
* R14 and R15 will designate start and end of the table to be           33500000
* searched for the reason code. R14 will be used as a pointer to the    33510000
* current table elememnt.                                               33520000
*                                                                       33530000
LGERR001 L     R14,=AL4(LGERRTAB)      * Start of logical error table   33540000
         USING DSLGERR,R14             * Establish R14 as pointer       33550000
*                                                                       33560000
LGERRLUP CLC   LGREASON,RPLERRCD       * Compare RPL-condition-code     33570000
         BE    LGERRDO                 * This is the element we seek    33580000
         LA    R14,L'LGERRELM(R14)     * Point to next table element    33590000
         C     R14,=AL4(LGTABEND)      * Past end-of-table ??           33600000
         BNH   LGERRLUP                * No: go check this code         33610000
         B     LGERREX                 * Y: use default error handling  33620000
*                                                                       33630000
* We found the reasoncode in our table. Therefore we can now load the   33640000
* correct error code. Then we should restart the error-routine with     33650000
* the error-code we found. Thus the error we just found will be issued  33660000
* in stead of the global error text, that serves as a default.          33670000
*                                                                       33680000
LGERRDO  EQU   *                                                        33690000
         LH    R15,LGERCODE            * Get the error number to use    33700000
         CH    R15,=H'001'             * Is it error nr 001 ? (eof)     33710000
         BNE   LGERRGO                 * No: go re-do error handler     33720000
         OI    FDBSTAT,FDBEOF          * Yes: indicate eof in FDB       33730000
*                                                                       33740000
LGERRGO  L     R14,UAERRSAV            * Reload return address          33750000
         LR    R0,R1                   * Reload original VSAM-reasncode 33760000
         B     ERROR                   * Now execute error for the new  33770000
*                                      *     error-number               33780000
         DROP  R2                      * R2 used to address RPL         33790000
*                                                                       33800000
* The default error message is to be used. Before returning to error    33810000
* the VSERR error exit should be executed to dump VSAM information.     33820000
* This is done by branching to VSERR as if it were called by error.     33830000
*                                                                       33840000
LGERREX  L     R14,UAERXSAV            * Reload return address to error 33850000
         L     R0,UAERRSAV             * Reload return addr from error  33860000
         B     VSERR                   * And continue with vserr        33870000
*                                                                       33880000
         DROP  R14                     * Reasoncode-table not           33890000
*                                      *           needed anymore       33900000
         EJECT                                                          33910000
*                                                                       33920000
* Routine for dumping VSAM information after an error occurred          33930000
*                                                                       33940000
VSERR    EQU   *                       * Exit to error routine          33950000
         ST    R0,UAERRSAV             * Save return address of error   33960000
         ST    R14,UAERXSAV            * Save return address to error   33970000
*                                                                       33980000
         USING DSERR,R10               * Points current error element   33990000
         CLI   ERRTEXT,C' '            * Display error info ??          34000000
         BE    VSERREX                 * No: quit this exit             34010000
*                                                                       34020000
         DROP  R10                     * ERRORTAB no longer needed      34030000
*                                                                       34040000
* First we dump VSAM return- and reason codes (R15 and R0, resp.)       34050000
*                                                                       34060000
         L     R2,=AL4(ERRWTO)         * Retrieve address of blank WTO  34070000
         MVC   UAWORKAR(ERRWTOLV),0(R2) *Copy blank WTO to workarea     34080000
         LA    R2,UAWORKAR             * Now point to modifiable WTO    34090000
         MVI   4(R2),C' '              * Set blank in 1st text position 34100000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Wipe default text              34110000
         LR    R14,R1                  * Reason code was copied to R1   34120000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34130000
         MVC   50(8,R2),4(R2)          * and move to correct location   34140000
         MVC   29(21,R2),=CL21' while reasoncode is '                   34150000
         L     R14,UAVSAMRC            * Retrieve VSAM returncode       34160000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34170000
         MVC   21(8,R2),4(R2)          * and move to correct location   34180000
         MVC   4(17,R2),=CL17'VSAM returncode: ' insert preceding text  34190000
         WTO   MF=(E,(R2))             * and display information        34200000
*                                                                       34210000
* Before dumping ACB and RPL data we must ensure that R5, our           34220000
* FDB-pointer, is currently valid.                                      34230000
*                                                                       34240000
         LA    R1,UAFDBPTR             * Point start of FDB-chain       34250000
*                                                                       34260000
VSERRLUP L     R1,0(R1)  0(R1)=FDBNEXT * Get address of next FDB        34270000
         LTR   R1,R1                   * Is it valid ??                 34280000
         BZ    VSERRERR                * No: R5 matches no FDB on chain 34290000
         CR    R1,R5                   * FDB-pointer points this FDB ?? 34300000
         BNE   VSERRLUP                * No: try next FDB               34310000
         B     VSERRACB                * Yes: FDB-ptr is valid: dump    34320000
*                                                                       34330000
VSERRERR EQU   *                                                        34340000
         MVI   4(R2),C' '              * Set blank in 1st text position 34350000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Wipe default text              34360000
         LR    R14,R5                  * Retrieve FDB-address           34370000
         BAS   R1,TOHEX                * Dump invalid FDB-pointer       34380000
         MVC   29(20,R2),=CL20' is not on FDB-chain' insert error text  34390000
         MVC   21(8,R2),4(R2)          * Move to correct location       34400000
         MVC   4(17,R2),=CL17'VSERR:    FDB at ' add preceding text     34410000
         WTO   MF=(E,(R2))             * and display information        34420000
         B     VSERREX                 * Exit this error-exit           34430000
*                                                                       34440000
* Now dump ACB-data if present                                          34450000
*                                                                       34460000
VSERRACB EQU   *                                                        34470000
         MVI   4(R2),C' '              * Set blank in 1st text position 34480000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Wipe default text              34490000
         L     R15,FDBACB              * Retrieve address of ACB        34500000
         LTR   R15,R15                 * Is it valid ??                 34510000
         BZ    VSERRRPL                * No: skip dumping ACB-data      34520000
         LR    R2,R15                  * Copy ACB-addr to usable reg.   34530000
         SHOWCB ACB=(R2),              * Retrieve info from current ACB*34540000
               FIELDS=(ERROR),         *    copy error-code            *34550000
               AREA=(S,UAVSAMRC),      *    into UAVSAMRC field        *34560000
               LENGTH=4,               *    length of field = 4        *34570000
               MF=(G,UAWORKAR+ERRWTOLV,SHOWACLV) use UAWORKAR for plist 34580000
         LA    R2,UAWORKAR             * Point to workarea again        34590000
         LTR   R15,R15                 * Was showcb ok ??               34600000
         BZ    VSERRAC2                * Yes: dumping is ok             34610000
         MVC   50(8,R2),=CL8'*UNKNOWN' * Error-text                     34620000
         B     VSERRAC3                * Continue dumping VASM-info     34630000
*                                                                       34640000
VSERRAC2 L     R14,UAVSAMRC            * Get reasoncode from ACB        34650000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34660000
         MVC   50(8,R2),4(R2)          * and move to correct location   34670000
*                                                                       34680000
VSERRAC3 MVC   29(21,R2),=CL21' contains reasoncode ' add error text    34690000
         L     R14,FDBACB              * Retrieve ACB-address           34700000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34710000
         MVC   21(8,R2),4(R2)          * and move to correct location   34720000
         MVC   12(9,R2),=CL9': ACB at ' * Insert preceding text         34730000
         MVC   4(8,R2),FDBDDNAM        * Add ddname of file in error    34740000
         WTO   MF=(E,(R2))             * and display information        34750000
*                                                                       34760000
* Now dump RPL-data if present                                          34770000
*                                                                       34780000
VSERRRPL EQU   *                                                        34790000
         MVI   4(R2),C' '              * Set blank in 1st text position 34800000
         MVC   5(L'WTOTEXT-1,R2),4(R2) * Wipe default text              34810000
         L     R15,FDBRPL              * Retrieve address of RPL        34820000
         LTR   R15,R15                 * Is it valid ??                 34830000
         BZ    VSERREX                 * No: quit dumping               34840000
*                                                                       34850000
         USING IFGRPL,R15              * Temp. addressability to RPL    34860000
         MVC   UAVSAMRC,RPLFDBWD       * Copy feedback word from RPL    34870000
         DROP  R15                     * Quit RPL-addressability        34880000
         L     R14,UAVSAMRC            * Get reasoncode from RPL        34890000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34900000
         MVC   50(8,R2),4(R2)          * and move to correct location   34910000
         MVC   29(21,R2),=CL21' contains fdbk-code  ' Add error text    34920000
*                                                                       34930000
         L     R14,FDBRPL              * Retrieve ACB-address           34940000
         BAS   R1,TOHEX                * Dump reasoncode, retadr in R1  34950000
         MVC   21(8,R2),4(R2)          * And move to correct location   34960000
         MVC   12(9,R2),=CL9': RPL at ' *Insert preceding error text    34970000
         MVC   4(8,R2),FDBDDNAM        * Add DDNAME of file in error    34980000
         WTO   MF=(E,(R2))             * and display information        34990000
*                                                                       35000000
VSERREX  L     R14,UAERXSAV            * Retrieve return address        35010000
         BR    R14                     * And return to error handler    35020000
*                                                                       35030000
         EJECT                                                          35040000
*                                                                       35050000
* TOHEX assumes a WTO in list form at (R2), the fullword to be dumped   35060000
* is in register 14, and will be put in the WTO at positions 0-15.      35070000
* Register 15 is corrupted, return address is supposed to be in R1.     35080000
*                                                                       35090000
TOHEX    EQU   *                       * Exit to error routine          35100000
         LR    R0,R1                   * Save return address            35110000
         LA    R1,7                    * Set loop counter               35120000
*                                                                       35130000
TOHEXLUP XR    R15,R15                 * Clear register                 35140000
         SRDL  R14,4                   * Retrieve nibble from the right 35150000
         SRL   R15,28                  * And place it rightmost in R15  35160000
         STC   R15,4(R1,R2)            * Store nibble in message        35170000
         BCT   R1,TOHEXLUP             * And go get next nibble         35180000
         STC   R14,4(R1,R2)            * Store last remaining nibble    35190000
         L     R14,=AL4(HEXTAB)        * Retrieve addr of hexchar-table 35200000
         TR    4(8,R2),0(R14)          * Translate nibbles to chars     35210000
         LR    R1,R0                   * Retrieve return address        35220000
         BR    R1                      * And return to error handler    35230000
*                                                                       35240000
* Drop all general base registers currently in use                      35250000
*                                                                       35260000
         DROP  R3                      * Base register for csect        35270000
         DROP  R4                      * Base to BXAIOPRM               35280000
         DROP  R5                      * Base to 'current' FDB          35290000
*                                                                       35300000
ERROREND EQU   *                                                        35310000
*                                                                       35320000
&ERR     SETB  0                       * No longer assembling the       35330000
*                                      *           error-routine        35340000
         EJECT                                                          35350000
*                                                                       35360000
* This routine resets the base register after execution of a subroutine 35370000
* That uses its own addressability.                                     35380000
* Upon entry R3  contains the address of RSETBASE                       35390000
*            R14 contains the address to be returned to                 35400000
* Upon exit  R3  must contain the base address associated with the      35410000
*                address in R14                                         35420000
*            all other registers should remain unchanged                35430000
*                                                                       35440000
* The table of base addresses is supposed to be ordered in descending   35450000
* order. Therefore the first element we find containing an address less 35460000
* than the return address in R14 must be the associated base address.   35470000
*                                                                       35480000
         USING RSETBASE,R3                                              35490000
RSETBASE EQU   *                                                        35500000
         LA    R14,0(R14)              * Strip hi-order bits of ret-adr 35510000
         L     R1,=AL4(BASETAB)        * Get address of table to search 35520000
*                                                                       35530000
RSETLOOP C     R14,0(R1)               * R14 >= (GE) table entry??      35540000
         BNL   RSETDONE                * Yes: go use the entry          35550000
         LA    R1,8(R1)                * No: get next element           35560000
         B     RSETLOOP                * And go see if it matches       35570000
*                                                                       35580000
RSETDONE EQU   *                                                        35590000
         C     R14,4(R1)               * End-of-section >= retaddr ?    35600000
         BL    RSETOK                  * Yes: base-addr valid, use it   35610000
         C     R14,UALV1SAV            * UALV1SAV is valid ??           35620000
         BE    RSETEXIT                * No: return to emergency exit   35630000
         L     R14,UALV1SAV            * Yes: return to mainline        35640000
         B     RSETERR                 * After issuing the error        35650000
*                                                                       35660000
RSETEXIT L     R14,=AL4(EXIT)          * After error: exit program      35670000
*                                                                       35680000
RSETERR  LA    R15,056                 * Load error number              35690000
         L     R3,=AL4(ERROR)          * Load address of error handler  35700000
         BR    R3                      * and execute error handler      35710000
*                                                                       35720000
RSETOK   L     R3,0(R1)                * Get the correct base address   35730000
         BR    R14                     * and return to caller's caller  35740000
*                                                                       35750000
         DROP  R3                                                       35760000
         DROP  R13                                                      35770000
*                                                                       35780000
RSETBEND EQU   *                                                        35790000
*                                                                       35800000
         AIF   (NOT &DBG).RSNAP        * RSNAP only in test mode        35810000
         EJECT                                                          35820000
*                                                                       35830000
         LCLA  &SNAPLEN                * Var for length of snaplist     35840000
&SNAPLEN SETA  (4+8*&AANTFIL)*8        * Maxnr of entries*entry-length  35850000
*                                                                       35860000
         USING RSNAP,R15                                                35870000
*                                                                       35880000
* This routine produces a snap dump of the most relevant control blocks 35890000
* Since standard mvs-linkage conventions are used, there is no need     35900000
* to return through the rsetbase-routine.                               35910000
*                                                                       35920000
RSNAP    EQU   *                       * Snap dump routine              35930000
         USING DSUSERAR,R13            * R13 still points to USERAREA   35940000
         TM    UASTAT,UASNAPER         * Snap-error occurred ??         35950000
         BNO   RSNAP00                 * Yes: return immediate          35960000
         XR    R15,R15                 * Set return-code                35970000
         BR    R14                     * And return immediate           35980000
*                                                                       35990000
RSNAP00  STM   R14,R12,SAVEDR14(R13)   * Save caller's registers        36000000
         DROP  R15                     * Switch base register           36010000
         USING RSNAP,R3                * to register 3                  36020000
         LR    R3,R15                  * and load base register         36030000
         XR    R15,R15                 * Set return code to zero        36040000
         L     R14,UASNAPTR            * Get address of snap-area       36050000
         LTR   R14,R14                 * Is it valid ??                 36060000
         BNZ   RSNAP10                 * Yes: continue                  36070000
         GETMAIN RC,                   * Try to allocate snaparea      *36080000
               SP=&SP,                 *    in our own subpool         *36090000
               LV=L'SNAPAREA           *    specifying its length       36100000
         LTR   R15,R15                 * Storage allocated ??           36110000
         BZ    RSNAP05                 * Yes                            36120000
         LA    R15,075                 * Load error code                36130000
         B     RSNAPXI2                * And exit snap-rout             36140000
*                                                                       36150000
RSNAP05  ST    R1,UASNAPTR             * Save addr of acquired storage  36160000
         LR    R14,R1                  * Copy address                   36170000
         DROP  R13                     * USERAREA no longer addressable 36180000
*                                                                       36190000
RSNAP10  EQU   *                       * R14 points to new save-area    36200000
         ST    R13,SAVEPREV(R14)       * Set backward pointer           36210000
         ST    R14,SAVENEXT(R13)       * and forward pointer            36220000
         LR    R13,R14                 * and establish new save-area    36230000
         USING DSSNAP,R13              * Set snap-block addressable     36240000
*                                                                       36250000
         L     R14,SAVEPREV(R13)       * Get address of USERAREA        36260000
         USING DSUSERAR,R14            * Address USERAREA               36270000
         TM    UASTAT,UASNAPOP         * Snap is open ??                36280000
         BO    RSNAP30                 * Yes: skip opening              36290000
         MVC   SNAPDCB,SNAP            * Copy default DCB               36300000
         MVC   UAWORKAR(SNAPOPLV),SNAPOPEN * Copy plist for open macro  36310000
         LA    R9,UAWORKAR             * And point to modifiable plist  36320000
         LA    R2,SNAPDCB              * Point to the copied DCB        36330000
         DROP  R14                     * End of addressability          36340000
         OPEN  ((R2)),                 * Open the sysudump file        *36350000
               MF=(E,(R9))             *      using a copy of the       36360000
*                                      *        default plist           36370000
         LTR   R15,R15                 * Open was ok??                  36380000
         BZ    RSNAP20                 * Yes: continue                  36390000
         LA    R15,076                 * Load error code                36400000
         B     RSNAPXIT                * And quit snapping              36410000
*                                                                       36420000
RSNAP20  L     R14,SAVEPREV(R13)       * Get address of USERAREA        36430000
         USING DSUSERAR,R14            * Address USERAREA               36440000
         MVI   SNAPIDNR,X'00'          * Set initial snap-id to zero    36450000
         OI    UASTAT,UASNAPOP         * Indicate snap-file is open     36460000
         DROP  R14                     * End of addressability          36470000
*                                                                       36480000
RSNAP30  LA    R10,SNAPHDRS            * R10 is pointer in headers list 36490000
         LA    R6,SNAPLIST             * R6 is pointer in SNAPLIST      36500000
         LR    R8,R6                   * First dump the snaparea        36510000
         LA    R9,L'SNAPAREA-1(R8)     *    so we can see all beginning 36520000
*                                      *    and ending addresses        36530000
         LA    R2,SNAPHD01             * Get address of header          36540000
         BAS   R14,RSNAPSET            * Put the adresses in the list   36550000
*                                                                       36560000
         L     R8,SAVEPREV(R13)        * Get address of USERAREA        36570000
         L     R8,SAVEPREV(R8)         * Get addr of previous save-area 36580000
         L     R8,SAVEDR1(R8)          * Get plist-pointer at entry     36590000
         L     R8,0(R8)                * Get address of BXAIOPRM        36600000
         LA    R8,0(R8)                * Strip end-of-plist-bit         36610000
         LA    R9,L'BXAIOPRM-1(R8)     * Get ending addr of dump-area   36620000
         LA    R2,SNAPHD02             * Get address of header          36630000
         BAS   R14,RSNAPSET            * Put range R8-R9 in SNAPLIST    36640000
*                                                                       36650000
         L     R8,SAVEPREV(R13)        * Get address of USERAREA        36660000
         L     R8,SAVEPREV(R8)         * Get addr of previous save-area 36670000
         L     R8,SAVEDR1(R8)          * Get plist-pointer at entry     36680000
         L     R8,4(R8)                * Get address of LNSPRM2         36690000
         LA    R8,0(R8)                * Strip end-of-plist-bit         36700000
         LA    R9,L'LNSPRM2-1(R8)      * Get ending addr of dump-area   36710000
         LA    R2,SNAPHD03             * Get address of header          36720000
         BAS   R14,RSNAPSET            * Put range R8-R9 in SNAPLIST    36730000
*                                                                       36740000
         L     R8,SAVEPREV(R13)        * Get address of old savearea    36750000
         LR    R4,R8                   *    which is the user-area      36760000
         USING DSUSERAR,R4             * and establish addressability   36770000
         LA    R9,L'USERAREA-1(R8)     * Get ending addr of dump-area   36780000
         LA    R2,SNAPHD04             * Get address of header          36790000
         BAS   R14,RSNAPSET            * Put range R8-R9 in SNAPLIST    36800000
*                                                                       36810000
         LA    R5,UAFDBPTR             * Setup base pointer for loop    36820000
         USING DSFDB,R5                * And establish addressability   36830000
RSNAPLUP L     R5,FDBNEXT              * Point next FDB                 36840000
         LTR   R5,R5                   * All FDBs done ??               36850000
         BE    RSNAPDO                 * Yes: go dump                   36860000
*                                                                       36870000
RSNAPFDB EQU   *                                                        36880000
         LR    R8,R5                   * Start address for of FDB       36890000
         LA    R9,L'FDB-1(R8)          * And end address of FDB         36900000
         LA    R2,SNAPHD05             * Get address of header          36910000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             36920000
*                                                                       36930000
RSNAPACB EQU   *                                                        36940000
         L     R8,FDBACB               * Get address of ACB             36950000
         LTR   R8,R8                   * Valid ??                       36960000
         BZ    RSNAPRPL                * No: go on to the RPL           36970000
         LA    R9,IFGACBLV-1           * Get length - 1                 36980000
         LA    R9,0(R8,R9)             * Get end address                36990000
         LA    R2,SNAPHD06             * Get address of header          37000000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             37010000
*                                                                       37020000
RSNAPRPL EQU   *                                                        37030000
         L     R8,FDBRPL               * Get address of RPL             37040000
         LTR   R8,R8                   * Valid ??                       37050000
         BZ    RSNAPREC                * No: go on to the record        37060000
         LA    R9,IFGRPLLV-1           * Get length - 1                 37070000
         LA    R9,0(R8,R9)             * Get end address                37080000
         LA    R2,SNAPHD07             * Get address of header          37090000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             37100000
*                                                                       37110000
         USING IFGRPL,R8               * Address RPL                    37120000
         L     R8,RPLPLHPT             * Get address of placeholder     37130000
         DROP  R8                                                       37140000
         LTR   R8,R8                   * Valid ??                       37150000
         BZ    RSNAPREC                * No: go on to the record        37160000
         LA    R9,IDAPLHLV-1           * Get length - 1                 37170000
         LA    R9,0(R8,R9)             * Get end address                37180000
         LA    R2,SNAPHD08             * Get address of header          37190000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             37200000
         AIF   (&OPT).RSNAPRC          * Skip PLH and control-interval  37210000
         LR    R15,R8                  * Save PLH-pointer               37220000
         USING IDAPLH,R15              * Address PLH by its DSECT       37230000
         L     R8,PLHDBUFC             * Point to bufc-block            37240000
         DROP  R15                     * End of addressability to PLH   37250000
         LTR   R8,R8                   * Valid ??                       37260000
         BZ    RSNAPREC                * No: go on to the record        37270000
         LH    R9,=H'79'               * Get length - 1                 37280000
         LA    R9,0(R8,R9)             * Get end address                37290000
         LA    R2,SNAPHD09             * Get address of header          37300000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             37310000
*                                                                       37320000
         L     R8,FDBRPL               * Get address of RPL             37330000
         USING IFGRPL,R8               * Address RPL                    37340000
         L     R8,RPLPLHPT             * Get address of placeholder     37350000
         DROP  R8                                                       37360000
         LR    R15,R8                  * Save PLH-pointer               37370000
         USING IDAPLH,R15              * Address PLH by its DSECT       37380000
         L     R8,PLHRECP              * Addr of current record in buf  37390000
         DROP  R15                     * End of addressability to PLH   37400000
         LTR   R8,R8                   * Valid ??                       37410000
         BZ    RSNAPREC                * No: go on to the record        37420000
         LH    R9,=H'32767'            * Get length - 1                 37430000
         LA    R9,0(R8,R9)             * Get end address of buffer      37440000
         LA    R2,SNAPHD10             * Get address of header          37450000
         BAS   R14,RSNAPSET            * And setup SNAPLIST             37460000
*                                                                       37470000
.RSNAPRC ANOP                                                           37480000
*                                                                       37490000
RSNAPREC EQU   *                                                        37500000
         L     R8,FDBREC               * Get addr of record in buffer   37510000
         LTR   R8,R8                   * Valid ??                       37520000
         BZ    RSNAPWAR                * No: go on to the workarea      37530000
         LH    R9,FDBRECLV             * Get length                     37540000
         LA    R9,0(R8,R9)             * Get end address + 1            37550000
         BCTR  R9,R0                   * and decrement to get end       37560000
         LA    R2,SNAPHD11             * Get address of header          37570000
         BAS   R14,RSNAPSET            * and setup SNAPLIST             37580000
*                                                                       37590000
RSNAPWAR EQU   *                                                        37600000
         L     R8,FDBWAREA             * Get addr of record in workarea 37610000
         LTR   R8,R8                   * Valid ??                       37620000
         BZ    RSNAPNXT                * No: go on to next FDB          37630000
         LH    R9,FDBRECLV             * Get length                     37640000
         LA    R9,0(R8,R9)             * Get end address + 1            37650000
         BCTR  R9,R0                   * and decrement to get end       37660000
         LA    R2,SNAPHD12             * Get address of header          37670000
         BAS   R14,RSNAPSET            * and setup SNAPLIST             37680000
*                                                                       37690000
RSNAPNXT EQU   *                                                        37700000
         B     RSNAPLUP                * Go try next FDB                37710000
*                                                                       37720000
RSNAPDO  EQU   *                                                        37730000
         SH    R6,=H'4'                * Point last used entry in       37740000
*                                      *              SNAPLIST          37750000
         OI    0(R6),X'80'             * Insert end-of-list indicator   37760000
         SH    R10,=H'4'               * Point last used entry in       37770000
*                                      *              HDRLIST           37780000
         OI    0(R10),X'80'            * Insert end-of-list indicator   37790000
         XR    R2,R2                   * Clear register                 37800000
         IC    R2,SNAPIDNR             * and get last snapid-nr         37810000
         LA    R2,1(R2)                * Increment id-nr                37820000
         STC   R2,SNAPIDNR             * Save snapid-nr for next call   37830000
         LA    R6,SNAPLIST             * Reload start of SNAPLIST       37840000
         LA    R7,SNAPHDRS             * Load start of header-list      37850000
         LA    R8,SNAPDCB              * Load address of DCB            37860000
*********************************************************************   37870000
* This change implemented on 9-7-2001: 4 lines removed                  37880000
* R4 still points to SAVEAREA in DSUSERAR, no need to use R9            37890000
*        L     R9,SAVEPREV(R13)        * Load address of USERAREA       37900000
*        USING DSUSERAR,R9             * And establish addressability   37910000
         MVC   UAWORKAR(RSNAPPLV),RSNAPSNP * copy coding of MF=L macro  37920000
*        LA    R9,UAWORKAR             * Point to the macro's coding    37930000
*        DROP  R9                      * End addressability of USERAREA 37940000
* End of change dated 9-7-2001                                          37950000
**********************************************************************  37960000
         SNAP  MF=(E,(R9)),            * Make dump, using remote plist *37970000
               DCB=(R8),               *    dump snap to this DCB      *37980000
               ID=(R2),                *    use incremented snap-id nr *37990000
               LIST=(R6),              *    list of storage ranges     *38000000
               STRHDR=(R7)             *    list of storage headers     38010000
         LTR   R2,R15                  * Snap was ok ??                 38020000
         BE    RSNAPXIT                * Yes: exit snap-routine         38030000
         LA    R15,077                 * Load error code                38040000
*                                                                       38050000
RSNAPXIT EQU   *                                                        38060000
         LR    R15,R2                  * R2 contains SNAP's returncode  38070000
         L     R13,SAVEPREV(R13)       * Get addr of previous save-area 38080000
*                                                                       38090000
RSNAPXI2 EQU   *                                                        38100000
         L     R14,SAVEDR14(R13)       * Reload return address          38110000
         LM    R0,R12,SAVEDR0(R13)     * Reload caller's registers      38120000
         BR    R14                     * and return                     38130000
*                                                                       38140000
RSNAPSET EQU   *                       * Put storage range in snaplist  38150000
         LA    R15,SNAPHDRS            * Point beyond snaplist          38160000
         CR    R6,R15                  * Enough room in plist ??        38170000
         BL    RSNAPSE2                * Yes: put addresses in plist    38180000
         LA    R15,081                 * Load error nr                  38190000
         B     RSNAPXIT                * And exit to issue error        38200000
*                                                                       38210000
RSNAPSE2 ST    R8,0(R6)                * Put start-address of range     38220000
         ST    R9,4(R6)                * and end address in snaplist    38230000
         LA    R6,8(R6)                * Have pointer point to next one 38240000
         ST    R2,0(R10)               * Store dump header address      38250000
         LA    R10,4(R10)              * Point to next free hdr entry   38260000
         BR    R14                     * Return                         38270000
*                                                                       38280000
         DROP  R3                      * Drop base register             38290000
         DROP  R4                      * Drop pointer to savearea       38300000
         DROP  R5                      * Drop FDB-pointer               38310000
*                                                                       38320000
RSNAPEND EQU   *                                                        38330000
*                                                                       38340000
         DROP  R13                     * Drop snap-block pointer        38350000
*                                                                       38360000
         EJECT                                                          38370000
*                                                                       38380000
* Snapheader entries                                                    38390000
*                                                                       38400000
         DS    0F                                                       38410000
SNAPHD01 DC    AL1(L'SNAPHD51)                                          38420000
SNAPHD51 DC    C'SNAPAREA - address ranges to be dumped etc.'           38430000
         DS    0F                                                       38440000
SNAPHD02 DC    AL1(L'SNAPHD52)                                          38450000
SNAPHD52 DC    C'BXAIOPRM - input parameter from application'           38460000
         DS    0F                                                       38470000
SNAPHD03 DC    AL1(L'SNAPHD53)                                          38480000
SNAPHD53 DC    C'LNSPRM2  - parameter for internal control information' 38490000
         DS    0F                                                       38500000
SNAPHD04 DC    AL1(L'SNAPHD54)                                          38510000
SNAPHD54 DC    C'USERAREA - data related with one caller'               38520000
         DS    0F                                                       38530000
SNAPHD05 DC    AL1(L'SNAPHD55)                                          38540000
SNAPHD55 DC    C'FDB      - file definition block'                      38550000
         DS    0F                                                       38560000
SNAPHD06 DC    AL1(L'SNAPHD56)                                          38570000
SNAPHD56 DC    C'ACB      - access method control block'                38580000
         DS    0F                                                       38590000
SNAPHD07 DC    AL1(L'SNAPHD57)                                          38600000
SNAPHD57 DC    C'RPL      - request parameter list'                     38610000
         DS    0F                                                       38620000
SNAPHD08 DC    AL1(L'SNAPHD58)                                          38630000
SNAPHD58 DC    C'PLH      - placeholder'                                38640000
         DS    0F                                                       38650000
SNAPHD09 DC    AL1(L'SNAPHD59)                                          38660000
SNAPHD59 DC    C'BUFC     - buffer control block (entry)'               38670000
         DS    0F                                                       38680000
SNAPHD10 DC    AL1(L'SNAPHD60)                                          38690000
SNAPHD60 DC    C'VSAM.CI  - complete VSAM control interval'             38700000
         DS    0F                                                       38710000
SNAPHD11 DC    AL1(L'SNAPHD61)                                          38720000
SNAPHD61 DC    C'RECORD   - record in data buffer'                      38730000
         DS    0F                                                       38740000
SNAPHD12 DC    AL1(L'SNAPHD62)                                          38750000
SNAPHD62 DC    C'WORKAREA - record work-area for insert/delete'         38760000
*                                                                       38770000
         SPACE 3                                                        38780000
RSNAPSNP SNAP  DCB=0,                  * Addr known only at run-time   *38790000
               ID=0,                   * Id-nr incremented each snap   *38800000
               LIST=0,                 * Dumping storage ranges        *38810000
               STRHDR=0,               * Specifying headers per range  *38820000
               PDATA=(PSW,REGS,SA,SAH), *Specify what to dump          *38830000
               MF=L                                                     38840000
RSNAPPLV EQU   *-RSNAPSNP              * Length for move of plist       38850000
*                                                                       38860000
SNAP     DCB   DDNAME=SYSUDUMP,        * Use DDNAME sysudump for snaps *38870000
               DSORG=PS,                                               *38880000
               MACRF=W,                                                *38890000
               LRECL=125,                                              *38900000
               BLKSIZE=1632,                                           *38910000
               RECFM=VBA                                                38920000
SNAPDCBL EQU   *-SNAP                  * Length required for this DCB   38930000
*                                                                       38940000
SNAPOPEN OPEN  (0,(OUTPUT)),           * Open DCB for snap-output      *38950000
               MODE=31,                * 31-bit addressing             *38960000
               MF=L                    * DCB address not yet known      38970000
SNAPOPLV EQU   *-SNAPOPEN              * Set length for move of plist   38980000
*                                                                       38990000
.RSNAP   ANOP                                                           39000000
         EJECT                                                          39010000
         DROP  R11                     * Drop data-area pointer         39020000
         DS    0D                      * Realign on doubleword boundary 39030000
*********************************************************************** 39040000
* Change implemented on 9-7-2001: put CONST area in a separate CSECT    39050000
* CONST  EQU   *                                                        39060000
CONST    CSECT                                                          39070000
* End of change dated 9-7-2001                                          39080000
*********************************************************************** 39090000
         LTORG                                                          39100000
*                                                                       39110000
         EJECT                                                          39120000
*                                                                       39130000
* Non-executable code, plists, macros etc.....                          39140000
*                                                                       39150000
WTOTEXT  DS    0CL64                   * Max text length is 64 chars    39160000
ERRWTO   WTO   '1234567890123456789012345678901234567890123456789012345*39170000
               678901234',             * 64 positions reserved for text*39180000
               ROUTCDE=11,             * Routing-code                  *39190000
               DESC=7,                 * Descriptor-code               *39200000
               MF=L                                                     39210000
ERRWTOLV EQU   *-ERRWTO                * Set length for move of plist   39220000
*                                                                       39230000
         DS    0D                      * Realign on doubleword boundary 39240000
NUMTAB   DC    240X'FF'                * This table is used with TRT to 39250000
         DC    10X'00'                 *  check that any required key   39260000
         DC    6X'FF'                  *  values be decently numeric.   39270000
*                                                                       39280000
HEXTAB   DC    C'01234567'             * This table is used with TR to  39290000
         DC    C'89ABCDEF'             *  translate nibbles into EBCDIC 39300000
         DC    240C' '                 *  characters.                   39310000
*                                                                       39320000
SEEKSPC  DC    64X'00'                 * This table is used with TRT to 39330000
         DC    X'FF'                   *  find the first blank in a     39340000
         DC    191X'00'                *  DDNAME.                       39350000
*                                                                       39360000
         SPACE 3                                                        39370000
*                                                                       39380000
* BASETAB is a table with all addresses that are used as base addresses 39390000
* in the program. They are listed in reverse order. The table is used   39400000
* to find the base address associated with a given return address.      39410000
* Before returning to a return address R3 (the base register) must be   39420000
* given the correct value from the table. That is: the first value      39430000
* in the table that is less than or equal to the return address.        39440000
*                                                                       39450000
         CNOP  0,4                     * Realign on fullword boundary   39460000
BASETAB  EQU   *                                                        39470000
         AIF   (&OPT).BASETB           * Skip some routines             39480000
         AIF   (NOT &DBG).BASETAB      * RSNAP invalid if not test      39490000
         DC    AL4(RSNAP),AL4(RSNAPEND)    * Is never returned to       39500000
.BASETAB ANOP                                                           39510000
         DC    AL4(RSETBASE),AL4(RSETBEND) * Is never returned to       39520000
         DC    AL4(ERROR),AL4(ERROREND)    * Is never returned to       39530000
.BASETB  ANOP                                                           39540000
         DC    AL4(RCHECK),AL4(RCHEKEND)                                39550000
         DC    AL4(PHASE4),AL4(FASE4END)                                39560000
         DC    AL4(PHASE3),AL4(FASE3END)                                39570000
         DC    AL4(PHASE2),AL4(FASE2END)                                39580000
         DC    AL4(PHASE1),AL4(FASE1END)                                39590000
         DC    F'0',F'0'                   * End-of-list marker         39600000
*                                                                       39610000
         EJECT                                                          39620000
*                                                                       39630000
* Table of supported function codes (opcodes)                           39640000
* The bit coding corresponds to FDBREQ. The close-request bit           39650000
* is used double: it is also used to indicate update mode for           39660000
* open processing. The open routine will have to reset this bit,        39670000
* to prevent the data set from being closed in the same call.           39680000
* The order of opcodes in this table is designed for optimum efficiency 39690000
* in the process of looking up the requested function code.             39700000
*                                                                       39710000
OPCODES  DS    0D                                                       39720000
         DC    CL2'RS',B'00100000',X'00',AL4(CHECKRS)                   39730000
         DC    CL2'RR',B'00100000',X'00',AL4(CHECKRR)                   39740000
         DC    CL2'WS',B'00010000',X'00',AL4(CHECKWS)                   39750000
         DC    CL2'WR',B'00010000',X'00',AL4(CHECKWR)                   39760000
         DC    CL2'SK',B'01000000',X'00',AL4(CHECKSK)                   39770000
         DC    CL2'SN',B'01100000',X'00',AL4(CHECKSN)                   39780000
         DC    CL2'IR',B'00001000',X'00',AL4(CHECKIR)                   39790000
         DC    CL2'DR',B'00000100',X'00',AL4(CHECKDR)                   39800000
         DC    CL2'SI',B'11100000',X'00',AL4(CHECKOI)                   39810000
         DC    CL2'RI',B'10100001',X'00',AL4(CHECKOI)                   39820000
         DC    CL2'SU',B'11100010',X'00',AL4(CHECKOU)                   39830000
         DC    CL2'RU',B'10100011',X'00',AL4(CHECKOU)                   39840000
         AIF   (NOT &DBG).OPCODE                                        39850000
         DC    CL2'WN',B'00110000',X'00',AL4(CHECKWN)                   39860000
         DC    CL2'DN',B'00100100',X'00',AL4(CHECKDN)                   39870000
         DC    CL2'SD',B'00000000',X'00',AL4(CHECKSD)                   39880000
.OPCODE  ANOP                                                           39890000
OPCODEND DC    CL2'CA',B'00000010',X'00',AL4(CHECKCA)                   39900000
         DC    CL2'  ',B'00000000',X'00',AL4(CHECKXX)                   39910000
* Last element forces error (invalid fcode in parm)                     39920000
*                                                                       39930000
         EJECT                                                          39940000
*                                                                       39950000
* VSAM macros                                                           39960000
*                                                                       39970000
         GBLA  &DBUF,&IBUF             * Nr of data and index buffers   39980000
&DBUF    SETA  8*&AANTFIL              * 8 databuffers per seq. file    39990000
&IBUF    SETA  160*&AANTFIL            * 160 indexbuffers / random file 40000000
*                                                                       40010000
BLDVRPD  BLDVRP BUFFERS=(22528(&DBUF)), *Allocate VSAM resource pool   *40020000
               TYPE=(LSR,DATA),        * Local shared, for data buffers*40030000
               STRNO=&AANTFIL,         * Max nr. of concurrent requests*40040000
               KEYLEN=&MAXKEY,         * Max key length to accommodate *40050000
               SHRPOOL=0,              * Shrpool-nr                    *40060000
               MODE=24,                * Plist in 24bit addressing mode*40070000
               RMODE31=ALL,            * Buffers and control blocks in *40080000
               MF=L                    *                high storage    40090000
BLDVRDLV EQU   *-BLDVRPD               * Set length for move of plist   40100000
*                                                                       40110000
BLDVRPI  BLDVRP BUFFERS=(512(&IBUF)),  * Allocate VSAM resource pool   *40120000
               TYPE=(LSR,INDEX),       * Local shared, for index bufs  *40130000
               STRNO=&AANTFIL,         * Max nr of concurrent requests *40140000
               KEYLEN=&MAXKEY,         * Maximum key length            *40150000
               SHRPOOL=0,              * Shrpool-nr                    *40160000
               MODE=24,                * Plist in 24bit addressing mode*40170000
               RMODE31=ALL,            * Buffers and control blocks in *40180000
               MF=L                    *               high storage     40190000
BLDVRILV EQU   *-BLDVRPI               * Set length for move of plist   40200000
*                                                                       40210000
         SPACE 3                                                        40220000
*                                                                       40230000
* All gencb-macros below generate a plist in the UAWORKAR-field,        40240000
* The plist can the be modified by the program (ROP-routine)            40250000
* before the control block is actually generated.                       40260000
*                                                                       40270000
         USING DSUSERAR,R13            * Valid for all gencb-macros     40280000
         USING DSFDB,R5                * Valid for all gencb-macros     40290000
*                                                                       40300000
ACBTAB   EQU   *                       * Table with addresses of GENCB  40310000
         DC    AL4(GENACLIS)           *  plists for generating an ACB  40320000
         DC    AL4(GENACLIR)           *                                40330000
         DC    AL4(GENACLUS)           *                                40340000
         DC    AL4(GENACLUR)           * Using local shared resources   40350000
         DC    AL4(GENACPIS)           *  or private pools              40360000
         DC    AL4(GENACPIR)           *                                40370000
         DC    AL4(GENACPUS)           *                                40380000
         DC    AL4(GENACPUR)           *                                40390000
*                                                                       40400000
         USING GENACLIS,R3                                              40410000
GENACLIS EQU   *                                                        40420000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *40430000
               AM=VSAM,                * Access method                 *40440000
               WAREA=(R7),             * Location for generated ACB    *40450000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *40460000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *40470000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *40480000
               MACRF=(KEY,DFR,SEQ,SKP,SIS,LSR), * Options for this ACB *40490000
               BUFND=8,                * Minimum nr of data buffers    *40500000
               BUFNI=1,                * Minimum nr of index buffers   *40510000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *40520000
               MF=(L,UAWORKAR,GACLISLV) *Generate plist in UAWORKAR     40530000
         BR    R10                     * Return to open routine         40540000
         DROP  R3                                                       40550000
*                                                                       40560000
         USING GENACLIR,R3                                              40570000
GENACLIR EQU   *                                                        40580000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *40590000
               AM=VSAM,                * Access method                 *40600000
               WAREA=(R7),             * Location for generated ACB    *40610000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *40620000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *40630000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *40640000
               MACRF=(KEY,DFR,DIR,SIS,LSR), * Options for this ACB     *40650000
               BUFND=2,                * Minimum nr of data buffers    *40660000
               BUFNI=160,              * Minimum nr of index buffers   *40670000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *40680000
               MF=(L,UAWORKAR,GACLIRLV) *Generate plist in UAWORKAR     40690000
         BR    R10                     * Return to open routine         40700000
         DROP  R3                                                       40710000
*                                                                       40720000
         USING GENACLUS,R3                                              40730000
GENACLUS EQU   *                                                        40740000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *40750000
               AM=VSAM,                * Access method                 *40760000
               WAREA=(R7),             * Location for generated ACB    *40770000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *40780000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *40790000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *40800000
               MACRF=(KEY,DFR,SEQ,SKP,IN,OUT,SIS,LSR), * ACB-options   *40810000
               BUFND=8,                * Minimum nr of data buffers    *40820000
               BUFNI=1,                * Minimum nr of index buffers   *40830000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *40840000
               MF=(L,UAWORKAR,GACLUSLV) *Generate plist in UAWORKAR     40850000
         BR    R10                     * Return to open routine         40860000
         DROP  R3                                                       40870000
*                                                                       40880000
         USING GENACLUR,R3                                              40890000
GENACLUR EQU   *                                                        40900000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *40910000
               AM=VSAM,                * Access method                 *40920000
               WAREA=(R7),             * Location for generated ACB    *40930000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *40940000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *40950000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *40960000
               MACRF=(KEY,DFR,SEQ,SKP,IN,OUT,SIS,LSR), * ACB-options   *40970000
               BUFND=2,                * Minimum nr of data buffers    *40980000
               BUFNI=160,              * Minimum nr of index buffers   *40990000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *41000000
               MF=(L,UAWORKAR,GACLURLV) *Generate plist in UAWORKAR     41010000
         BR    R10                     * Return to open routine         41020000
         DROP  R3                                                       41030000
*                                                                       41040000
         USING GENACPIS,R3                                              41050000
GENACPIS EQU   *                                                        41060000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *41070000
               AM=VSAM,                * Access method                 *41080000
               WAREA=(R7),             * Location for generated ACB    *41090000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *41100000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *41110000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *41120000
               MACRF=(KEY,DFR,SEQ,SKP,SIS,NSR), * Options for this ACB *41130000
               BUFND=8,                * Minimum nr of data buffers    *41140000
               BUFNI=1,                * Minimum nr of index buffers   *41150000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *41160000
               MF=(L,UAWORKAR,GACPISLV) *Generate plist in UAWORKAR     41170000
         BR    R10                     * Return to open routine         41180000
         DROP  R3                                                       41190000
*                                                                       41200000
         USING GENACPIR,R3                                              41210000
GENACPIR EQU   *                                                        41220000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *41230000
               AM=VSAM,                * Access method                 *41240000
               WAREA=(R7),             * Location for generated ACB    *41250000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *41260000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *41270000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *41280000
               MACRF=(KEY,DFR,DIR,SIS,NSR), * Options for this ACB     *41290000
               BUFND=2,                * Minimum nr of data buffers    *41300000
               BUFNI=160,              * Minimum nr of index buffers   *41310000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *41320000
               MF=(L,UAWORKAR,GACPIRLV) *Generate plist in UAWORKAR     41330000
         BR    R10                     * Return to open routine         41340000
         DROP  R3                                                       41350000
*                                                                       41360000
         USING GENACPUS,R3                                              41370000
GENACPUS EQU   *                                                        41380000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *41390000
               AM=VSAM,                * Access method                 *41400000
               WAREA=(R7),             * Location for generated ACB    *41410000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *41420000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *41430000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *41440000
               MACRF=(KEY,DFR,SEQ,SKP,IN,OUT,SIS,NSR), * ACB-options   *41450000
               BUFND=8,                * Minimum nr of data buffers    *41460000
               BUFNI=1,                * Minimum nr of index buffers   *41470000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *41480000
               MF=(L,UAWORKAR,GACPUSLV) *Generate plist in UAWORKAR     41490000
         BR    R10                     * Return to open routine         41500000
         DROP  R3                                                       41510000
*                                                                       41520000
         USING GENACPUR,R3                                              41530000
GENACPUR EQU   *                                                        41540000
         GENCB BLK=ACB,                * Generate plist for gencb ACB  *41550000
               AM=VSAM,                * Access method                 *41560000
               WAREA=(R7),             * Location for generated ACB    *41570000
               LENGTH=IFGACBLV,        * Max length for generated ACB  *41580000
               DDNAME=(*,FDBDDNAM),    * Gencb ACB is to copy DDNAME   *41590000
               SHRPOOL=(S,0(R6)),      * Shrpool-nr varies from 0-15   *41600000
               MACRF=(KEY,DFR,SEQ,SKP,IN,OUT,SIS,NSR), * ACB-options   *41610000
               BUFND=2,                * Minimum nr of data buffers    *41620000
               BUFNI=160,              * Minimum nr of index buffers   *41630000
               RMODE31=ALL,            * Buffer and control bl. > 16M  *41640000
               MF=(L,UAWORKAR,GACPURLV) *Generate plist in UAWORKAR     41650000
         BR    R10                     * Return to open routine         41660000
         DROP  R3                                                       41670000
*                                                                       41680000
         SPACE 3                                                        41690000
RPLTAB   EQU   *                       * Table with addresses of gencb  41700000
         DC    AL4(GENRPLIS)           * plists for generating an RPL   41710000
         DC    AL4(GENRPLIR)                                            41720000
         DC    AL4(GENRPLUS)                                            41730000
         DC    AL4(GENRPLUR)                                            41740000
*                                                                       41750000
         USING GENRPLIS,R3                                              41760000
GENRPLIS GENCB BLK=RPL,                * Generate plist for gencb RPL  *41770000
               AM=VSAM,                * For VSAM files                *41780000
               WAREA=(R9),             * Specify address for RPL       *41790000
               LENGTH=IFGRPLLV,        * And length available          *41800000
               ACB=(R7),               * Specify ACB-address for RPL   *41810000
               AREA=(S,FDBREC),        * and data-area                 *41820000
               AREALEN=4,              * Length of data-area           *41830000
               ARG=(S,UAKEY),          * Specify key location          *41840000
               KEYLEN=(S,0(R6)),       * and key length                *41850000
               ECB=(S,FDBECB),         * Specify ECB-address           *41860000
               RECLEN=(R8),            * and record length             *41870000
               OPTCD=(KEY,SEQ,ASY,NUP,KGE,GEN,LOC), * Options for RPL  *41880000
               MF=(G,UAWORKAR,GRPLISLV) *                               41890000
         BR    R10                     * Return to open routine         41900000
         DROP  R3                                                       41910000
*                                                                       41920000
         USING GENRPLIR,R3                                              41930000
GENRPLIR GENCB BLK=RPL,                * Generate plist for gencb RPL  *41940000
               AM=VSAM,                * For VSAM files                *41950000
               WAREA=(R9),             * Specify address for RPL       *41960000
               LENGTH=IFGRPLLV,        * And length available          *41970000
               ACB=(R7),               * Specify ACB-address for RPL   *41980000
               AREA=(S,FDBREC),        * and data-area                 *41990000
               AREALEN=4,              * Length of data-area           *42000000
               ARG=(S,UAKEY),          * Specify key location          *42010000
               KEYLEN=(S,0(R6)),       * and key length                *42020000
               ECB=(S,FDBECB),         * Specify ECB-address           *42030000
               RECLEN=(R8),            * and record length             *42040000
               OPTCD=(KEY,DIR,ASY,NUP,KEQ,FKS,LOC), * Options for RPL  *42050000
               MF=(G,UAWORKAR,GRPLIRLV) *                               42060000
         BR    R10                     * Return to open routine         42070000
         DROP  R3                                                       42080000
*                                                                       42090000
         USING GENRPLUS,R3                                              42100000
GENRPLUS GENCB BLK=RPL,                * Generate plist for gencb RPL  *42110000
               AM=VSAM,                * For VSAM files                *42120000
               WAREA=(R9),             * Specify address for RPL       *42130000
               LENGTH=IFGRPLLV,        * and length available          *42140000
               ACB=(R7),               * Specify ACB-address for RPL   *42150000
               AREA=(S,FDBREC),        * and data-area                 *42160000
               AREALEN=4,              * Length of data-area           *42170000
               ARG=(S,UAKEY),          * Specify key location          *42180000
               KEYLEN=(S,0(R6)),       * and key length                *42190000
               ECB=(S,FDBECB),         * Specify ECB-address           *42200000
               RECLEN=(R8),            * and record length             *42210000
               OPTCD=(KEY,SEQ,ASY,UPD,KGE,GEN,LOC), * Options for RPL  *42220000
               MF=(G,UAWORKAR,GRPLUSLV) *                               42230000
         BR    R10                     * Return to open routine         42240000
         DROP  R3                                                       42250000
*                                                                       42260000
         USING GENRPLUR,R3                                              42270000
GENRPLUR GENCB BLK=RPL,                * Generate plist for gencb RPL  *42280000
               AM=VSAM,                * For VSAM files                *42290000
               WAREA=(R9),             * Specify address for RPL       *42300000
               LENGTH=IFGRPLLV,        * And length available          *42310000
               ACB=(R7),               * Specify ACB-address for RPL   *42320000
               AREA=(S,FDBREC),        * and data-area                 *42330000
               AREALEN=4,              * Length of data-area           *42340000
               ARG=(S,UAKEY),          * Specify key location          *42350000
               KEYLEN=(S,0(R6)),       * and key length                *42360000
               ECB=(S,FDBECB),         * Specify ECB-address           *42370000
               RECLEN=(R8),            * and record length             *42380000
               OPTCD=(KEY,DIR,ASY,UPD,KEQ,FKS,LOC), * Options for RPL  *42390000
               MF=(G,UAWORKAR,GRPLURLV) *                               42400000
         BR    R10                     * Return to open routine         42410000
         DROP  R3                                                       42420000
*                                                                       42430000
         DROP  R5                      * FDB no longer valid            42440000
         DROP  R13                     * USERAREA no longer valid       42450000
         SPACE 3                                                        42460000
VSAMOPEN OPEN  (0),                    * Open VSAM file                *42470000
               MODE=31,                * 31-bit addressing             *42480000
               MF=L                    * ACB-address not yet known      42490000
VSAMOPLV EQU   *-VSAMOPEN              * Set length for move of plist   42500000
CLOSE    CLOSE (0),                    * Close a file                  *42510000
               MODE=31,                * 31-bit addressing             *42520000
               MF=L                    * ACB/DCB-address unknown        42530000
CLOSELV  EQU   *-CLOSE                 * Set length for move of plist   42540000
*                                                                       42550000
         EJECT                                                          42560000
*                                                                       42570000
* Default file descriptor blocks                                        42580000
*                                                                       42590000
CCDFDB   DS    0D                                                       42600000
         DC    AL4(CPDFDB)                                              42610000
         DC    F'0'                                                     42620000
         DC    CL8'CCD     '                                            42630000
         DC    6F'0'                                                    42640000
         DC    AL4(CCDMAP)                                              42650000
         DC    2H'0'                                                    42660000
         DC    H'350'                                                   42670000
         DC    AL1(14)                                                  42680000
         DC    X'00'                                                    42690000
         DC    7X'00'                                                   42700000
         DC    CL14'00000000000000',X'00' * Key of version record       42710000
         DC    CL14' ',X'00'                                            42720000
         DC    7X'00'                                                   42730000
*                                                                       42740000
         SPACE 3                                                        42750000
CPDFDB   DS    0D                                                       42760000
         DC    AL4(CCXFDB)                                              42770000
         DC    F'0'                                                     42780000
         DC    CL8'CPD     '                                            42790000
         DC    6F'0'                                                    42800000
         DC    AL4(CPDMAP)                                              42810000
         DC    2H'0'                                                    42820000
         DC    H'300'                                                   42830000
         DC    AL1(15)                                                  42840000
         DC    X'01'                                                    42850000
         DC    7X'00'                                                   42860000
         DC    CL15'000000000000000'   * Key of version record          42870000
         DC    CL15' '                                                  42880000
         DC    7X'00'                                                   42890000
*                                                                       42900000
         SPACE 3                                                        42910000
CCXFDB   DS    0D                                                       42920000
         DC    AL4(PDDFDB)                                              42930000
         DC    F'0'                                                     42940000
         DC    CL8'CCX     '                                            42950000
         DC    6F'0'                                                    42960000
         DC    AL4(CCXMAP)                                              42970000
         DC    2H'0'                                                    42980000
         DC    H'74'                                                    42990000
         DC    AL1(14)                                                  43000000
         DC    X'02'                                                    43010000
         DC    7X'00'                                                   43020000
         DC    CL14'00000000000000',X'00' * Key of version record       43030000
         DC    CL14' ',X'00'                                            43040000
         DC    7X'00'                                                   43050000
*                                                                       43060000
         SPACE 3                                                        43070000
PDDFDB   DS    0D                                                       43080000
         DC    AL4(CSCFDB)                                              43090000
         DC    F'0'                                                     43100000
         DC    CL8'PDD     '                                            43110000
         DC    6F'0'                                                    43120000
         DC    AL4(PDDMAP)                                              43130000
         DC    2H'0'                                                    43140000
         DC    H'42'                                                    43150000
         DC    AL1(14)                                                  43160000
         DC    X'03'                                                    43170000
         DC    7X'00'                                                   43180000
         DC    CL14'00000000000000',X'00' * Key of version record       43190000
         DC    CL14' ',X'00'                                            43200000
         DC    7X'00'                                                   43210000
*                                                                       43220000
         SPACE 3                                                        43230000
CSCFDB   DS    0D                                                       43240000
         DC    AL4(ACDFDB)                                              43250000
         DC    F'0'                                                     43260000
         DC    CL8'CSC     '                                            43270000
         DC    6F'0'                                                    43280000
         DC    AL4(CSCMAP)                                              43290000
         DC    2H'0'                                                    43300000
         DC    H'47'                                                    43310000
         DC    AL1(14)                                                  43320000
         DC    X'04'                                                    43330000
         DC    7X'00'                                                   43340000
         DC    CL14'00000000000000',X'00' * Key of version record       43350000
         DC    CL14' ',X'00'                                            43360000
         DC    7X'00'                                                   43370000
*                                                                       43380000
         SPACE 3                                                        43390000
ACDFDB   DS    0D                                                       43400000
         DC    F'0'                                                     43410000
         DC    F'0'                                                     43420000
         DC    CL8'ACD     '                                            43430000
         DC    6F'0'                                                    43440000
         DC    AL4(ACDMAP)                                              43450000
         DC    2H'0'                                                    43460000
         DC    H'46'                                                    43470000
         DC    AL1(14)                                                  43480000
         DC    X'05'                                                    43490000
         DC    7X'00'                                                   43500000
         DC    CL14'00000000000000',X'00' * Key of version record       43510000
         DC    CL14' ',X'00'                                            43520000
         DC    7X'00'                                                   43530000
*                                                                       43540000
         SPACE 3                                                        43550000
*                                                                       43560000
* Data map-lists defining mapping of data between record and parameter  43570000
*                                                                       43580000
CCDMAP   DC    H'0'                    * Nr of elements after this one  43590000
         DC    CL2'01'                 * Version number                 43600000
         DC    AL4(CCD01)              * Start addr of map version 01   43610000
*                                                                       43620000
CCD01    DC    H'0'                    * Nr of elements after this one  43630000
         DC    H'350'                  * Data length                    43640000
         DC    AL2(17)                 * Offset in parameter            43650000
         DC    H'0'                    * Offset in record               43660000
*                                                                       43670000
CPDMAP   DC    H'0'                    * Nr of elements after this one  43680000
         DC    CL2'02'                 * Version number                 43690000
         DC    AL4(CPD01)              * Start addr of map version 02   43700000
*                                                                       43710000
CPD01    DC    H'0'                    * Nr of elements after this one  43720000
         DC    H'300'                  * Data length                    43730000
         DC    AL2(18)                 * Offset in parameter            43740000
         DC    H'0'                    * Offset in record               43750000
*                                                                       43760000
CCXMAP   DC    H'0'                    * Nr of elements after this one  43770000
         DC    CL2'03'                 * Version number                 43780000
         DC    AL4(CCX01)              * Start addr of map version 03   43790000
*                                                                       43800000
CCX01    DC    H'0'                    * Nr of elements after this one  43810000
         DC    H'74'                   * Data length                    43820000
         DC    AL2(17)                 * Offset in parameter            43830000
         DC    H'0'                    * Offset in record               43840000
*                                                                       43850000
PDDMAP   DC    H'0'                    * Nr of elements after this one  43860000
         DC    CL2'04'                 * Version number                 43870000
         DC    AL4(PDD01)              * Start addr of map version 04   43880000
*                                                                       43890000
PDD01    DC    H'0'                    * Nr of elements after this one  43900000
         DC    H'42'                   * Data length                    43910000
         DC    AL2(17)                 * Offset in parameter            43920000
         DC    H'0'                    * Offset in record               43930000
*                                                                       43940000
CSCMAP   DC    H'0'                    * Nr of elements after this one  43950000
         DC    CL2'05'                 * Version number                 43960000
         DC    AL4(CSC01)              * Start addr of map version 05   43970000
*                                                                       43980000
CSC01    DC    H'0'                    * Nr of elements after this one  43990000
         DC    H'47'                   * Data length                    44000000
         DC    AL2(17)                 * Offset in parameter            44010000
         DC    H'0'                    * Offset in record               44020000
*                                                                       44030000
ACDMAP   DC    H'0'                    * Nr of elements after this one  44040000
         DC    CL2'06'                 * Version number                 44050000
         DC    AL4(ACD01)              * Start addr of map version 05   44060000
*                                                                       44070000
ACD01    DC    H'0'                    * Nr of elements after this one  44080000
         DC    H'46'                   * Data length                    44090000
         DC    AL2(17)                 * Offset in parameter            44100000
         DC    H'0'                    * Offset in record               44110000
*                                                                       44120000
         EJECT                                                          44130000
*                                                                       44140000
* Error codes: error text + returncode + reasoncode + error exit addr   44150000
*                                                                       44160000
* Whenever returncodes are changed: do check that returning is done     44170000
* correctly for all locations where the error is initiated.             44180000
*                                                                       44190000
ERRORTAB DS    0D                                                       44200000
         AIF   (&DBG).ERROR1                                            44210000
         DC    CL50' 1 - sequential end-of-file has been reached'       44220000
         DC    CL6'      ',X'00',C'1',H'001',F'0'                       44230000
         DC    CL50' 2 - requested record not found'                    44240000
         DC    CL6'      ',X'04',C'1',H'002',AL4(VSERR)                 44250000
         AGO   .ERROR1A                                                 44260000
.ERROR1  ANOP                                                           44270000
         DC    CL50'01 - sequential end-of-file has been reached'       44280000
         DC    CL6'      ',X'00',C'1',H'001',F'0'                       44290000
         DC    CL50'02 - requested record not found'                    44300000
         DC    CL6'      ',X'04',C'1',H'002',AL4(VSERR)                 44310000
.ERROR1A ANOP                                                           44320000
         DC    CL50'03 - file selector not 0 or 1: 0 assumed'           44330000
         DC    CL6'      ',X'00',C'2',H'003',F'0'                       44340000
         DC    CL50'04 - no files selected, request ignored'            44350000
         DC    CL6'      ',X'00',C'2',H'004',F'0'                       44360000
         DC    CL50'05 - file is open: open request ignored'            44370000
         DC    CL6'      ',X'00',C'2',H'005',F'0'                       44380000
         DC    CL50'06 - file is not open: close request ignored'       44390000
         DC    CL6'      ',X'00',C'2',H'006',F'0'                       44400000
         DC    CL50'07 - cannot read sequential, trying random read'    44410000
         DC    CL6'      ',X'00',C'2',H'007',F'0'                       44420000
         DC    CL50'08 - cannot read random, trying sequential read'    44430000
         DC    CL6'      ',X'00',C'2',H'008',F'0'                       44440000
         DC    CL50'09 - cannot write sequential, trying random write'  44450000
         DC    CL6'      ',X'00',C'2',H'009',F'0'                       44460000
         DC    CL50'10 - cannot write random, trying sequential write'  44470000
         DC    CL6'      ',X'00',C'2',H'010',F'0'                       44480000
         DC    CL50'11 - ECB unexpectedly in use, skip postponed'       44490000
         DC    CL6'      ',X'04',C'2',H'011',F'0'                       44500000
         DC    CL50'12 - ECB unexpectedly in use, read postponed'       44510000
         DC    CL6'      ',X'04',C'2',H'012',F'0'                       44520000
         DC    CL50'13 - ECB unexpectedly in use, write postponed'      44530000
         DC    CL6'      ',X'04',C'2',H'013',F'0'                       44540000
         DC    CL50'14 - ECB unexpectedly in use, insert postponed'     44550000
         DC    CL6'      ',X'04',C'2',H'014',F'0'                       44560000
         DC    CL50'15 - ECB unexpectedly in use, delete postponed'     44570000
         DC    CL6'      ',X'04',C'2',H'015',F'0'                       44580000
         DC    CL50'16 - ECB unexpectedly in use, close postponed'      44590000
         DC    CL6'      ',X'04',C'2',H'016',F'0'                       44600000
         DC    CL50'17 - VSAM resource pool could not be allocated'     44610000
         DC    CL6'      ',X'00',C'2',H'017',AL4(VSERR)                 44620000
         DC    CL50'18 - VSAM resource pool could not be freed'         44630000
         DC    CL6'      ',X'00',C'2',H'018',AL4(VSERR)                 44640000
         DC    CL50'19 - cannot open input: file is open for update'    44650000
         DC    CL6'      ',X'00',C'2',H'019',F'0'                       44660000
         DC    CL50'20 - key length not changed for skip'               44670000
         DC    CL6'      ',X'04',C'2',H'020',AL4(VSERR)                 44680000
         DC    CL50'21 - file closed, last update was not version rec'  44690000
         DC    CL6'      ',X'00',C'2',H'021',F'0'                       44700000
         DC    CL50'22 - ACB/RPL-storage could not be freed'            44710000
         DC    CL6'      ',X'00',C'2',H'022',F'0'                       44720000
         DC    CL50'23 - cannot obtain storage for ACB/RPL'             44730000
         DC    CL6'      ',X'00',C'5',H'023',F'0'                       44740000
         DC    CL50'24 - workarea for insert/delete could not be freed' 44750000
         DC    CL6'      ',X'00',C'2',H'024',F'0'                       44760000
         DC    CL50'25 - storage for USERAREA/FDB could not be freed'   44770000
         DC    CL6'      ',X'00',C'2',H'025',AL4(UAERR)                 44780000
         DC    CL50'26 - no input parameter'                            44790000
         DC    CL6'      ',X'00',C'3',H'026',AL4(UAERR)                 44800000
         DC    CL50'27 - requested function code not supported'         44810000
         DC    CL6'      ',X'00',C'3',H'027',F'0'                       44820000
         DC    CL50'28 - requested version of parameter not supported'  44830000
         DC    CL6'      ',X'00',C'3',H'028',F'0'                       44840000
         DC    CL50'29 - file version records are not equal'            44850000
         DC    CL6'      ',X'00',C'3',H'029',F'0'                       44860000
         DC    CL50'30 - cannot open update: file is open for input'    44870000
         DC    CL6'      ',X'00',C'3',H'030',F'0'                       44880000
         DC    CL50'31 - file is not open, skip request ignored'        44890000
         DC    CL6'      ',X'00',C'3',H'031',F'0'                       44900000
         DC    CL50'32 - file is not open, read request ignored'        44910000
         DC    CL6'      ',X'00',C'3',H'032',F'0'                       44920000
         DC    CL50'33 - file not open for update, cannot write'        44930000
         DC    CL6'      ',X'00',C'3',H'033',F'0'                       44940000
         DC    CL50'34 - file not open for update, cannot insert'       44950000
         DC    CL6'      ',X'00',C'3',H'034',F'0'                       44960000
         DC    CL50'35 - file not open for update, cannot delete'       44970000
         DC    CL6'      ',X'00',C'3',H'035',F'0'                       44980000
         DC    CL50'36 - skip request illegal, file is opened random'   44990000
         DC    CL6'      ',X'00',C'3',H'036',F'0'                       45000000
         DC    CL50'37 - cannot skip: specified skip-key is too short'  45010000
         DC    CL6'      ',X'04',C'3',H'037',F'0'                       45020000
         DC    CL50'38 - sequential input requested after end-of-file'  45030000
         DC    CL6'      ',X'00',C'3',H'038',F'0'                       45040000
         DC    CL50'39 - cannot read: specified key is not numeric'     45050000
         DC    CL6'      ',X'00',C'3',H'039',F'0'                       45060000
         DC    CL50'40 - cannot insert: specified key is not numeric'   45070000
         DC    CL6'      ',X'00',C'3',H'040',F'0'                       45080000
         DC    CL50'41 - write request not preceded by successful read' 45090000
         DC    CL6'      ',X'00',C'3',H'041',F'0'                       45100000
         DC    CL50'42 - delete request not preceded by successful rea' 45110000
         DC    CL6'd     ',X'00',C'3',H'042',F'0'                       45120000
         DC    CL50'43 - write requested, but keys are not equal'       45130000
         DC    CL6'      ',X'00',C'3',H'043',F'0'                       45140000
         DC    CL50'44 - delete requested, but keys are not equal'      45150000
         DC    CL6'      ',X'00',C'3',H'044',F'0'                       45160000
         DC    CL50'45 - insert requested, but keys are not equal'      45170000
         DC    CL6'      ',X'00',C'3',H'045',F'0'                       45180000
         DC    CL50'46 - insert requested, but key is not unique'       45190000
         DC    CL6'      ',X'04',C'3',H'046',AL4(VSERR)                 45200000
         DC    CL50'47 - insert of version record not allowed'          45210000
         DC    CL6'      ',X'00',C'3',H'047',F'0'                       45220000
         DC    CL50'48 - delete of version record not allowed'          45230000
         DC    CL6'      ',X'00',C'3',H'048',F'0'                       45240000
         DC    CL50'49 - cannot create ACB: file not opened'            45250000
         DC    CL6'      ',X'00',C'4',H'049',AL4(VSERR)                 45260000
         DC    CL50'50 - cannot create RPL: file not opened'            45270000
         DC    CL6'      ',X'00',C'4',H'050',AL4(VSERR)                 45280000
         DC    CL50'51 - file could not be opened'                      45290000
         DC    CL6'      ',X'00',C'4',H'051',AL4(VSERR)                 45300000
         DC    CL50'52 - skip request rejected by VSAM'                 45310000
         DC    CL6'      ',X'08',C'4',H'052',AL4(VSERR)                 45320000
         DC    CL50'53 - read request rejected by VSAM'                 45330000
         DC    CL6'      ',X'08',C'4',H'053',AL4(VSERR)                 45340000
         DC    CL50'54 - insert request rejected by VSAM'               45350000
         DC    CL6'      ',X'08',C'4',H'054',AL4(VSERR)                 45360000
         DC    CL50'55 - delete request rejected by VSAM'               45370000
         DC    CL6'      ',X'08',C'4',H'055',AL4(VSERR)                 45380000
         DC    CL50'56 - cannot re-establish addressability'            45390000
         DC    CL6'      ',X'00',C'5',H'056',F'0'                       45400000
         DC    CL50'57 - VSAM returned no record nor EOF on read'       45410000
         DC    CL6'      ',X'08',C'4',H'057',F'0'                       45420000
         DC    CL50'58 - sequential position in file not defined'       45430000
         DC    CL6'      ',X'08',C'4',H'058',AL4(VSERR)                 45440000
         DC    CL50'59 - data buffer could not be marked for output'    45450000
         DC    CL6'      ',X'08',C'4',H'059',AL4(VSERR)                 45460000
         DC    CL50'60 - close request failed'                          45470000
         DC    CL6'      ',X'08',C'4',H'060',F'0'                       45480000
         DC    CL50'61 - RPL could not be changed: insert impossible'   45490000
         DC    CL6'      ',X'08',C'4',H'061',AL4(VSERR)                 45500000
         DC    CL50'62 - RPL could not be changed: delete impossible'   45510000
         DC    CL6'      ',X'08',C'4',H'062',AL4(VSERR)                 45520000
         DC    CL50'63 - cannot reset RPL to normal processing'         45530000
         DC    CL6'      ',X'04',C'4',H'063',AL4(VSERR)                 45540000
         DC    CL50'64 - I/O could not be completed successfully'       45550000
         DC    CL6'      ',X'08',C'4',H'064',AL4(LGERR)                 45560000
         DC    CL50'65 - VSAM returned errorcode in ECB'                45570000
         DC    CL6'      ',X'04',C'4',H'065',AL4(VSERR)                 45580000
         DC    CL50'66 - cannot extend (shared) data set'               45590000
         DC    CL6'      ',X'08',C'4',H'066',AL4(VSERR)                 45600000
         DC    CL50'67 - a physical I/O-error occurred'                 45610000
         DC    CL6'      ',X'08',C'4',H'067',AL4(VSERR)                 45620000
         DC    CL50'68 - cannot load dynamic module BXAIO00'            45630000
         DC    CL6'      ',X'00',C'5',H'068',F'0'      *** Cannot occur 45640000
         DC    CL50'69 - dynamic storage request for USERAREA/FDB fail' 45650000
         DC    CL6'ed    ',X'00',C'5',H'069',AL4(UAERR)                 45660000
         DC    CL50'70 - cannot allocate work-area for insert/delete'   45670000
         DC    CL6'      ',X'00',C'5',H'070',F'0'                       45680000
         DC    CL50'71 - not enough virtual storage for VSAM'           45690000
         DC    CL6'      ',X'08',C'5',H'071',AL4(VSERR)                 45700000
         DC    CL50'72 - not enough buffers in buffer pool'             45710000
         DC    CL6'      ',X'08',C'5',H'072',AL4(VSERR)                 45720000
         DC    CL50'73 - current record address in PLH and FDB not equ' 45730000
         DC    CL6'al    ',X'08',C'4',H'073',F'0'                       45740000
         DC    CL50'74 - cannot remove dynamic module BXAIO00'          45750000
         DC    CL6'      ',X'00',C'5',H'074',F'0'                       45760000
         DC    CL50'75 - cannot obtain storage for snap control block'  45770000
         DC    CL6'      ',X'00',C'2',H'075',F'0'                       45780000
         DC    CL50'76 - cannot open snap output file (sysudump)'       45790000
         DC    CL6'      ',X'00',C'2',H'076',F'0'                       45800000
         DC    CL50'77 - snap was unsuccessful'                         45810000
         DC    CL6'      ',X'00',C'2',H'077',F'0'                       45820000
         DC    CL50'78 - cannot close snap output file (sysudump)'      45830000
         DC    CL6'      ',X'00',C'2',H'078',F'0'                       45840000
         DC    CL50'79 - cannot free storage of snap control block'     45850000
         DC    CL6'      ',X'00',C'2',H'079',F'0'                       45860000
         DC    CL50'80 - cannot build resource pool for index buffers'  45870000
         DC    CL6'      ',X'00',C'2',H'080',AL4(VSERR)                 45880000
         DC    CL50'81 - not enough storage for snaplist, cannot snap'  45890000
         DC    CL6'      ',X'00',C'2',H'081',F'0'                       45900000
ERRORTND DC    CL50'82 - unidentified error'                            45910000
         DC    CL6'      ',X'00',C'5',H'082',F'0'                       45920000
*                                                                       45930000
         SPACE 3                                                        45940000
*                                                                       45950000
* LGERRTAB is a table used for translating RPL-reasoncodes (1 byte)     45960000
* to errorcodes that can be used with the errortab.                     45970000
*                                                                       45980000
LGERRTAB DS    0D                                                       45990000
         DC    X'04',X'00',H'001'      * End-of-file                    46000000
         DC    X'08',X'00',H'046'      * Duplicate key                  46010000
         DC    X'10',X'00',H'002'      * Record not found               46020000
         DC    X'1C',X'00',H'066'      * Dataset not extendable         46030000
         DC    X'28',X'00',H'071'      * Insufficient virtual storage   46040000
         DC    X'58',X'00',H'058'      * Sequential location undefined  46050000
LGTABEND DC    X'98',X'00',H'072'      * Insufficient buffers in pool   46060000
*                                                                       46070000
         SPACE 3                                                        46080000
*                                                                       46090000
* CRASHMEM area is used only in emergencies when a USERAREA cannot be   46100000
* obtained or the parameter was not supplied by the caller.             46110000
* The first word of this area serves as a lock-word against concurrency 46120000
* errors. A value of zero indicates the area is available.              46130000
* A total length equal to that of USERAREA is quite enough to           46140000
* accomodate space for an emergency USERAREA, overlaid with the part    46150000
* of the parameter that may be used yet.                                46160000
*                                                                       46170000
CRASHMEM DC    (8+L'USERAREA)X'00'     * Prefill with zeros.            46180000
LASTADDR EQU   *                                                        46190000
*                                                                       46200000
         EJECT                                                          46210000
*                                                                       46220000
* This DSECT describes the elements of the opcode table                 46230000
*                                                                       46240000
DSOPC    DSECT                                                          46250000
OPC      DS    0D                      * Opcode table element           46260000
OPCFCOD  DS    CL2                     * Text of opcode (LNSFCODE)      46270000
OPCMASK  DS    XL1                     * Mask for FDBREQ                46280000
         DS    XL1                     * Filler byte                    46290000
OPCROUT  DS    AL4                     * Exit routine                   46300000
*                                                                       46310000
         SPACE 3                                                        46320000
*                                                                       46330000
* This DSECT describes the elements of the error table                  46340000
*                                                                       46350000
DSERR    DSECT                                                          46360000
ERR      DS    0D                      * Error table element            46370000
ERRTEXT  DS    CL56                    * Text of error                  46380000
ERRFDBCD DS    X                       * Error code for FDB             46390000
ERRRETCD DS    X                       * Return code for caller         46400000
ERRREASN DS    H                       * Reasoncode                     46410000
ERRROUT  DS    AL4                     * Error exit routine             46420000
ERR_LEN  EQU   *-DSERR                 * Length of error entry          46430000
         AIF   (ERR_LEN EQ 64).ERLENOK                                  46440000
         MNOTE 8,'ERROR routine uses fixed length of 64 for DSERR'      46450000
.ERLENOK ANOP                                                           46460000
*                                                                       46470000
         SPACE 3                                                        46480000
*                                                                       46490000
* This DSECT describes the elements of the LGERRTAB table               46500000
*                                                                       46510000
DSLGERR  DSECT                                                          46520000
LGERRELM DS    0F                      * Error table element            46530000
LGREASON DS    X                       * Reason code                    46540000
         DS    X                       * Filler                         46550000
LGERCODE DS    H                       * Error code for error table     46560000
*                                                                       46570000
         EJECT                                                          46580000
*                                                                       46590000
* This DSECT describes the caller-dependent data-area.                  46600000
* Its length is dependent on the number of FDBs to be accomodated in    46610000
* the UAFILES field. if &NOOFFDB changes, the length of USERAREA may    46620000
* have to be changed as well. The &WORKLV variable is calculated        46630000
* elsewhere such that UAWORKAR will be long enough to accommodate       46640000
* any code that needs to be changed.                                    46650000
* Remember never to move the UASAVEAR-field from its first position     46660000
* in the user-area                                                      46670000
*                                                                       46680000
DSUSERAR DSECT                                                          46690000
USERAREA DS    0CL(168+&WORKLV)                                         46700000
UASAVEAR DS    18F                     * Savearea for any called module 46710000
UAWORKAR DS    XL&WORKLV               * Space for work-area            46720000
UALV1SAV DS    F                       * Ret addr from level1 routines  46730000
UALV2SAV DS    F                       * Ret addr from level2 routines  46740000
UAERRSAV DS    F                       * Ret addr from error routine    46750000
UAERXSAV DS    F                       * Ret addr from error exits      46760000
UABASSAV DS    F                       * Saved basereg of calling rout  46770000
UASNAPTR DS    AL4                     * Addr of snap control block     46780000
UAFDBPTR DS    AL4                     * Addr of first FDB on chain     46790000
UALRECAD DS    AL4                     * Addr record read for last FDB  46800000
UAOPCADR DS    AL4                     * Addr of opcode element         46810000
UACALLNR DS    F                       * Call count for current caller  46820000
UAIOCNT  DS    F                       * Total nr of check/open/close   46830000
UAVSAMRC DS    F                       * Saved returncode from VSAM     46840000
UALRECLV DS    H                       * Compare length for UALRECAD    46850000
UAREASN  DS    H                       * Reasoncode of worst error      46860000
UARETCD  DS    X                       * Highest returncode encountered 46870000
UASTAT   DS    X                       * Status bits                    46880000
UAPOOLNR DS    X                       * LST-poolnr 00-0f or no LSR 10  46890000
UAVRPSTA DS    X                       * Status of VSAM resource pool   46900000
UAWORK   DS    X                       * Working byte                   46910000
UAVERSI  DS    CL2                     * Version / release level        46920000
UASELECT DS    0CL8                    * Logical file selectors         46930000
UASCCDI  DS    CL1                     * Customer Contract Data         46940000
UASCPDI  DS    CL1                     * Customer Personal Data         46950000
UASCCXI  DS    CL1                     * Customer Contract eXtension    46960000
UASPDDI  DS    CL1                     * Product Definition Data        46970000
UASCSCI  DS    CL1                     * Capitalized Savings Contract   46980000
UASACDI  DS    CL1                     * ACounting Data                 46990000
         DS    CL2                     * Reserved                       47000000
UAFILES  DS    CL&NOOFFDB              * File indicators                47010000
UAKEY    DS    CL&MAXKEY               * Current key (from LNSKEY)      47020000
         DS    (29-&NOOFFDB-&MAXKEY)X  * Reserved                       47030000
*                                                                       47040000
         SPACE                                                          47050000
*                                                                       47060000
* Bit masks for UASTAT                                                  47070000
*                                                                       47080000
UANOREQ  EQU   B'00000000'             * No outstanding requests        47090000
UARQREAD EQU   B'00100000'             * Request to restart read        47100000
UASNAPOP EQU   B'10000000'             * Snap-file is open              47110000
UASNAPER EQU   B'01000000'             * Rsnap encountered serious err  47120000
*                                                                       47130000
UARQNORX EQU   B'11011111'             * Reset mask for restart read    47140000
UASNAPCL EQU   B'01111111'             * Reset mask for closed snapfile 47150000
*                                                                       47160000
         SPACE                                                          47170000
*                                                                       47180000
* Bit masks for UAVRPSTA                                                47190000
*                                                                       47200000
UAVCLOSE EQU   B'00000000'             * No VRP is defined              47210000
UAVEXIST EQU   B'00000001'             * VRP is defined                 47220000
UAVRANDM EQU   B'00000100'             * VRP allocated for random acces 47230000
UAVERROR EQU   B'10000000'             * Error on VRP processing        47240000
*                                                                       47250000
         SPACE 3                                                        47260000
*                                                                       47270000
* Equates for offsets in the savearea (first 18 words of USERAREA)      47280000
*                                                                       47290000
SAVEPLI  EQU   0                       * First word used by PL/I only   47300000
SAVEPREV EQU   4                       * Pointer ro previous save-area  47310000
SAVENEXT EQU   8                       * Pointer to next savearea       47320000
SAVEDR14 EQU   12                      * Return addr for current call   47330000
SAVEDR15 EQU   16                      * Entry-point address of         47340000
*                                      *          current call          47350000
SAVEDR0  EQU   20                      * Original contents of R0        47360000
SAVEDR1  EQU   24                      * Address of plist for this call 47370000
SAVEDR2  EQU   28                      * Original contents of R2        47380000
SAVEDR3  EQU   32                      * Original contents of R3        47390000
SAVEDR4  EQU   36                      * Original contents of R4        47400000
SAVEDR5  EQU   40                      * Original contents of R5        47410000
SAVEDR6  EQU   44                      * Original contents of R6        47420000
SAVEDR7  EQU   48                      * Original contents of R7        47430000
SAVEDR8  EQU   52                      * Original contents of R8        47440000
SAVEDR9  EQU   56                      * Original contents of R9        47450000
SAVEDR10 EQU   60                      * Original contents of R10       47460000
SAVEDR11 EQU   64                      * Original contents of R11       47470000
SAVEDR12 EQU   68                      * Original contents of R12       47480000
*                                                                       47490000
         SPACE 3                                                        47500000
*                                                                       47510000
* Statements below are for ensuring that UAWORKAR will be large         47520000
* enough for all data and coding that is to be put into it.             47530000
* If - for any reason - lengths are changed so that a data area         47540000
* that is to use the UAWORKAR-field does not fit in it anymore          47550000
* an error (due to negative length) will be generated.                  47560000
*                                                                       47570000
         DS    0CL(&WORKLV-VSAMOPLV)   * Plist of vsamopen              47580000
         DS    0CL(&WORKLV-CLOSELV)    * Plist of close                 47590000
         DS    0CL(&WORKLV-BLDVRDLV)   * Plist of bldvrpd               47600000
         DS    0CL(&WORKLV-BLDVRILV)   * Plist of bldvrpi               47610000
         DS    0CL(&WORKLV-ERRWTOLV)   * Plist of errwto                47620000
         DS    0CL(&WORKLV-SHOWACLV)   * Plist generated by showcb ACB  47630000
         DS    0CL(&WORKLV-ERRWTOLV-SHOWACLV) * Used together in vserr  47640000
         DS    0CL(&WORKLV-MODCBDLV)   * Plist gen'ed by modcb (delete) 47650000
         DS    0CL(&WORKLV-MODCBILV)   * Plist gen'ed by modcb (insert) 47660000
         DS    0CL(&WORKLV-MODCNDLV)   * Plist gen'ed by modcb (no del) 47670000
         DS    0CL(&WORKLV-MODCNILV)   * Plist gen'ed by modcb (no ins) 47680000
         DS    0CL(&WORKLV-MODCBKLV)   * Plist gen'ed by modcb (key)    47690000
         DS    0CL(&WORKLV-GACLISLV)   * Plist generated for gencb ACB  47700000
         DS    0CL(&WORKLV-GACLIRLV)   * Plist generated for gencb ACB  47710000
         DS    0CL(&WORKLV-GACLUSLV)   * Plist generated for gencb ACB  47720000
         DS    0CL(&WORKLV-GACLURLV)   * Plist generated for gencb ACB  47730000
         DS    0CL(&WORKLV-GACPISLV)   * Plist generated for gencb ACB  47740000
         DS    0CL(&WORKLV-GACPIRLV)   * Plist generated for gencb ACB  47750000
         DS    0CL(&WORKLV-GACPUSLV)   * Plist generated for gencb ACB  47760000
         DS    0CL(&WORKLV-GACPURLV)   * Plist generated for gencb ACB  47770000
         DS    0CL(&WORKLV-GRPLISLV)   * Plist generated for gencb RPL  47780000
         DS    0CL(&WORKLV-GRPLIRLV)   * Plist generated for gencb RPL  47790000
         DS    0CL(&WORKLV-GRPLUSLV)   * Plist generated for gencb RPL  47800000
         DS    0CL(&WORKLV-GRPLURLV)   * Plist generated for gencb RPL  47810000
         AIF   (NOT &DBG).DSFDB                                         47820000
         DS    0CL(&WORKLV-SNAPOPLV)   * Plist of snapopen              47830000
         DS    0CL(&WORKLV-RSNAPPLV)   * Plist of rsnapsnp              47840000
.DSFDB   ANOP                                                           47850000
*                                                                       47860000
         EJECT                                                          47870000
*                                                                       47880000
* This DSECT describes the file descriptor blocks.                      47890000
* Each FDB is used to control 1 physical file; logical files are        47900000
* mapped onto physical files in a n:m relationship. (currently 1:1)     47910000
* This mapping is done in phase1.                                       47920000
*                                                                       47930000
DSFDB    DSECT                                                          47940000
FDB      DS    0CL96                   * File Descriptor Block          47950000
FDBNEXT  DS    AL4                     * Pointer to next FDB            47960000
FDBECB   DS    F                       * Event control block            47970000
FDBDDNAM DS    CL8                     * DDNAME to use for this file    47980000
FDBDDLOC EQU   FDBDDNAM-FDB            * Offset of DDNAME within FDB    47990000
FDBACB   DS    AL4                     * Address of ACB                 48000000
FDBRPL   DS    AL4                     * Address of RPL                 48010000
FDBREC   DS    AL4                     * Record-address within buffer   48020000
FDBSBUF  DS    AL4                     * Start-of-data current buffer   48030000
FDBEBUF  DS    AL4                     * End-of-data in current buffer  48040000
FDBWAREA DS    AL4                     * Addr of working area for rec'd 48050000
FDBMAP   DS    AL4                     * Address of rec'd/parm map-list 48060000
         DS    H                       * Len of allocated ACB (unused)  48070000
         DS    H                       * Len of allocated RPL (unused)  48080000
FDBRECLV DS    H                       * Logical record length          48090000
FDBKEYLV DS    X                       * Key-length                     48100000
FDBNR    DS    X                       * File-group number              48110000
FDBREASN DS    H                       * Reasoncode for FDBRETCD        48120000
FDBRETCD DS    X                       * Retcd of worst error this FDB  48130000
FDBSTAT  DS    X                       * Status bits                    48140000
FDBSKKLV DS    X                       * Skip-key length value          48150000
FDBREQ   DS    X                       * I/O request bits               48160000
FDBLREQ  DS    X                       * Last completed I/O request     48170000
FDBLKEY  DS    CL&MAXKEY               * Key of FDBLREQ                 48180000
FDBXKEY  DS    CL&MAXKEY               * Extra key for double requests  48190000
         DS    (37-2*&MAXKEY)X         * Reserved                       48200000
*                                                                       48210000
* FDBNEXT must be the first field (thus it is valid, even when the      48220000
*         base register for FDB points to UAFDBPTR)                     48230000
* FDBDDNAM must be on a doubleword boundary                             48240000
*                                                                       48250000
         SPACE                                                          48260000
*                                                                       48270000
* Bit masks for FDBSTAT                                                 48280000
*                                                                       48290000
FDBCLSD  EQU   B'00000000'             * File is currently closed       48300000
FDBINPUT EQU   B'00000001'             * File is open for read only     48310000
FDBUPDAT EQU   B'00000011'             * File is open for read/write    48320000
FDBACRND EQU   B'00000100'             * Access to file is random       48330000
FDBRPLDR EQU   B'00001000'             * RPL-optcd = UPD,MVE (LOC->MVE) 48340000
FDBRPLIR EQU   B'00011000'             * RPL-optcd = NUP,MVE            48350000
*                                      *                 (ID.+UPD->NUP) 48360000
FDBBUFUP EQU   B'00100000'             * Buffer marked for output       48370000
FDBEOF   EQU   B'01000000'             * Eof / file pointer not valid   48380000
FDBERROR EQU   B'10000000'             * Uncorrectable I/O error        48390000
*                                                                       48400000
FDBRPLND EQU   B'11110111'             * Reset-mask from delete-status  48410000
FDBRPLNI EQU   B'11100111'             * Reset-mask from insert status  48420000
FDBBUFNU EQU   B'11011111'             * Reset-mask from buffer marked  48430000
FDBNOEOF EQU   B'10111111'             * Reset eof-condition            48440000
         SPACE                                                          48450000
*                                                                       48460000
* Bit masks for FDBREQ and FDBLREQ                                      48470000
*                                                                       48480000
FDBNOREQ EQU   B'00000000'             * No outstanding requests        48490000
FDBOPEN  EQU   B'10000000'             * Request to open the file       48500000
FDBOPENU EQU   B'10000010'             * Request to open file for updat 48510000
FDBSKIP  EQU   B'01000000'             * Request to seek a partial key  48520000
FDBREAD  EQU   B'00100000'             * Request to read a record       48530000
FDBREAD2 EQU   B'01101000'             * Request to re-execute          48540000
*                                      *                   RRX-routine  48550000
FDBWRITE EQU   B'00010000'             * Request to update a record     48560000
FDBINSRT EQU   B'00001000'             * Request to insert a new record 48570000
FDBDEL   EQU   B'00000100'             * Request to delete a record     48580000
FDBCLOSE EQU   B'00000010'             * Request to close the file      48590000
FDBOPRND EQU   B'00000001'             * Request to open random         48600000
*                                                                       48610000
FDBNOOI  EQU   B'00011110'             * Reset open input request       48620000
FDBNOOU  EQU   B'00011100'             * Reset open update request      48630000
FDBNOSK  EQU   B'10111111'             * Reset skip request             48640000
FDBNORX  EQU   B'11011111'             * Reset read request             48650000
FDBNOWX  EQU   B'11101111'             * Reset write request            48660000
FDBNOIR  EQU   B'11110111'             * Reset insert request           48670000
FDBNODR  EQU   B'11111011'             * Reset delete request           48680000
FDBNOCA  EQU   B'11111101'             * Reset close request            48690000
FDBNORND EQU   B'11111110'             * Reset random specifier         48700000
*                                                                       48710000
* The close-request bit serves also as an update-indicator during open  48720000
* processing. After opening it is reset: Therefore open and close       48730000
* requets cannot be combined in one opcode. This is no problem:         48740000
* the combination would be quite useless anyway.                        48750000
*                                                                       48760000
* The insert-request-bit serves a double function as well: it also      48770000
* indicates a re-read request (issued when read-sequntial reaches       48780000
* end-of-buffer). Thus read and insert cannot be combined into          48790000
* one opcode.                                                           48800000
*                                                                       48810000
         EJECT                                                          48820000
*                                                                       48830000
* This DSECT describes the map master elements (1 per version)          48840000
* For each FDB there is a list of map master elements. These must       48850000
* be in contiguous storage.                                             48860000
*                                                                       48870000
DSMME    DSECT                                                          48880000
MME      DS    0CL8                    * Map Master Element             48890000
MMEREM   DS    H                       * Remaining elements in list     48900000
MMEVERS  DS    CL2                     * Version identifier             48910000
MMEMAP   DS    AL4                     * Start of map for this version  48920000
*                                                                       48930000
* MMEREM gives the number of MME-elements there are in this MME-list    48940000
*        (that is: for the current FDB)                                 48950000
* MMEMAP points to the start of the map for the current FDB and for     48960000
*        the current version                                            48970000
*                                                                       48980000
         SPACE 3                                                        48990000
*                                                                       49000000
* This DSECT describes the map-elements. For each version of each file  49010000
* there must be a map describing how data is to be transferred between  49020000
* record and parameter. The map-elements must be in contiguous storage. 49030000
*                                                                       49040000
DSME     DSECT                                                          49050000
ME       DS    0CL8                    * Parameter block                49060000
MEREM    DS    H                       * Nr of remaining MEs in list    49070000
MEDATLV  DS    H                       * Data length                    49080000
MEPRMOFS DS    H                       * Offset of data in parm         49090000
MERECOFS DS    H                       * Offset of data in record       49100000
*                                                                       49110000
         EJECT                                                          49120000
*                                                                       49130000
* This DSECT describes the parameter that is used for communication     49140000
*                                      with the application program     49150000
*                                                                       49160000
DS83PARM DSECT                                                          49170000
BXAIOPRM DS    0CL1024                 * Parameter block                49180000
         SPACE                                                          49190000
LNSPARM  DS    0CL(3+&MAXKEY)                                           49200000
LNSFCODE DS    CL2                     * Function code                  49210000
LNSRCODE DS    CL1                     * Return code                    49220000
LNSKEY   DS    CL&MAXKEY               * Key                            49230000
         SPACE                                                          49240000
         DS    CL(1021-&MAXKEY)        * Start of record/data area      49250000
*                                      *   for records with             49260000
*                                      *   FDBKEYLV = &MAXKEY           49270000
         SPACE 3                                                        49280000
*                                                                       49290000
* This DSECT describes the parameter that is used for communication     49300000
*                                      with the static part of BXAIO    49310000
*                                                                       49320000
DS83PRM2 DSECT                                                          49330000
LNSPRM2  DS    0CL16                                                    49340000
LNSUAPTR DS    AL4                     * Address of USERAREA            49350000
LNSVERSI DS    CL2                     * Version number of parameter 1  49360000
LNSFILES DS    CL8                     * Logical data-group selectors   49370000
         DS    CL2                     * Reserved                       49380000
*                                                                       49390000
         EJECT                                                          49400000
         AIF   (NOT &DBG).DSSNAP                                        49410000
*                                                                       49420000
* This DSECT is used by the RSANP-routine                               49430000
*                                                                       49440000
DSSNAP   DSECT                                                          49450000
SNAPAREA DS    0CL(120+&SNAPLEN+(&SNAPLEN/2)+SNAPDCBL)                  49460000
SNAPSAVE DS    18F                     * Register save-area             49470000
SNAPLIST DS    XL&SNAPLEN              * Space for storage ranges       49480000
SNAPHDRS DS    XL(&SNAPLEN/2)          * Space for storage header ptrs  49490000
SNAPIDNR DS    X                       * Idnr of last snap, initial 0   49500000
         DS    XL3                     * Filler to realign              49510000
SNAPDCB  DS    XL(SNAPDCBL)            * Space for DCB of snap-file     49520000
         DS    XL40                    * Extension space for DCB        49530000
*                                                                       49540000
         SPACE 3                                                        49550000
.DSSNAP  ANOP                                                           49560000
*                                                                       49570000
* This DSECT describes an access method control block                   49580000
*                                                                       49590000
         IFGACB DSECT=YES,             * Generate DSECT for ACBs       *49600000
               AM=VSAM                 *    used for VSAM-files         49610000
IFGACBLV EQU   *-IFGACB                                                 49620000
*                                                                       49630000
         AIF   (NOT &DBG).IFGRPL                                        49640000
         EJECT                                                          49650000
.IFGRPL  ANOP                                                           49660000
*                                                                       49670000
* This DSECT describes a request parameter list                         49680000
*                                                                       49690000
         IFGRPL DSECT=YES,             * Generate DSECT for RPLs       *49700000
               AM=VSAM                 *    used for VSAM-files         49710000
IFGRPLLV EQU   *-IFGRPL                                                 49720000
*                                                                       49730000
         AIF   (NOT &DBG).IDAPLH                                        49740000
         EJECT                                                          49750000
.IDAPLH  ANOP                                                           49760000
*                                                                       49770000
* This DSECT describes a placeholder                                    49780000
*                                                                       49790000
*        IDAPLH DSECT=YES,AM=VSAM      * IDAPLH macro not present       49800000
IDAPLH   DSECT ,                       * Placeholder                    49810000
         DS    13F                     * First 13 words not described   49820000
PLHDBUFC DS    AL4                     * Addr of current data bufc      49830000
PLHNBUFC DS    AL4                     * Addr of next read bufc         49840000
PLHRECP  DS    AL4                     * Addr of current record         49850000
PLHFSP   DS    AL4                     * Addr of 1st byte of free space 49860000
*                                      * Remainder of PLH not described 49870000
IDAPLHLV EQU   332                     * Total length of a placeholder  49880000
*                                                                       49890000
         SPACE 3                                                        49900000
*                                                                       49910000
* Shrpool-nr in bldvrp is to be changeable. The bldvrp macro does not   49920000
* support register specification of shrpool-parameter. Therefore we     49930000
* must alter the shrpool-byte in the bldvrp-pool ourselves. The         49940000
* shrpool-number is located at offset X'20' in the bldvrp request list. 49950000
*                                                                       49960000
DSBLDVRP DSECT ,                       * Describes bldvrp/dlvrp plists  49970000
BLDVRPTR DS    F                       * Pointer to only element        49980000
BLDVRPHD DS    0F                      * Start of header = only element 49990000
         DS    7F                      * First 28 bytes not described   50000000
BLDVRPNR DS    X                       * Location of shrpoolnr in       50010000
*                                      *              bldvrp-request    50020000
*                                      * Remainder not described        50030000
         END                                                            50040000
