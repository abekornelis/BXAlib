BXAIO    TITLE 'Static stub for dynamic I/O routine BXAIO00'            00010000
*********************************************************************** 00020000
* Start create : 20-03-1989                                             00030000
* 1st delivery : 15-08-1989                                             00040000
* Designer     : AF Kornelis                                            00050000
* Programmer   : AF Kornelis                                            00060000
* Reason       : Untie logical record lay-outs from physical file       00070000
*                structure                                              00080000
*********************************************************************** 00090000
* Change 01    : 21-06-1990                                             00100000
* Programmer   : JB                                                     00110000
* Reason       : Added 2 logical record lay-outs: PDD and CSC           00120000
*********************************************************************** 00130000
* Change 02    : 31-10-1991                                             00140000
* Programmer   : JB                                                     00150000
* Reason       : Added 1 logical record lay-out: CCX                    00160000
*********************************************************************** 00170000
* Change 03    : 31-05-1992                                             00180000
* Programmer   : JB                                                     00190000
* Reason       : Added 1 logical record lay-out: ACD                    00200000
*********************************************************************** 00210000
* Change 04    : 31-05-1996                                             00220000
* Programmer   : JB                                                     00230000
* Reason       : Added 1 logical record lay-out: SVD                    00240000
*********************************************************************** 00250000
* Change 05    : Summer 2001                                            00260000
* Programmer   : Abe F. Kornelis                                        00270000
* Reason       : Replace register numbers with names                    00280000
*                Improve comments                                       00290000
*********************************************************************** 00300000
         EJECT ,                       *                                00310000
         PRINT GEN                     *                                00320000
         ENTRY BXAIOCCD                * Customer Contract Data         00330000
         ENTRY BXAIOCPD                * Customer Personal Data         00340000
         ENTRY BXAIOCCX                * Customer Contract eXtension    00350000
         ENTRY BXAIOPDD                * Product Definition Data        00360000
         ENTRY BXAIOCSC                * Capitalized Savings/Contract   00370000
         ENTRY BXAIOACD                * ACcounting Data                00380000
         ENTRY BXAIOSVD                * SaVings Details                00390000
*********************************************************************** 00400000
* Change implemented on 9-7-2001: use DSECT for entry parm lay-out      00410000
HDRDATA  DSECT ,                       * HeaDeR DATA                    00420000
         B     0                       * Skip header: dummy instruction 00430000
         DS    AL1,CL24                * Entry Point descriptor         00440000
MOVEIN   DS    A                       * Setup routine for parameter 2  00450000
MOVEOUT  DS    A                       * Output conversion routine      00460000
* End of change d.d. 9-7-2001                                           00470000
*********************************************************************** 00480000
* Change implemented on 9-7-2001: use register equates                  00490000
R0       EQU   0                                                        00500000
R1       EQU   1                                                        00510000
R2       EQU   2                                                        00520000
R3       EQU   3                                                        00530000
R4       EQU   4                                                        00540000
R5       EQU   5                                                        00550000
R6       EQU   6                                                        00560000
R7       EQU   7                                                        00570000
R8       EQU   8                                                        00580000
R9       EQU   9                                                        00590000
R10      EQU   10                                                       00600000
R11      EQU   11                                                       00610000
R12      EQU   12                                                       00620000
R13      EQU   13                                                       00630000
R14      EQU   14                                                       00640000
R15      EQU   15                                                       00650000
* End of change d.d. 9-7-2001                                           00660000
*********************************************************************** 00670000
BXAIO    START 0                       *                                00680000
BXAIO    AMODE ANY                                                      00690000
BXAIO    RMODE ANY                                                      00700000
*********************************************************************** 00710000
* Change implemented on 10-7-2001: add error message and abend          00720000
         USING BXAIO,R15               * Establish addressability       00730000
         B     BXAIO_GO                * Skip header data               00740000
         DC    AL1(24),CL24'BXAIO    &SYSDATE &SYSTIME'                 00750000
         DC    A(0)                    * Setup routine for parameter 2  00760000
         DC    A(0)                    * Output conversion routine      00770000
BXAIO_GO EQU   *                                                        00780000
         LR    R12,R15                 * Copy base address              00790000
         DROP  R15                     * No longer needed               00800000
         USING BXAIO,R12               * Re-establish addressability    00810000
         WTO   'BXAIO - Illegal entry point into mudule',              *00820000
               ROUTCDE=11,DESC=7                                        00830000
         DC    X'0000'                 * Force a S0C1 abend             00840000
         CNOP  0,8                     * Re-align on doubleword         00850000
         DROP  R12                     * End of error logic             00860000
* End of change d.d. 9-7-2001                                           00870000
*********************************************************************** 00880000
         SPACE 2                                                        00890000
         USING BXAIOCCD,R15            * Establish addressability (CCD) 00900000
BXAIOCCD B     IOCCD_GO                * Skip header data               00910000
         DC    AL1(24),CL24'BXAIOCCD &SYSDATE &SYSTIME'                 00920000
         DC    A(CCDIN)                * Setup routine for parameter 2  00930000
         DC    A(CCDOUT)               * Output conversion routine      00940000
*                                                                       00950000
IOCCD_GO EQU   *                                                        00960000
         STM   R14,R12,12(R13)         * Save caller's registers        00970000
         LA    R3,BXAIOGO              * Set base register              00980000
         BR    R3                      * and execute main line          00990000
         CNOP  0,8                     * Re-align on doubleword         01000000
         DROP  R15                     * End of entry logic for CCD     01010000
*                                                                       01020000
         SPACE 2                                                        01030000
         USING BXAIOCPD,R15            * Establish addressability (CPD) 01040000
BXAIOCPD B     IOCPD_GO                * Skip header data               01050000
         DC    AL1(24),CL24'BXAIOCPD &SYSDATE &SYSTIME'                 01060000
         DC    A(CPDIN)                * Setup routine for parameter 2  01070000
         DC    A(CPDOUT)               * Output conversion routine      01080000
*                                                                       01090000
IOCPD_GO EQU   *                                                        01100000
         STM   R14,R12,12(R13)         * Save caller's registers        01110000
         LA    R3,BXAIOGO              * Set base register              01120000
         BR    R3                      * and execute main line          01130000
         CNOP  0,8                     * Re-align on doubleword         01140000
         DROP  R15                     * End of entry logic for CPD     01150000
*                                                                       01160000
         SPACE 2                                                        01170000
         USING BXAIOCCX,R15            * Establish addressability (CCX) 01180000
BXAIOCCX B     IOCCX_GO                * Skip header data               01190000
         DC    AL1(24),CL24'BXAIOCCX &SYSDATE &SYSTIME'                 01200000
         DC    A(CCXIN)                * Setup routine for parameter 2  01210000
         DC    A(CCXOUT)               * Output conversion routine      01220000
*                                                                       01230000
IOCCX_GO EQU   *                                                        01240000
         STM   R14,R12,12(R13)         * Save caller's registers        01250000
         LA    R3,BXAIOGO              * Set base register              01260000
         BR    R3                      * and execute main line          01270000
         CNOP  0,8                     * Re-align on doubleword         01280000
         DROP  R15                     * End of entry logic for CCX     01290000
*                                                                       01300000
         SPACE 2                                                        01310000
         USING BXAIOPDD,R15            * Establish addressability (PDD) 01320000
BXAIOPDD B     IOPDD_GO                * Skip header data               01330000
         DC    AL1(24),CL24'BXAIOPDD &SYSDATE &SYSTIME'                 01340000
         DC    A(PDDIN)                * Setup routine for parameter 2  01350000
         DC    A(PDDOUT)               * Output conversion routine      01360000
*                                                                       01370000
IOPDD_GO EQU   *                                                        01380000
         STM   R14,R12,12(R13)         * Save caller's registers        01390000
         LA    R3,BXAIOGO              * Set base register              01400000
         BR    R3                      * and execute main line          01410000
         CNOP  0,8                     * Re-align on doubleword         01420000
         DROP  R15                     * End of entry logic for PDD     01430000
*                                                                       01440000
         SPACE 2                                                        01450000
         USING BXAIOCSC,R15            * Establish addressability (CSC) 01460000
BXAIOCSC B     IOCSC_GO                * Skip header data               01470000
         DC    AL1(24),CL24'BXAIOCSC &SYSDATE &SYSTIME'                 01480000
         DC    A(CSCIN)                * Setup routine for parameter 2  01490000
         DC    A(CSCOUT)               * Output conversion routine      01500000
*                                                                       01510000
IOCSC_GO EQU   *                                                        01520000
         STM   R14,R12,12(R13)         * Save caller's registers        01530000
         LA    R3,BXAIOGO              * Set base register              01540000
         BR    R3                      * and execute main line          01550000
         CNOP  0,8                     * Re-align on doubleword         01560000
         DROP  R15                     * End of entry logic for CSC     01570000
*                                                                       01580000
         SPACE 2                                                        01590000
         USING BXAIOACD,R15            * Establish addressability (ACD) 01600000
BXAIOACD B     IOACD_GO                * Skip header data               01610000
         DC    AL1(24),CL24'BXAIOACD &SYSDATE &SYSTIME'                 01620000
         DC    A(ACDIN)                * Setup routine for parameter 2  01630000
         DC    A(ACDOUT)               * Output conversion routine      01640000
*                                                                       01650000
IOACD_GO EQU   *                                                        01660000
         STM   R14,R12,12(R13)         * Save caller's registers        01670000
         LA    R3,BXAIOGO              * Set base register              01680000
         BR    R3                      * and execute main line          01690000
         CNOP  0,8                     * Re-align on doubleword         01700000
         DROP  R15                     * End of entry logic for ACD     01710000
*                                                                       01720000
         SPACE 2                                                        01730000
         USING BXAIOSVD,R15            * Establish addressability (SVD) 01740000
BXAIOSVD B     IOSVD_GO                * Skip header data               01750000
         DC    AL1(24),CL24'BXAIOSVD &SYSDATE &SYSTIME'                 01760000
         DC    A(SVDIN)                * Setup routine for parameter 2  01770000
         DC    A(SVDOUT)               * Output conversion routine      01780000
*                                                                       01790000
IOSVD_GO EQU   *                                                        01800000
         STM   R14,R12,12(R13)         * Save caller's registers        01810000
         LA    R3,BXAIOGO              * Set base register              01820000
         BR    R3                      * and execute main line          01830000
         CNOP  0,8                     * Re-align on doubleword         01840000
         DROP  R15                     * End of entry logic for SVD     01850000
*                                                                       01860000
         EJECT                                                          01870000
         USING BXAIOGO,R3              * Declare base register          01880000
BXAIOGO  EQU   *                                                        01890000
         LA    R14,SAVEAREA            * Retrieve address of save-area  01900000
         ST    R13,4(R14)              * Set backward pointer           01910000
         XR    R0,R0                   * Set to zero for compare        01920000
         C     R0,0(R13)               * Old save-area is PL/I ??       01930000
         BNE   *+8                     * Yes: no forward pointer !!     01940000
         ST    R14,8(R13)              * Set forward pointer            01950000
         LR    R13,R14                 * and switch to new save-area    01960000
*                                                                       01970000
         SPACE 3                                                        01980000
         LR    R4,R15                  * Set base reg to entry point    01990000
         USING HDRDATA,R4              * Inserted 7-9-2001              02000000
*                                                                       02010000
         OI    PLIST+4,X'80'           * Set end-of-plist               02020000
         LTR   R1,R1                   * Plist ??                       02030000
         BZ    NOPARM                  * No: no conversion              02040000
*  Sometimes end-of-plist marker is missing.                            02050000
**       TM    0(1),X'80'              * End-of-plist correct ??        02060000
**       BNO   NOPARM                  * No: no conversion              02070000
         L     R1,0(R1)                * Get address of parameter       02080000
         LA    R1,0(R1)                * Strip end-of-plist bit         02090000
         LTR   R1,R1                   * Address is valid ??            02100000
         BZ    NOPARM                  * No: no conversion              02110000
         ST    R1,PLIST                * Store address of input-parm    02120000
*                                                                       02130000
         L     R15,MOVEIN              * Get addr of move-input routine 02140000
         BASR  R14,R15                 * and execute it                 02150000
*                                                                       02160000
LOAD     ICM   R15,B'1111',ENTRY       * First time: load BXAIO00       02170000
         BNZ   BXAIO00                 * thereafter: execute immediate  02180000
*                                                                       02190000
         SPACE 3                                                        02200000
         LOAD  EP=BXAIO00,ERRET=ERROR  * Load dynamic I/O routine       02210000
         B     LOADOK                  * I/O routine correctly loaded   02220000
*                                                                       02230000
ERROR    WTO   'BXAIO - 68 - Cannot load dynamic module BXAIO00',      *02240000
               ROUTCDE=11,DESC=7                                        02250000
         LA    R10,68                  * Load reasoncode                02260000
         L     R1,PLIST                * Get address of parameter       02270000
         LTR   R1,R1                   * Valid ??                       02280000
         BZ    EXITERR                 * No: quit                       02290000
         MVI   2(R1),C'5'              * Set retcode in caller's parm   02300000
         B     EXITERR                                                  02310000
*                                                                       02320000
LOADOK   ST    R0,ENTRY                * Save address of load module    02330000
         XC    LNSUAPTR,LNSUAPTR       * Set user-area pointer to zeros 02340000
         LR    R15,R0                  * Copy entry point address       02350000
*                                                                       02360000
         SPACE 3                                                        02370000
BXAIO00  EQU   *                                                        02380000
         LA    R1,PLIST                * Get addr of plist for BXAIO00  02390000
         BASSM R14,R15                 * and execute BXAIO00            02400000
*                                                                       02410000
         LTR   R10,R15                 * BXAIO00 was ok ??              02420000
         BZ    CONTINUE                * Yes: fill caller's parameter   02430000
         L     R1,PLIST                * Retrieve address of parm       02440000
         LTR   R1,R1                   * Is it valid ??                 02450000
         BZ    CONTINUE                * No: cannot process the error   02460000
*                                                                       02470000
         CLI   2(R1),C'1'              * EOF / record not found ??      02480000
         BE    CONTINUE                * Yes: use exit after error      02490000
*                                                                       02500000
         CH    R10,=H'025'             * If userarea could not be freed 02510000
         BNE   NOWIPEUA                * then LNSUAPTR may be invalid   02520000
         XC    LNSUAPTR,LNSUAPTR       * and is therefore to be cleared 02530000
NOWIPEUA EQU   *                                                        02540000
         CLI   2(R1),C'2'              * Error is just a warning ??     02550000
         BE    CONTINUE                * Yes: return output to caller   02560000
         CLI   2(R1),C'0'              * Errorcode set ??               02570000
         BNE   EXITERR                 * Yes: use exit-after-error      02580000
*                                      * Returncode not set: set it     02590000
         CH    R10,=H'025'             * Userarea freeing error ??      02600000
         BNE   NOTERR25                * No: skip setting code 2        02610000
         MVI   2(R1),C'2'              * Set error level to two         02620000
         B     CONTINUE                * and carry on accordingly       02630000
NOTERR25 EQU   *                                                        02640000
*                                                                       02650000
         CH    R10,=H'026'             * No parameter-error ??          02660000
         BNE   NOTERR26                * No: skip setting code 3        02670000
         MVI   2(R1),C'3'              * Set error level to three       02680000
         B     EXITERR                 * And use exit-after-error       02690000
NOTERR26 EQU   *                                                        02700000
*                                                                       02710000
         MVI   2(R1),C'5'              * Other error: set RCODE to 5    02720000
         B     EXITERR                 * and use exit-after-error       02730000
*                                                                       02740000
         EJECT                                                          02750000
CONTINUE EQU   *                       * Statements disabled:no moveout 02760000
*                                                                       02770000
**!!     L     R1,PLIST                * Get address of parm in caller  02780000
**!!     L     R15,MOVEOUT             * Get addr of move-output routin 02790000
**!!     BASR  R14,R15                 * and execute it                 02800000
*                                                                       02810000
         CLC   LNSUAPTR,=F'0'          * USERAREA de-allocated ??       02820000
         BNE   EXITERR                 * No: leave BXAIO00 in storage   02830000
         DELETE EP=BXAIO00             * Remove dynamic mod from memory 02840000
         LTR   R15,R15                 * Delete was ok ??               02850000
         BNE   DELETERR                * No: issue delete error         02860000
         XC    ENTRY,ENTRY             * Next call: reload dynamic mod  02870000
*                                                                       02880000
EXITERR  EQU   *                                                        02890000
         LR    R15,R10                 * Restore saved reasoncode       02900000
*                                                                       02910000
EXIT     EQU   *                                                        02920000
         L     R13,4(R13)              * Retrieve addr of old save-area 02930000
         L     R14,12(R13)             * Restore return address         02940000
         LM    R0,R12,20(R13)          * Restore all other registers    02950000
         BR    R14                     * and return with retcode        02960000
*                                                                       02970000
DELETERR WTO   'BXAIO - 74 - Cannot remove dymanic module BXAIO00',    *02980000
               ROUTCDE=11,DESC=7                                        02990000
         LA    R10,74                  * Load reasoncode                03000000
         L     R1,PLIST                * Get address of parameter       03010000
         LTR   R1,R1                   * Valid ??                       03020000
         BZ    EXITERR                 * No: quit                       03030000
         MVI   2(R1),C'5'              * Set retcode in caller's parm   03040000
         B     EXITERR                                                  03050000
*                                                                       03060000
         SPACE 3                                                        03070000
* Reset end-of-plist bit to cause error - to be issued by BXAIO00       03080000
NOPARM   EQU   *                       * No parameter given by applic.  03090000
         NI    PLIST+4,X'7F'           * Reset end-of-plist bit         03100000
         B     LOAD                    * And go call to issue error     03110000
         DROP  4                       * Inserted 7-9-2001              03120000
*                                                                       03130000
         EJECT                                                          03140000
CCDIN    EQU   *                       * Movein of BXAIOCCD             03150000
         MVC   LNSVERSI,=C'01'         * Set parameter version to 01    03160000
         MVC   LNSFILES,=C'10000000'   * Select all files for CCD-parm  03170000
         BR    R14                     * Return to mainline             03180000
*                                                                       03190000
CCDOUT   EQU   *                       * Moveout of BXAIOCCD            03200000
         BR    R14                     * Return to mainline             03210000
*                                                                       03220000
         SPACE 2                                                        03230000
CPDIN    EQU   *                       * Movein of BXAIOCPD             03240000
         MVC   LNSVERSI,=C'02'         * Set parameter version to 02    03250000
         MVC   LNSFILES,=C'01000000'   * Select all files for CPD-parm  03260000
         BR    R14                     * Return to mainline             03270000
*                                                                       03280000
CPDOUT   EQU   *                       * Moveout of BXAIOCPD            03290000
         BR    R14                     * Return to mainline             03300000
*                                                                       03310000
         SPACE 2                                                        03320000
CCXIN    EQU   *                       * Movein of BXAIOCCX             03330000
         MVC   LNSVERSI,=C'03'         * Set parameter version to 03    03340000
         MVC   LNSFILES,=C'00100000'   * Select all files for CCX-parm  03350000
         BR    R14                     * Return to mainline             03360000
*                                                                       03370000
CCXOUT   EQU   *                       * Moveout of BXAIOCCX            03380000
         BR    R14                     * Return to mainline             03390000
*                                                                       03400000
         SPACE 2                                                        03410000
PDDIN    EQU   *                       * Movein of BXAIOPDD             03420000
         MVC   LNSVERSI,=C'04'         * Set parameter version to 04    03430000
         MVC   LNSFILES,=C'00010000'   * Select all files for PDD-parm  03440000
         BR    R14                     * Return to mainline             03450000
*                                                                       03460000
PDDOUT   EQU   *                       * Moveout of BXAIOPDD            03470000
         BR    R14                     * Return to mainline             03480000
*                                                                       03490000
         SPACE 2                                                        03500000
CSCIN    EQU   *                       * Movein of BXAIOCSC             03510000
         MVC   LNSVERSI,=C'05'         * Set parameter version to 05    03520000
         MVC   LNSFILES,=C'00001000'   * Select all files for CSC-parm  03530000
         BR    R14                     * Return to mainline             03540000
*                                                                       03550000
CSCOUT   EQU   *                       * Moveout of BXAIOCSC            03560000
         BR    R14                     * Return to mainline             03570000
*                                                                       03580000
         SPACE 2                                                        03590000
ACDIN    EQU   *                       * Movein of BXAIOACD             03600000
         MVC   LNSVERSI,=C'06'         * Set parameter version to 06    03610000
         MVC   LNSFILES,=C'00000100'   * Select all files for ACD-parm  03620000
         BR    R14                     * Return to mainline             03630000
*                                                                       03640000
ACDOUT   EQU   *                       * Moveout of BXAIOACD            03650000
         BR    R14                     * Return to mainline             03660000
*                                                                       03670000
         SPACE 2                                                        03680000
SVDIN    EQU   *                       * Movein of BXAIOSVD             03690000
         MVC   LNSVERSI,=C'07'         * Set parameter version to 07    03700000
         MVC   LNSFILES,=C'00000010'   * Select all files for SVD-parm  03710000
         BR    R14                     * Return to mainline             03720000
*                                                                       03730000
SVDOUT   EQU   *                       * Moveout of BXAIOSVD            03740000
         BR    R14                     * Return to mainline             03750000
*                                                                       03760000
         EJECT                                                          03770000
SAVEAREA DS    9D                      * Save-area for all entry points 03780000
ENTRY    DS    F                       * Entry point of dynamic module  03790000
PLIST    DC    A(0)                    * Parameter in application       03800000
         DC    A(LNSPRM2)              * Extra parameter                03810000
*                                                                       03820000
         DS    0D                                                       03830000
LNSPRM2  DS    0CL16                                                    03840000
LNSUAPTR DS    A                       * Address of user-area           03850000
LNSVERSI DS    CL2                     * Parameter version number       03860000
LNSFILES DS    CL8                     * Logical files to be used       03870000
         DS    CL2                     * Reserved                       03880000
*                                                                       03890000
         LTORG                                                          03900000
*                                                                       03910000
         END                                                            03920000
