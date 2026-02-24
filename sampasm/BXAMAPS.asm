*PROCESS FLAG(SUBSTR)                                                   00010000
*PROCESS RENT                                                           00020000
*********************************************************************** 00030000
*                                                                       00040000
* BIXXAMS - Bixoft Cross Access Method Services                         00050000
* Licensed material - Property of B.V. Bixoft                           00060000
*                                                                       00070000
* This program can be licensed or used on an as-is basis.               00080000
* No warranty, neither implicit nor explicit, is given.                 00090000
* It remains your own responsibility to ensure the correct              00100000
* working of this program in your installation.                         00110000
*                                                                       00120000
* Suggestions for improvement are always welcome at                     00130000
* http://www.bixoft.com  or mail to  bixoft@bixoft.nl                   00140000
*                                                                       00150000
* (C) Copyright B.V. Bixoft, 1999-2000                                  00160000
*********************************************************************** 00170000
*                                                                       00180000
* This program performs no function:                                    00190000
*   it is used only for generating a listing of all dsects used.        00200000
*                                                                       00210000
*********************************************************************** 00220000
         LCLC  &SELECT                 * Selection variable             00230000
&SELECT  SETC  'UCB'                   * Select a single map macro      00240000
&SELECT  SETC  '*BXA'                  * Select bixxams map-macros      00250000
&SELECT  SETC  '*ALLMAPS'              * Select all map-macros          00260000
&SELECT  SETC  '*ALLMACS'              * Select all macros              00270000
*                                                                       00280000
         AIF   ('&SELECT'(1,1) EQ '*').NOTSA                            00290000
*                                                                       00300000
* Entry for stand-alone testing new mapping macro's                     00310000
         PGM   VERSION=V00R00M00,      * Version number                *00320000
               HDRTXT='Map testing',   * Header for loadmod            *00330000
               ENTRY=SUBPGM,           * Entry for subroutine          *00340000
               ABND=1,                 * User abend code               *00350000
               MAPS=(&SELECT),         * Map to be tested              *00360000
               LIST=YES                * Generate listing               00370000
         AGO   .END                    *                                00380000
.NOTSA   ANOP  ,                       *                                00390000
&SAVES   SETC  '0'                     * Default                        00400000
         AIF   ('&SELECT' NE '*ALLMACS').SAVESOK                        00410000
&SAVES   SETC  '1'                     * Required for *ALLMACS          00420000
.SAVESOK ANOP  ,                       *                                00430000
*                                                                       00440000
* Entry for a complete overview of all BIXXAMS mapping macro's          00450000
         PGM   VERSION=V00R00M00,      * Version number                *00460000
               HDRTXT='Mapping module for BIXXAMS',                    *00470000
               ENTRY=SUBPGM,           * Entry for subroutine          *00480000
               ABND=1,                 * User abend code               *00490000
               SAVES=&SAVES,           * Internal save areas           *00500000
               MAPS=($AMQS,$BDS,$BDSD,$BDSL,$BDST,$COPY,$DAPL,$DBG,    *00510000
               $OCW,$PCW,$SCB,$SNAP,$SRB,$TST,$UNLD),                  *00520000
               LIST=YES                * And generate a listing         00530000
         AIF   ('&SELECT' EQ '*BXA').END                                00540000
         AIF   ('&SELECT' EQ '*ALLMAPS').GENALL                         00550000
         AIF   ('&SELECT' EQ '*ALLMACS').GENALL                         00560000
&SELECT  SETC  (DOUBLE '&SELECT')      *                                00570000
         MNOTE 8,'Invalid value for &&SELECT - &SELECT'                 00580000
         AGO   .END                    *                                00590000
.GENALL  ANOP  ,                       *                                00600000
*                                                                       00610000
* Other mapping macros (A-C):                                           00620000
         GENMAPS (ABEP,ACB,ACEE,ADSR,ADYENF,AE,ASCB,ASEO,              *00630000
               ASMVT,ASSB,ASVT,ASXB,   *                               *00640000
               BASEA,BITS,             *                               *00650000
               CAM,CDE,CIB,COM,CQE,CSCB,CVT),                          *00660000
               LIST=YES                *                                00670000
*                                                                       00680000
* Other mapping macros (D-I):                                           00690000
         GENMAPS (DCB,DCBE,DDRCOM,DEB,DECB,DES,DFA,DOTU,DSAB,DSABQDB,  *00700000
               DSCB,DSCB1,DSCB2,DSCB3,DSCB4,DSCB5,                     *00710000
               ECB,ECVT,EPAL,EQU,EVNT, *                               *00720000
               FRRPL,FRRS,             *                               *00730000
               GVT,GVTX,               *                               *00740000
               IEANT,IECEQ,IHSA,IOB,IOQ,IOSB),                         *00750000
               LIST=YES                *                                00760000
*                                                                       00770000
* Other mapping macros (J-R):                                           00780000
         GENMAPS (JCT,JCTX,JESCT,JFCB,JFCBE,JFCBX,JSCB,                *00790000
               LCT,LDA,LLE,LMASM,LPDE, *                               *00800000
               OCPL,ORE,OUCB,          *                               *00810000
               PCCA,PCCAVT,PDAB,PDS,PEL,PMAR,PRB,PRMLB,PSA,PSL,PVT,    *00820000
               QCB,QEL,QHT,QMIDS,      *                               *00830000
               RB,RCTD,REGS,RMCT,RMPL,RPL,RQE,RT1W),                   *00840000
               LIST=YES                *                                00850000
*                                                                       00860000
* Other mapping macros (S-Z):                                           00870000
         GENMAPS (SAVE,SCCB,SCT,SCTX,SCVT,SDWA,SIOT,SMCA,SMDE,SNAP,SRB,*00880000
               SSDR,SSL,SSOB,SSRB,STCB,SVCE,SVRB,SVT,SWAPX,S99,        *00890000
               TAXE,TCB,TCCW,TCT,TIOT,TQE,                             *00900000
               UCB,UCM,                *                               *00910000
               VRA,VSL,                *                               *00920000
               WQE,WTOPL,              *                               *00930000
               XSB),                   *                               *00940000
               LIST=YES                *                                00950000
         AIF   ('&SELECT' NE '*ALLMACS').END                            00960000
*                                                                       00970000
* Routine that will never execute                                       00980000
         IF    R12,EQ,R13              * Can never be true              00990000
          EXSR ALLMACS                 *                                01000000
         ELSE  ,                       * Always taken: leave empty      01010000
         ENDIF ,                       *                                01020000
*                                                                       01030000
.END     ANOP  ,                       *                                01040000
*                                                                       01050000
         RETRN RC=0                    * Normal return to caller        01060000
         AIF   ('&SELECT' NE '*ALLMACS').LTORG                          01070000
*********************************************************************** 01080000
*                                                                       01090000
* Routine to inlcude all macros                                         01100000
*                                                                       01110000
*********************************************************************** 01120000
ALLMACS  BEGSR ,                       *                                01130000
*                                                                       01140000
R_SLIST  EQUREG ,                      *                                01150000
         USE   SNAPLIST,R_SLIST        *                                01160000
R_HLIST  EQUREG ,                      *                                01170000
         USE   SNAPHLIST,R_HLIST       *                                01180000
R_DBG    EQUREG ,                      *                                01190000
         USE   DBG,R_DBG,              *                               *01200000
               OVR=((DBGSAVE,DBGSA))   *                                01210000
*                                                                       01220000
         DBG   ABND,NOWARN             *                                01230000
         DS    0F                      *                                01240000
FLD1     DCOVR AL4(266)                *                                01250000
FLD1     DC    FL2'66'                 *                                01260000
         DCOVR *END                    *                                01270000
TESTRDTA RDATA CMDTXT,'TEST'           *                                01280000
*                                                                       01290000
         BALE  R14,ALLMACSX            *                                01300000
         BALH  R14,ALLMACSX            *                                01310000
         BALL  R14,ALLMACSX            *                                01320000
         BALM  R14,ALLMACSX            *                                01330000
         BALO  R14,ALLMACSX            *                                01340000
         BALP  R14,ALLMACSX            *                                01350000
         BALZ  R14,ALLMACSX            *                                01360000
         BALNE R14,ALLMACSX            *                                01370000
         BALNH R14,ALLMACSX            *                                01380000
         BALNL R14,ALLMACSX            *                                01390000
         BALNM R14,ALLMACSX            *                                01400000
         BALNO R14,ALLMACSX            *                                01410000
         BALNP R14,ALLMACSX            *                                01420000
         BALNZ R14,ALLMACSX            *                                01430000
*                                                                       01440000
         BASE  R14,ALLMACSX            *                                01450000
         BASH  R14,ALLMACSX            *                                01460000
         BASL  R14,ALLMACSX            *                                01470000
         BASM  R14,ALLMACSX            *                                01480000
         BASO  R14,ALLMACSX            *                                01490000
         BASP  R14,ALLMACSX            *                                01500000
         BASZ  R14,ALLMACSX            *                                01510000
         BASNE R14,ALLMACSX            *                                01520000
         BASNH R14,ALLMACSX            *                                01530000
         BASNL R14,ALLMACSX            *                                01540000
         BASNM R14,ALLMACSX            *                                01550000
         BASNO R14,ALLMACSX            *                                01560000
         BASNP R14,ALLMACSX            *                                01570000
         BASNZ R14,ALLMACSX            *                                01580000
*                                                                       01590000
         BHER  R14                     *                                01590100
         BLER  R14                     *                                01590200
         BLHR  R14                     *                                01590300
         BNHER R14                     *                                01590400
         BNLER R14                     *                                01590500
         BNLHR R14                     *                                01590600
*                                                                       01591000
         CASE  DBG_PROB                *                                01600000
          RWTO 'DBG:PROB'              *                                01610000
         ENDCASE ,                     *                                01620000
*                                                                       01630000
         DO    UNTIL,R0,Z              *                                01640000
          BXAEPSW R0                   *                                01650000
          LEAVE NZ                     *                                01660000
          LOOP ,                       *                                01670000
         ENDDO ,                       *                                01680000
*                                                                       01690000
         EXCLC 0(R1,R2),0(R4)          *                                01700000
         EXMVC 0(R1,R2),0(R4)          *                                01710000
         EXSVC (R14)                   *                                01720000
         EXTR  0(R1,R2),0(R4)          *                                01730000
         EXTRT 0(R1,R2),0(R4)          *                                01740000
         EXXC  0(R1,R2),0(R4)          *                                01750000
         MVPL  DBGENQ,DBG_ENQ          *                                01760000
*                                                                       01770000
         IF$ALC R5                     *                                01780000
         IF$LS R4,FLD1,4,A             *                                01790000
         IF$LU R4,FLD1,4,A             *                                01800000
*                                                                       01810000
         INC   R5                      *                                01820000
         LC    R5,0(R4)                *                                01830000
         LTA24 R5,0(R4)                *                                01840000
         LTC   R5,0(R4)                *                                01850000
         LTH   R5,0(R4)                *                                01860000
         LTHU  R5,0(R4)                *                                01870000
         STA24 R5,0(R4)                *                                01880000
*                                                                       01890000
         SET   DBGINIT                 *                                01900000
         SETOF DBG_PROB                *                                01910000
         SETON DBG_PROB                *                                01920000
         SETMODE PSWKEY,KEY=8          *                                01930000
*                                                                       01940000
         SNAPNTRY (R4),                *                               *01950000
               LEN=(R6),               *                               *01960000
               HDR='>> CB - Some Control Block'                         01970000
*                                                                       01980000
         GOTO  ALLMACSX                *                                01990000
TRTAB1   TRTAB UC                      *                                02000000
         USEDREGS ,                    *                                02010000
*                                                                       02020000
DBG_ENQ  ENQ   (0,0,E,0,SYSTEM),       * Prototype for ENQ             *02030000
               RET=NONE,MF=L           *   plist                        02040000
*                                                                       02050000
ALLMACSX LABEL ,                       *                                02060000
         GBLB  &SP_OPT                 * Optimize switch                02070000
         AIF   (&SP_OPT).NOOPSYNS      *                                02080000
         OPSYNS LA,LR                  *                                02090000
.NOOPSYNS ANOP ,                       *                                02100000
         IPK   ,                       * Macro IPK                      02110000
         LA    R7,4                    * Macro LA                       02120000
         LR    R15,R7                  * Macro LR                       02130000
         TRT   0(8,R4),0(R8)           * Macro TRT                      02140000
*                                                                       02150000
         ENDSR ,                       *                                02160000
.LTORG   ANOP  ,                       *                                02170000
*********************************************************************** 02180000
*                                                                       02190000
* Constants etc.                                                        02200000
*                                                                       02210000
*********************************************************************** 02220000
         LTORG ,                       *                                02230000
*                                                                       02240000
         END                                                            02250000
