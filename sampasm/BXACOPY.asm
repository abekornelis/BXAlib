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
* (C) Copyright B.V. Bixoft, 1999-2001                                  00160000
*********************************************************************** 00170000
*                                                                       00180000
* This program will copy a member from a PDS concatenation              00190000
*                     or a physical sequential dataset concatenation    00200000
*                                                                       00210000
*********************************************************************** 00220000
*                                                                       00230000
* Input:  parameter specifying 'MEMBER=memname'                         00240000
*                           or 'DATSET=PS'                              00250000
*         INPUT  dd-statement giving the input dataset(s)               00260000
* OUTPUT: OUTPUT dd-statement specifying the dataset to create          00270000
*                                                                       00280000
* For MEMBER=memname the INPUT concatenation of PDS'es will             00290000
*     be searched for the specified member, which will then             00300000
*     be copied to OUTPUT.                                              00310000
* For DATSET=PS the INPUT concatenation of physical sequential files    00320000
*     will be copied to OUTPUT.                                         00330000
*                                                                       00340000
* IEBCOPY does more, but needs control cards for its input,             00350000
*         which cannot be substituted from JCL variables.               00360000
* IEHLIST will also copy datasets, but it also lists all                00370000
*         records, filling up the spool.                                00380000
*                                                                       00390000
*********************************************************************** 00400000
         PGM   VERSION=V00R00M00,      * Version number                *00410000
               HDRTXT='Bixxams copy utility',                          *00420000
               WORKAREA=COPY,          * Dynamic area                  *00430000
               SAVES=4,                * Internal save-areas           *00440000
               ABND=4090,              * Abend code                    *00450000
               MAPS=($COPY,            * Private mapping macros        *00460000
               DCB,DCBE,DECB,IOB,SDWA)                                  00470000
*                                                                       00480000
* Assign some global registers                                          00490000
R_RCD    EQUREG ,                      * Assign retcode register        00500000
         USE   R_RCD,SCOPE=CALLED      * Set register in use            00510000
R_TMP    EQU   R_RCD                   * retcode reg also temp reg      00520000
R_LEN    EQUREG ,                      * Assign length register         00530000
         USE   R_LEN,SCOPE=CALLED      * Set length reg in use          00540000
R_RSN    EQU   R_LEN                   * length reg also reson reg      00550000
*                                                                       00560000
* Assign registers for input parm parsing                               00570000
R_PTR1   EQUREG ,                      * Ptr to first operand           00580000
         USE   R_PTR1                  * Set register in use            00590000
R_PTR2   EQUREG ,                      * Ptr to second operand          00600000
         USE   R_PTR2                  * Set register in use            00610000
R_LEN1   EQUREG ,                      * Length of first operand        00620000
         USE   R_LEN1                  * Set register in use            00630000
R_LEN2   EQUREG ,                      * Length of second operand       00640000
         USE   R_LEN2                  * Set register in use            00650000
*                                                                       00660000
* Retrieve JCL parameter - if specified - and save in R_PTR1            00670000
         IF    R1,Z                    * Pointer to parmlist valid?     00680000
          ABND ,                       * No: issue error                00690000
         ENDIF ,                       *                                00700000
         L     R_PTR1,0(,R1)           * Retrieve ptr to JCL parm       00710000
         CLEAR (R_PTR1,*ADDR)          * Wipe hi-order bit              00720000
         IF    R_PTR1,Z                * If it is invalid               00730000
          ABND ,                       * issue error                    00740000
         ENDIF ,                       *                                00750000
         LH    R_LEN1,0(R_PTR1)        * First halfword is length       00760000
         INC   R_PTR1,2                * Point start of text of parm    00770000
         IF    R_LEN1,GT,256           * If it is too long              00780000
          ABND ,                       * Issue error                    00790000
         ENDIF ,                       *                                00800000
         IF    R_LEN1,Z                * If no parm was specified       00810000
          ABND ,                       * Issue error                    00820000
         ENDIF ,                       *                                00830000
*                                                                       00840000
* Find equal sign in input string                                       00850000
         L     R_TMP,=A(TRTAB1)        * Point table to be used         00860000
         EXTRT 0(R_LEN1,R_PTR1),0(R_TMP) * Search first equal sign      00870000
         ABND  Z                       * Abend if not found             00880000
*                                                                       00890000
* Determine length of operand 1 and remainder of string                 00900000
         LA    R_PTR2,1(,R1)           * Point after equal sign         00910000
         CPY   R_LEN2,R_LEN1           * Copy string length             00920000
         CPY   R_TMP,R1                * Delimiter location             00930000
         SR    R_TMP,R_PTR1            * Nr of chars in first operand   00940000
         ABND  Z                       * Empty operand is error         00950000
         CPY   R_LEN1,R_TMP            * Set length of operand 1        00960000
         SR    R_LEN2,R_LEN1           * Remaining string length        00970000
         DEC   R_LEN2                  *    after delimiter             00980000
         IF    R_LEN2,LE,0             * Something left?                00990000
          ABND ,                       * No: error                      01000000
         ENDIF ,                       *                                01010000
*                                                                       01020000
* Operand 1 must be a valid keyword                                     01030000
         CASE  R_LEN1,EQ,6             * Length must be 6               01040000
          CASE E,CLC,=CL6'MEMBER',0(R_PTR1),NEST=YES * MEMBER copy?     01050000
           SETON COPYMEM               * Yes: indicate member copy      01060000
          CASE E,CLC,=CL6'DATSET',0(R_PTR1) * Dataset copy?             01070000
           SETON COPYDS                * Yes: indicate dataset copy     01080000
          ELSE ,                       *                                01090000
           ABND ,                      * Invalid keyword                01100000
          ENDCASE ,                    *                                01110000
         ELSE  ,                       * Other keyword lengths          01120000
          ABND ,                       * Invalid keyword length         01130000
         ENDCASE ,                     *                                01140000
*                                                                       01150000
* Test operand 2 for validity                                           01160000
         CASE  COPYMEM                 * Copy member requested?         01170000
          IF   R_LEN2,GT,8             * Length max is 8                01180000
           ABND ,                      * Member name too long           01190000
          ENDIF ,                      *                                01200000
          CLEAR COPYMBNM               * Wipe member name               01210000
          EXMVC COPYMBNM(R_LEN2),0(R_PTR2) * Copy member name           01220000
         CASE  COPYDS                  * Copy dataset requested?        01230000
          IF   R_LEN2,NE,2             * Length must be 2               01240000
           ABND ,                      * Wrong organisation             01250000
          ENDIF ,                      *                                01260000
          IF   E,CLC,=CL2'PS',0(R_PTR2) * Physical Sequential?          01270000
           SETON COPYPS                * Indicate PS copy request       01280000
          ENDIF ,                      *                                01290000
         ENDCASE ,                     *                                01300000
*                                                                       01310000
* Input string processing complete: drop used registers                 01320000
         DROP  R_PTR1                  *                                01330000
         DROP  R_PTR2                  *                                01340000
         DROP  R_LEN1                  *                                01350000
         DROP  R_LEN2                  *                                01360000
*                                                                       01370000
* Set up recovery environment                                           01380000
         MVPL  COPYESTAE,CPY_ESTAE     * Copy ESTAE parmlist            01390000
         ESTAE RECOVER,CT,             * Create new ESTAE-environment  *01400000
               PARAM=(R13),            * Pass COPY as parameter field  *01410000
               MF=(E,COPYESTAE)        *                                01420000
         ABND  TSTRC,RCD=(R_RCD,R_RSN) * Abend on error                 01430000
                                                                        01440000
*                                                                       01450000
* Perform requested function                                            01460000
         CASE  COPYMEM                 * Member copy?                   01470000
          EXSR CPYMEM                  * Ok: copy a member              01480000
         CASE  COPYPS                  * PS copy?                       01490000
          EXSR CPYPS                   * Ok: copy a PS dataset          01500000
         ENDCASE ,                                                      01510000
*                                                                       01520000
* Remove ESTAE environment                                              01530000
         MVPL  COPYESTAE,CPY_ESTAE     * Copy ESTAE parmlist            01540000
         ESTAE 0,                      * Remove our ESTAE-environment  *01550000
               MF=(E,COPYESTAE)        *                                01560000
         ABND  TSTRC,RCD=(R_RCD,R_RSN) * Abend on error                 01570000
*                                                                       01580000
* And exit program                                                      01590000
         RETRN RC=0                    * Quit this program              01600000
*********************************************************************** 01610000
*                                                                       01620000
* Routine to copy a PDS member                                          01630000
*                                                                       01640000
*********************************************************************** 01650000
CPYMEM   BEGSR ,                                                        01660000
*                                                                       01670000
* Allocate input DCB and DCBE in the workarea                           01680000
         MVPL  COPYDCBP,CPY_DCBP       * Copy input DCB                 01690000
         MVPL  COPYDCBE,CPY_DCBE       * Copy DCBE to be used           01700000
IN       USE   DCB,COPYDCBP            * Set DCB fields addressable     01710000
         USE   DCBE,COPYDCBE           * Set DCBE fields addressable    01720000
         SET   IN.DCBDCBE,COPYDCBE     * Point from DCB to DCBE         01730000
         SET   DCBEEODA,EODADRTN       * Point to EODAD routine         01740000
*                                                                       01750000
* Open the input PDS (concatenation)                                    01760000
         MVPL  COPYOPEN,CPY_OPEN       * Copy open parmlist             01770000
         OPEN  (COPYDCBP,INPUT),       * Open the input dataset(s)     *01780000
               MF=(E,COPYOPEN)         *                                01790000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               01800000
*                                                                       01810000
* Allocate and open the output DCB in the workarea                      01820000
         MVPL  COPYDCBO,CPY_DCBO       * Copy output DCB                01830000
OUT      USE   DCB,COPYDCBO            * Set DCB fields addressable     01840000
CPYMEM_OPEN LABEL ,                    *                                01850000
         MVPL  COPYOPEN,CPY_OPEN       * Copy open parmlist             01860000
         OPEN  (COPYDCBO,OUTPUT),      * Open the output dataset       *01870000
               MF=(E,COPYOPEN)         *                                01880000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               01890000
*                                                                       01900000
* Locate the required input member                                      01910000
         FIND  COPYDCBP,COPYMBNM,D     * Locate required member         01920000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               01930000
*                                                                       01940000
* Allocate 1 buffer for the BPAM input dataset                          01950000
R_BUFP   EQUREG ,                      * Assign buffer ptr              01960000
         USE   R_BUFP                  * Set ptr in use                 01970000
         CPY   R_LEN,IN.DCBBLKSI       * Obtain input block size        01980000
         STORAGE OBTAIN,LOC=ANY,       * Get storage above the line    *01990000
               LENGTH=(R_LEN)          *   for a single block           02000000
         CPY   R_BUFP,R1               * Set ptr to buffer              02010000
         CPY   COPYBUFI,R_BUFP         * And save buffer address        02020000
*                                                                       02030000
* Allocate 1 buffer for an output record                                02040000
R_BUFO   EQUREG ,                      * Assign buffer ptr              02050000
         USE   R_BUFO                  * Set ptr in use                 02060000
         CPY   R_LEN,OUT.DCBLRECL      * Obtain (max) output lrecl      02070000
         STORAGE OBTAIN,LOC=ANY,       * Get storage above the line    *02080000
               LENGTH=(R_LEN)          *   for a single block           02090000
         CPY   R_BUFO,R1               * Set ptr to buffer              02100000
         CPY   COPYBUFO,R_BUFO         * And save buffer address        02110000
*                                                                       02120000
* Loop to read all blocks in the member                                 02130000
         DO    UNTIL,COPYEOF           * Until EOF detected             02140000
          MVPL COPYDECB,CPY_DECB       * Set up initial DECB            02150000
          USE  DECB,COPYDECB           * Set DECB fields addressable    02160000
          CPY  R_TMP,R_BUFP            * Set ptr to BPAM buffer         02170000
          READ COPYDECB,SF,            * Read forward                  *02180000
               COPYDCBP,(R_TMP),'S',   *  1 block from input dataset   *02190000
               MF=E                    *                                02200000
          CHECK COPYDECB               * Wait for READ to complete      02210000
          IF   NOT,COPYEOF             * Valid block was read?          02220000
* For Fixed records: use IOB to determine end-of-buffer                 02230000
* For Variable records: use BDW to determine end-of-buffer              02240000
           IF  IN.DCBRECF              * Fixed or FB input records?     02250000
            CPY R_LEN,IN.DCBBLKSI      * Load input block length        02260000
R_IOB       EQUREG ,                   * Assign IOB ptr                 02270000
            USE IOBSTDRD,R_IOB         * Set IOB addressable            02280000
            CPY R_IOB,DECIOBPT         * And point to IOB               02290000
            CPY R_TMP,IOBRESCT         * Load residual count            02300000
            DROP R_IOB                 * IOB no longer needed           02310000
            SR R_LEN,R_TMP             * Nr of bytes in input buffer    02320000
            AR R_LEN,R_BUFP            * Point past end of data         02330000
            ST R_LEN,COPYBUFE          * Save end-of-block ptr          02340000
            ST R_BUFP,COPYREC          * Set ptr to current record      02350000
           ELSE  ,                     * Must be variable or VB records 02360000
R_BDW       EQUREG ,                   * Assign buffer ptr              02370000
            USE BDW,R_BDW              * Address block descriptor word  02380000
            CPY R_BDW,R_BUFP           * Point to filled buffer         02390000
            CPY R_LEN,BDWBLKLN         * Retrieve length of block       02400000
            AR  R_LEN,R_BUFP           * Point past end of data         02410000
            ST  R_LEN,COPYBUFE         * Set ptr to end of buffer       02420000
            LA  R_TMP,BDW_LEN(,R_BUFP) * Point to first RDW in buffer   02430000
            CPY COPYREC,R_TMP          * Set ptr to current record      02440000
            DROP R_BDW                 * Buffer ptr no longer needed    02450000
           ENDIF ,                     *                                02460000
           EXSR CPYBLK                 * Go copy a block to output      02470000
          ENDIF ,                      *                                02480000
         ENDDO ,                       *                                02490000
*                                                                       02500000
* Free the output record buffer                                         02510000
         CPY   R_LEN,OUT.DCBLRECL      * Obtain output record length    02520000
         STORAGE RELEASE,ADDR=(R_BUFO), * Free storage allocated       *02530000
               LENGTH=(R_LEN)          *   for a single record          02540000
         DROP  R_BUFO                  * Buffer ptr no longer valid     02550000
         CLEAR COPYBUFO                * And wipe ptr in storage too    02560000
*                                                                       02570000
* Free the input buffer                                                 02580000
         CPY   R_LEN,IN.DCBBLKSI       * Obtain input block size        02590000
         STORAGE RELEASE,ADDR=(R_BUFP), * Free storage allocated       *02600000
               LENGTH=(R_LEN)          *   for a single block           02610000
         DROP  R_BUFP                  * Buffer ptr no longer valid     02620000
         CLEAR COPYBUFI                * And wipe ptr in storage too    02630000
*                                                                       02640000
* Close the input PDS (concatenation)                                   02650000
         MVPL  COPYCLOS,CPY_CLOS       * Copy close parmlist            02660000
         CLOSE (COPYDCBP),MF=(E,COPYCLOS) * Close the input dataset(s)  02670000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               02680000
*                                                                       02690000
* Close the output dataset                                              02700000
         MVPL  COPYCLOS,CPY_CLOS       * Copy close parmlist            02710000
         CLOSE (COPYDCBO),MF=(E,COPYCLOS) * Close the input dataset(s)  02720000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               02730000
*                                                                       02740000
* Release registers                                                     02750000
         DROP  R_RCD                   *                                02760000
         DROP  R_LEN                   *                                02770000
*                                                                       02780000
         ENDSR ,                                                        02790000
*********************************************************************** 02800000
*                                                                       02810000
* Routine to copy a sequential dataset (or concatenation)               02820000
*                                                                       02830000
*********************************************************************** 02840000
CPYPS    BEGSR ,                                                        02850000
*                                                                       02860000
* Allocate input DCB and DCBE in the workarea                           02870000
         MVPL  COPYDCBS,CPY_DCBS       * Copy input DCB                 02880000
         MVPL  COPYDCBE,CPY_DCBE       * Copy DCBE to be used           02890000
IN       USE   DCB,COPYDCBS            * Set DCB fields addressable     02900000
         USE   DCBE,COPYDCBE           * Set DCBE fields addressable    02910000
         SET   IN.DCBDCBE,COPYDCBE     * Point from DCB to DCBE         02920000
         SET   DCBEEODA,EODADRTN       * Point to EODAD routine         02930000
*                                                                       02940000
* Open the input dataset or concatenation                               02950000
         MVPL  COPYOPEN,CPY_OPEN       * Copy open parmlist             02960000
         OPEN  (COPYDCBS,INPUT),       * Open the input dataset(s)     *02970000
               MF=(E,COPYOPEN)         *                                02980000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               02990000
*                                                                       03000000
* Allocate and open the output DCB in the workarea                      03010000
         MVPL  COPYDCBO,CPY_DCBO       * Copy output DCB                03020000
OUT      USE   DCB,COPYDCBO            * Set DCB fields addressable     03030000
CPYPS_OPEN LABEL ,                     *                                03040000
         MVPL  COPYOPEN,CPY_OPEN       * Copy open parmlist             03050000
         OPEN  (COPYDCBO,OUTPUT),      * Open the output dataset       *03060000
               MF=(E,COPYOPEN)         *                                03070000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               03080000
*                                                                       03090000
* Allocate 1 buffer for the input BSAM dataset                          03100000
R_BUFS   EQUREG ,                      * Assign buffer ptr              03110000
         USE   R_BUFS                  * Set ptr in use                 03120000
         CPY   R_LEN,IN.DCBBLKSI       * Obtain input block size        03130000
         STORAGE OBTAIN,LOC=ANY,       * Get storage above the line    *03140000
               LENGTH=(R_LEN)          *   for a single block           03150000
         CPY   R_BUFS,R1               * Set ptr to buffer              03160000
         CPY   COPYBUFI,R_BUFS         * And save buffer address        03170000
*                                                                       03180000
* Allocate 1 buffer for an output record                                03190000
* R_BUFO EQUREG ,                      * Assigned in CPYMEM routine!    03200000
         USE   R_BUFO                  * Set ptr in use                 03210000
         CPY   R_LEN,OUT.DCBLRECL      * Obtain (max) output lrecl      03220000
         STORAGE OBTAIN,LOC=ANY,       * Get storage above the line    *03230000
               LENGTH=(R_LEN)          *   for a single block           03240000
         CPY   R_BUFO,R1               * Set ptr to buffer              03250000
         CPY   COPYBUFO,R_BUFO         * And save buffer address        03260000
*                                                                       03270000
* Loop to read all blocks in the dataset                                03280000
         DO    UNTIL,COPYEOF           * Until EOF detected             03290000
          MVPL COPYDECB,CPY_DECB       * Set up initial DECB            03300000
          USE  DECB,COPYDECB           * Set DECB fields addressable    03310000
          CPY  R_TMP,R_BUFS            * Set ptr to BSAM buffer         03320000
          READ COPYDECB,SF,            * Read forward                  *03330000
               COPYDCBS,(R_TMP),'S',   *  1 block from input dataset   *03340000
               MF=E                    *                                03350000
          CHECK COPYDECB               * Wait for READ to complete      03360000
          IF   NOT,COPYEOF             * Valid block was read?          03370000
* For Fixed records: use IOB to determine end-of-buffer                 03380000
* For Variable records: use BDW to determine end-of-buffer              03390000
           IF  IN.DCBRECF              * Fixed or FB input records?     03400000
            CPY R_LEN,IN.DCBBLKSI      * Load input block length        03410000
            USE IOBSTDRD,R_IOB         * Set IOB addressable            03420000
            CPY R_IOB,DECIOBPT         * And point to IOB               03430000
            CPY R_TMP,IOBRESCT         * Load residual count            03440000
            DROP R_IOB                 * IOB no longer needed           03450000
            SR R_LEN,R_TMP             * Nr of bytes in input buffer    03460000
            AR R_LEN,R_BUFS            * Point past end of data         03470000
            ST R_LEN,COPYBUFE          * Save end-of-block ptr          03480000
            ST R_BUFS,COPYREC          * Set ptr to current record      03490000
           ELSE  ,                     * Must be variable or VB records 03500000
            USE BDW,R_BDW              * Address block descriptor word  03510000
            CPY R_BDW,R_BUFS           * Point to filled buffer         03520000
            CPY R_LEN,BDWBLKLN         * Retrieve length of block       03530000
            AR  R_LEN,R_BUFS           * Point past end of data         03540000
            ST  R_LEN,COPYBUFE         * Set ptr to end of buffer       03550000
            LA  R_TMP,BDW_LEN(,R_BUFS) * Point to first RDW in buffer   03560000
            CPY COPYREC,R_TMP          * Set ptr to current record      03570000
            DROP R_BDW                 * Buffer ptr no longer needed    03580000
           ENDIF ,                     *                                03590000
           EXSR CPYBLK                 * Go copy a block to output      03600000
          ENDIF ,                      *                                03610000
         ENDDO ,                       *                                03620000
*                                                                       03630000
* Free the output record buffer                                         03640000
         CPY   R_LEN,OUT.DCBLRECL      * Obtain output record length    03650000
         STORAGE RELEASE,ADDR=(R_BUFO), * Free storage allocated       *03660000
               LENGTH=(R_LEN)          *   for a single record          03670000
         DROP  R_BUFO                  * Buffer ptr no longer valid     03680000
         CLEAR COPYBUFO                * And wipe ptr in storage too    03690000
*                                                                       03700000
* Free the BSAM input buffer                                            03710000
         CPY   R_LEN,IN.DCBBLKSI       * Obtain input block size        03720000
         STORAGE RELEASE,ADDR=(R_BUFS), * Free storage allocated       *03730000
               LENGTH=(R_LEN)          *   for a single block           03740000
         DROP  R_BUFS                  * Buffer ptr no longer valid     03750000
         CLEAR COPYBUFI                * And wipe ptr in storage too    03760000
*                                                                       03770000
* Close the input dataset (or concatenation)                            03780000
         MVPL  COPYCLOS,CPY_CLOS       * Copy close parmlist            03790000
         CLOSE (COPYDCBS),MF=(E,COPYCLOS) * Close the input dataset(s)  03800000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               03810000
*                                                                       03820000
* Close the output dataset                                              03830000
         MVPL  COPYCLOS,CPY_CLOS       * Copy close parmlist            03840000
         CLOSE (COPYDCBO),MF=(E,COPYCLOS) * Close the input dataset(s)  03850000
         ABND  TSTRC,RCD=R_RCD         * Abend on failure               03860000
*                                                                       03870000
* Release registers                                                     03880000
         DROP  R_RCD                   *                                03890000
         DROP  R_LEN                   *                                03900000
*                                                                       03910000
         ENDSR ,                                                        03920000
*********************************************************************** 03930000
*                                                                       03940000
* Routine to write an entire block                                      03950000
*                                                                       03960000
* At entry: COPYREC  points to first record in buffer                   03970000
*           COPYBUFE points to end-of-buffer                            03980000
*           COPYBUFO points to output record buffer                     03990000
*                                                                       04000000
*********************************************************************** 04010000
CPYBLK   BEGSR ,                                                        04020000
*                                                                       04030000
* Set up to loop thru the block                                         04040000
         CPY   R_BUFO,COPYBUFO         * Point to output record area    04050000
         USE   R_BUFO                  * and set register in use        04060000
*                                                                       04070000
R_REC    EQUREG ,                      * Assign record ptr              04080000
RDWIN    USE   RDW,R_REC               * Assume RECFM=V or VB           04090000
*                                                                       04100000
* No distinction is made between COPYDCBP (BPAM) and COPYDCBS (BSAM)    04110000
IN       USE   DCB,COPYDCBP            * Set DCB fields addressable     04120000
OUT      USE   DCB,COPYDCBO            * Set DCB fields addressable     04130000
*                                                                       04140000
* For each record in the buffer:                                        04150000
* - determine length, advance current record pointer                    04160000
* - copy record, truncate if too long, pad if too short                 04170000
* - write record to output dataset                                      04180000
*                                                                       04190000
         DO    WHILE,COPYREC,LT,COPYBUFE * For each record in buffer    04200000
*         Determine length, advance current record pointer              04210000
          CPY  R_REC,COPYREC           * Copy ptr to current record     04220000
          IF   IN.DCBRECF              * Fixed record length:           04230000
           CPY R_LEN,IN.DCBLRECL       * Retrieve rec length from DCB   04240000
           CPY R_TMP,R_REC             * Copy current record ptr        04250000
           INC R_TMP,(R_LEN)           * Point to next record           04260000
           CPY COPYREC,R_TMP           * Update current record ptr      04270000
          ELSE ,                       * Variable records:              04280000
           CPY R_LEN,RDWIN.RDWRECLN    * Retrieve length of record      04290000
           CPY R_TMP,R_REC             * Copy current record pointer    04300000
           INC R_TMP,(R_LEN)           * Point next record in buffer    04310000
           CPY COPYREC,R_TMP           * Update current record pointer  04320000
           INC R_REC,RDW_LEN           * Point to start of record data  04330000
           DEC R_LEN,RDW_LEN           * And adjust data length         04340000
          ENDIF ,                      *                                04350000
*         R_REC now points data, R_LEN holds data length                04360000
*         Copy record, truncate if too long, pad if too short           04370000
          IF   OUT.DCBRECF             * Fixed record length:           04380000
           IF  R_LEN,GT,OUT.DCBLRECL   * Record is too long?            04390000
            CPY R_LEN,OUT.DCBLRECL     * Yes: truncate                  04400000
           ENDIF ,                     *                                04410000
           IF  R_LEN,LE,256            * Length is legal?               04420000
            EXMVC 0(R_LEN,R_BUFO),0(R_REC) * Copy the data              04430000
           ELSE ,                      * Length too large               04440000
            ABND ,                     *                                04450000
           ENDIF ,                     *                                04460000
           IF  R_LEN,LT,OUT.DCBLRECL   * Wipe remainder of buffer?      04470000
            LA R_TMP,0(R_BUFO,R_LEN)   * Yes: point to remainder start  04480000
            SH R_LEN,OUT.DCBLRECL      *      and set remainder size    04490000
            IF R_LEN,LE,256            * Length is legal?               04500000
             EXXC 0(R_LEN,R_TMP),0(R_TMP) * Wipe remainder              04510000
            ELSE ,                     * Length too large               04520000
             ABND ,                    *                                04530000
            ENDIF ,                    *                                04540000
           ENDIF ,                     * End of wipe for short records  04550000
          ELSE  ,                      * Must be V or VB records        04560000
           DROP R_BUFO                 * Drop to swap using status      04570000
RDWOUT     USE RDW,R_BUFO              * Record starts with a RDW       04580000
           INC R_LEN,RDW_LEN           * Add size of RDW to lrecl       04590000
           IF  R_LEN,GT,OUT.DCBLRECL   * Record is too long?            04600000
            CPY R_LEN,OUT.DCBLRECL     * Yes: truncate                  04610000
           ENDIF ,                     *                                04620000
           CPY RDWOUT.RDWRECLN,R_LEN   * Set length in RDW              04630000
           CLEAR RDWOUT.RDWT00         * Wipe trailing zeroes           04640000
           DEC R_LEN,RDW_LEN           * Reduce to data length          04650000
           IF  R_LEN,LE,256            * Length is legal?               04660000
            EXMVC RDW_LEN(R_LEN,R_BUFO),0(R_REC) * Copy the data        04670000
           ELSE ,                      * Length too large               04680000
            ABND ,                     *                                04690000
           ENDIF ,                     *                                04700000
          ENDIF ,                      * Output buffer now ready        04710000
*         Output buffer now complete: write record to output            04720000
          PUT  COPYDCBO,(R_BUFO)       * Write record to output dataset 04730000
         ENDDO ,                       *                                04740000
*                                                                       04750000
         ENDSR ,                       *                                04760000
*********************************************************************** 04770000
*                                                                       04780000
* Retry routine after System 013 abend                                  04790000
*                                                                       04800000
*********************************************************************** 04810000
RETRY013 BEGSR TYPE=RETRY              *                                04820000
*                                                                       04830000
IN       USE   DCB,COPYDCBS            * Set DCB fields addressable     04840000
OUT      USE   DCB,COPYDCBO            * Set DCB fields addressable     04850000
*                                                                       04860000
* Setup fresh output DCB                                                04870000
         MVPL  COPYDCBO,CPY_DCBO       * Copy output DCB                04880000
*                                                                       04890000
* Copy LRECL, BLKSIZE, and record format from input DCB                 04900000
         CPY   OUT.DCBBLKSI,IN.DCBBLKSI * Copy block size               04910000
         CPY   OUT.DCBLRECL,IN.DCBLRECL * Copy record length            04920000
         CPY   OUT.DCBRECFM,IN.DCBRECFM * Copy record format            04930000
*                                                                       04940000
* Retry the open                                                        04950000
         GOTO  CPYMEM_OPEN,COPYMEM     * Retry for member copy          04960000
         GOTO  CPYPS_OPEN,COPYPS       * Retry for PS dataset copy      04970000
         ABND  ,                       * Error!                         04980000
*                                                                       04990000
         DROP  IN                      * DCB fields no longer           05000000
         DROP  OUT                     *     needed                     05010000
*                                                                       05020000
         ENDSR ,                       *                                05030000
*********************************************************************** 05040000
*                                                                       05050000
* Constants etc.                                                        05060000
*                                                                       05070000
*********************************************************************** 05080000
         LTORG ,                       *                                05090000
*********************************************************************** 05100000
*                                                                       05110000
* Out-of-line routinse                                                  05120000
*                                                                       05130000
*********************************************************************** 05140000
EODADRTN LABEL H                       * Ensure alignment               05150000
         SETON COPYEOF                 * Indicate EOF reached           05160000
         BR    R14                     * Return                         05170000
*********************************************************************** 05180000
*                                                                       05190000
* Recovery routine                                                      05200000
*                                                                       05210000
*********************************************************************** 05220000
RECOVER  BEGSR TYPE=ESTAE,             * Estae recovery routine        *05230000
               LVL=1                   * For normal code                05240000
*                                                                       05250000
* Do we have an SDWA?                                                   05260000
         GOTO  RECPERC,R0,EQ,12        * No SDWA: percolate             05270000
*                                                                       05280000
* SDWA found                                                            05290000
R_SDWA   EQUREG ,                      *                                05300000
         LR    R_SDWA,R1               * Copy SDWA pointer              05310000
         USE   SDWA,R_SDWA             * And set SDWA addressable       05320000
*                                                                       05330000
* If registers at time of error unavailable: do not retry               05340000
         GOTO  SETRP0,SDWARPIV         * Regs not available: percolate  05350000
*                                                                       05360000
* This is a recoverable abend?                                          05370000
         CASE  SDWACMPC,EQ,=X'013000'  * System 013 is recoverable      05380000
          GOTO SYS013                  * Retry if original SVC abended  05390000
         ELSE  ,                       * All other abends               05400000
          GOTO SETRP0                  * Percolate                      05410000
         ENDCASE ,                     *                                05420000
         GOTO  SETRP0                  * Always percolate               05430000
*                                                                       05440000
* We encountered a S013 abend, meaning that open could not complete     05450000
* successfully. If reasoncode is 34 some DCB parameters are missing     05460000
* and must be copied from the input DCB before retrying the open.       05470000
SYS013   LABEL ,                       *                                05480000
R_PTRS   EQUREG ,                      * Assign ptr to pointers block   05490000
         USE   SDWAPTRS,R_PTRS         * And set it addressable         05500000
         L     R_PTRS,SDWAXPAD         * Point to pointers block        05510000
R_RC1    EQUREG ,                      * Assign ptr service extension 1 05520000
         USE   SDWARC1,R_RC1           * And set it addressable         05530000
         L     R_RC1,SDWASRVP          * Point to service extension 1   05540000
         GOTO  SETRP0,NOT,SDWARCF      * Reasoncode must be available   05550000
         GOTO  SETRP0,SDWAHRC,NE,52    * Reasoncode must be 34 hex      05560000
*                                                                       05570000
* Open failed due to incomplete DCB                                     05580000
IN       USE   DCB,COPYDCBS            * Set DCB fields addressable     05590000
OUT      USE   DCB,COPYDCBO            * Set DCB fields addressable     05600000
*                                                                       05610000
* Make sure input DCB is open and output DCB is not                     05620000
         GOTO  SETRP0,NOT,IN.DCBOFOPN  * No retry: input not open       05630000
         GOTO  SETRP0,OUT.DCBOFOPN     * No retry: output is open       05640000
*                                                                       05650000
* Make sure we don't retry more than once                               05660000
         GOTO  SETRP0,COPYRTRY         * No retry: retried before       05670000
         SETON COPYRTRY                * Indicate retry performed       05680000
*                                                                       05690000
* Setup for retry                                                       05700000
         L     R0,=AL4(RETRY013)       * Retrieve address of retry-rout 05710000
         B     SETRP4                  * And go retry                   05720000
*                                                                       05730000
         DROP  R_RC1                   * SDWARC1 not needed anymore     05740000
         DROP  R_PTRS                  * SDWAPTRS no longer needed      05750000
         DROP  R_SDWA                  * SDWA no longer needed          05760000
*                                                                       05770000
* Percolate                                                             05780000
SETRP0   LABEL ,                       * SETRP RC=0: percolate          05790000
         SETRP RC=0,                   * Retcode 0 to percolate        *05800000
               WKAREA=(R_SDWA)         * Point to SDWA                  05810000
         B     RECEXIT                 *                                05820000
*                                                                       05830000
* Tell system to retry                                                  05840000
SETRP4   LABEL ,                       * SETRP RC=4: retry              05850000
         SETRP RC=4,                   * Retcode 0 to percolate        *05860000
               WKAREA=(R_SDWA),        * Points to SDWA                *05870000
               DUMP=NO,                * Suppress dump                 *05880000
               RETADDR=(R0),           * Retry address in R0           *05890000
               RETREGS=YES,            * Restore registers from SDWA   *05900000
               FRESDWA=YES,            * Free SDWA before retry        *05910000
               RECORD=NO               * Do not record in LOGREC        05920000
         B     RECEXIT                 *                                05930000
*                                                                       05940000
* Percolate: no SDWA                                                    05950000
RECPERC  LABEL ,                       *                                05960000
         CLEAR R15                     * RC=0 to percolate              05970000
*                                                                       05980000
RECEXIT  LABEL ,                       *                                05990000
         ENDSR RC=*,                   * When RC=4 (retry)             *06000000
               KEEPREG=R0              *   R0 contains retry address    06010000
*********************************************************************** 06020000
*                                                                       06030000
* Indirectly addressable Plists and constants                           06040000
*                                                                       06050000
*********************************************************************** 06060000
TRTAB1   TRTAB ,                       * Select no characters          *06070000
               CHARS=(C'=')            * Except equal sign              06080000
*                                                                       06090000
CPY_ESTAE ESTAE 0,                     * Establish ESTAE routine       *06100000
               MF=L                    *                                06110000
*                                                                       06120000
CPY_DCBP DCB   DDNAME=INPUT,           * Model input DCB for BPAM      *06130000
               DSORG=PO,               * Partitioned organization      *06140000
               DCBE=CPY_DCBE,          * For use in 31-bit environment *06150000
               MACRF=R                 * And read-only                  06160000
*                                                                       06170000
CPY_DCBS DCB   DDNAME=INPUT,           * Model input DCB for BSAM      *06180000
               DSORG=PS,               * Physical sequential           *06190000
               DCBE=CPY_DCBE,          * For use in 31-bit environment *06200000
               MACRF=R                 * And read-only                  06210000
*                                                                       06220000
CPY_DCBE DCBE  EODAD=EODADRTN          * DCB-extension prototype        06230000
*                                                                       06240000
         READ  CPY_DECB,SF,MF=L        * DECB prototype                 06250000
*                                                                       06260000
CPY_DCBO DCB   DDNAME=OUTPUT,          * Model output DCB              *06270000
               DSORG=PS,               * Sequential file               *06280000
               MACRF=PM                * Use Put-Move                   06290000
*                                                                       06300000
CPY_OPEN OPEN  (0,INPUT),MF=L          *                                06310000
CPY_CLOS CLOSE (0),MF=L                *                                06320000
*                                                                       06330000
         END                                                            06340000
