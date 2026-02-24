*PROCESS FLAG(SUBSTR)                                                   00000010
*PROCESS RENT                                                           00000020
*                                                                       00000100
* This program is free software; you can redistribute it and/or modify  00000200
* it under the terms of the GNU General Public License as published by  00000300
* the Free Software Foundation; either version 2 of the License         00000400
* or (at your option) any later version.                                00000500
* The license text is available at the following internet addresses:    00000600
* - http://www.bixoft.com/english/gpl.htm                               00000700
* - http://fsf.org                                                      00000800
* - http://opensource.org                                               00000900
*                                                                       00001000
* This program is distributed in the hope that it will be useful,       00001100
* but WITHOUT ANY WARRANTY; without even the implied warranty of        00001200
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  00001300
* See the GNU General Public License for more details.                  00001400
*                                                                       00001500
* You should have received a copy of the GNU General Public License     00001600
* along with this program; if not, write to either of the following:    00001700
* the Free Software Foundation, Inc.      B.V. Bixoft                   00001800
* 59 Temple Place, Suite 330              Rogge 9                       00001900
* Boston, MA 02111-1307                   7261 JA Ruurlo                00002000
* United States of America                The Netherlands               00002100
*                                                                       00002200
*                                         e-mail: bixoft@bixoft.nl      00002300
*                                         phone : +31-6-22755401        00002400
*                                                                       00002500
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
* This program converts a PDS or PDSE to a sequential dataset that      00190000
*      contains a job stream, capable of recreating the dataset.        00200000
*                                                                       00210000
*********************************************************************** 00220000
         PGM   VERSION=V00R00M00,      * Version number                *00230000
               HDRTXT='Bixxams PDS unload program',                    *00240000
               WORKAREA=UNLD,          * Dynamic area                  *00250000
               SAVES=3,                * Internal save-areas           *00260000
               ABND=0130,              * Abend code for BXAUNLD        *00270000
               MAPS=($UNLD,            * Private control blocks        *00280000
               CVT,DCB,DCBE,JESCT,JFCB,IOB,PDS,PSA,TCB,TIOT)            00290000
*                                                                       00300000
* Assign some global registers                                          00310000
R_RCD    EQUREG ,                      * Assign retcode register        00320000
         USE   R_RCD,SCOPE=CALLED      * Set register in use            00330000
R_TMP    EQU   R_RCD                   * Use for temp. also             00340000
R_LEN    EQUREG ,                      * Assign length register         00350000
         USE   R_LEN,SCOPE=CALLED      * Set register in use            00360000
*                                                                       00370000
* Retrieve JCL parameter - if specified - and save in UNLD              00380000
         IF    R1,NZ                   * Parm ptr was passed?           00390000
          L    R_TMP,0(,R1)            * Retrieve ptr to JCL parm       00400000
          CLEAR (R_TMP,*ADDR)          * Wipe hi-order bit              00410000
          IF   R_TMP,NZ                * If it is valid                 00420000
           LH  R_LEN,0(R_TMP)          * First halfword is length       00430000
           IF  R_LEN,GT,8              * If it is too long              00440000
            LA R_LEN,8                 * Truncate to 8 characters       00450000
           ELSE ,                      * It might be too short          00460000
            MVC UNLPARM,=CL8' '        * pre-fill with spaces           00470000
           ENDIF ,                     *                                00480000
           IF  R_LEN,NZ                * If length is valid             00490000
            EXMVC UNLPARM(R_LEN),2(R_TMP) * Copy parameter text         00500000
            SETON UNLSPRM              * Set valid parm indicator       00510000
           ENDIF ,                     *                                00520000
          ENDIF ,                      *                                00530000
         ENDIF ,                       *                                00540000
*                                                                       00550000
* Create in-storage table of directory entries                          00560000
         EXSR  CRTDIR                  * Create directory table         00570000
*                                                                       00580000
* Process the library: read & copy all members                          00590000
         EXSR  RDLIB                   * Read all members in the lib    00600000
*                                                                       00610000
* Release the directory table                                           00620000
         CPY   R_TMP,UNLDIRP           * Point table                    00630000
         CPY   R_LEN,UNLDIRSZ          * Retrieve length of table       00640000
         STORAGE RELEASE,              * Free the directory table      *00650000
               LENGTH=(R_LEN),         *                               *00660000
               ADDR=(R_TMP)            *                                00670000
         CLEAR UNLDIRP                 * Wipe ptr to buffer             00680000
         CLEAR UNLDIRFP                * Wipe ptr to free entry         00690000
         CLEAR UNLDIRSZ                * And buffer size                00700000
*                                                                       00710000
* Release remaining registers                                           00720000
         DROP  R_LEN                   *                                00730000
         DROP  R_RCD                   *                                00740000
*                                                                       00750000
* And exit                                                              00760000
         RETRN RC=0                    * Quit this program              00770000
*********************************************************************** 00780000
*                                                                       00790000
* Routine to create an in-storage table of directrory entries           00800000
*                                                                       00810000
*********************************************************************** 00820000
CRTDIR   BEGSR ,                       *                                00830000
*                                                                       00840000
* Create BPAM DCB and open it.                                          00850000
         MVPL  UNLDCB1,UNL_DCB1        * Copy DCB for PDS               00860000
         MVPL  UNLDCBE1,UNL_DCBE       * Copy DCBE for PDS              00870000
         USE   DCB,UNLDCB1             * Set DCB fields addressable     00880000
         USE   DCBE,UNLDCBE1           * Set DCBE fields addressable    00890000
         SET   DCBDCBE,UNLDCBE1        * Point from DCB to DCBE         00900000
         SET   DCBEEODA,LIST_EODAD     * Set ptr to end-of-member rtn   00910000
*                                                                       00920000
         MVPL  UNLOPEN,UNL_OPEN        * Copy OPEN parmlist             00930000
         OPEN  (UNLDCB1,INPUT),        * Open the input dataset        *00940000
               MF=(E,UNLOPEN)          *                                00950000
         ABND  TSTRC,RCD=R_RCD         *                                00960000
*                                                                       00970000
* Allocate buffer for reading dir blocks                                00980000
         LA    R_LEN,PDSDIRBS          * Room for 8 entries             00990000
         STORAGE OBTAIN,               * Allocate storage              *01000000
               LENGTH=(R_LEN),         * for 8 entries                 *01010000
               LOC=ANY                 *                                01020000
         CPY   UNLBUFP,R1              * Save ptr to buffer             01030000
         CPY   UNLBUFSZ,R_LEN          * Save length of buffer          01040000
*                                                                       01050000
* Allocate initial buffer for 8 directory entries                       01060000
         LA    R_LEN,8*PDS_LEN         * Room for 8 entries             01070000
         STORAGE OBTAIN,               * Allocate storage              *01080000
               LENGTH=(R_LEN),         * for 8 entries                 *01090000
               LOC=ANY                 *                                01100000
         CPY   UNLDIRP,R1              * Save ptr to table              01110000
         CPY   UNLDIRFP,R1             * Set ptr to 1st free element    01120000
         CPY   UNLDIRSZ,R_LEN          * Save length of table           01130000
*                                                                       01140000
* Prepare for reading the directory                                     01150000
         CPY   UNLBLKSI,DCBBLKSI       * Save blocksize                 01160000
         CPY   DCBBLKSI,PDSDIRBS       * Set blocksize for dir block    01170000
         SETOF UNLSEOF                 * Signal No EOF reached yet      01180000
*                                                                       01190000
* Read directory - 1 block at a time to copy relevant dir-info          01200000
         DO    UNTIL,UNLSEOF           * Repeat until EOF occurs        01210000
          MVPL UNLDECB1,UNL_DECB       * Set up prototype DECB          01220000
          CPY  R_TMP,UNLBUFP           * Point to block buffer          01230000
          READ UNLDECB1,SF,            * Read forward                  *01240000
               UNLDCB1,(R_TMP),'S',    *   1 directory block into buf  *01250000
               MF=E                    *                                01260000
          CHECK UNLDECB1               * Wait for read to complete      01270000
          EXSR CPYDIRB                 * Copy directory block           01280000
         ENDDO ,                       *                                01290000
*                                                                       01300000
* Restore correct blocksize to DCB                                      01310000
         CPY   DCBBLKSI,UNLBLKSI       * Restore blocksize              01320000
*                                                                       01330000
* Release buffer area                                                   01340000
         CPY   R_TMP,UNLBUFP           * Point record buffer            01350000
         CPY   R_LEN,UNLBUFSZ          * Retrieve length of buffer      01360000
         STORAGE RELEASE,              * Free the directory buffer     *01370000
               LENGTH=(R_LEN),         *                               *01380000
               ADDR=(R_TMP)            *                                01390000
         CLEAR UNLBUFP                 * Wipe ptr to buffer             01400000
         CLEAR UNLBUFSZ                * And buffer size                01410000
*                                                                       01420000
* Close input dataset                                                   01430000
         MVPL  UNLCLOS,UNL_CLOS        * Copy CLOSE plist               01440000
         CLOSE (UNLDCB1),MF=(E,UNLCLOS) * Close the input dataset       01450000
         ABND  TSTRC,RCD=R_RCD         *                                01460000
*                                                                       01470000
         ENDSR ,                       *                                01480000
*********************************************************************** 01490000
*                                                                       01500000
* Routine to copy direntries from a dirblock to our own table           01510000
*                                                                       01520000
*********************************************************************** 01530000
CPYDIRB  BEGSR ,                       *                                01540000
*                                                                       01550000
R_PDS    EQUREG ,                      * Assign ptr to PDS entry        01560000
         USE   PDS,R_PDS               * Set PDS direntry addressable   01570000
         CPY   R_PDS,UNLBUFP           * Point to dir buffer            01580000
*                                                                       01590000
R_PDSEND EQUREG ,                      * Assign ptr to end of PDS block 01600000
         USE   R_PDSEND                * Set register in use            01610000
         CPY   R_PDSEND,R_PDS          * Point to buffer                01620000
         AH    R_PDSEND,0(R_PDS)       * Nr of occupied bytes in 1st H  01630000
         INC   R_PDS,2                 * Point to first entry           01640000
*                                                                       01650000
* Process all entries in the current directory block                    01660000
         DO    WHILE,R_PDS,LT,R_PDSEND * For each valid entry           01670000
          CPY  R1,R_PDS                * Ptr to entry to be copied      01680000
          EXSR CPYDIRE                 * Copy a single direntry         01690000
          LA   R_LEN,TTRNUSLN          * Load mask for length bits      01700000
          IC   R_TMP,TTRNINDC          * Retrieve indicator byte        01710000
          NR   R_LEN,R_TMP             * Extract length indication      01720000
          SLL  R_LEN,1                 * Length of user data in bytes   01730000
          LA   R_PDS,PDS_LEN(R_LEN,R_PDS) * Point next entry            01740000
         ENDDO ,                       *                                01750000
*                                                                       01760000
         ENDSR ,                       *                                01770000
*********************************************************************** 01780000
*                                                                       01790000
* Routine to copy a single direntry to our table                        01800000
*                                                                       01810000
*********************************************************************** 01820000
CPYDIRE  BEGSR ,                       *                                01830000
*                                                                       01840000
         USE   PDS,R_PDS               * Set PDS direntry addressable   01850000
         CPY   R_PDS,R1                * Point to current entry         01860000
*                                                                       01870000
R_TABEND EQUREG ,                      * Allocate ptr to end of table   01880000
         USE   R_TABEND                * Set reg in use                 01890000
         CPY   R_TABEND,UNLDIRP        * Point to dir table             01900000
         A     R_TABEND,UNLDIRSZ       * Point past table               01910000
*                                                                       01920000
R_TAB    EQUREG ,                      * Assign current entry pointer   01930000
         USE   R_TAB                   * Set poiner reg in use          01940000
         CPY   R_TAB,UNLDIRFP          * Point current free entry       01950000
*                                                                       01960000
* If last entry: set EOF indicator                                      01970000
         IF    E,CLC,PDSNAME,=8X'FF'   * Terminating entry is all X'FF' 01980000
          SETON UNLSEOF                * Set end-of-directory           01990000
         ENDIF ,                       *                                02000000
*                                                                       02010000
* If our table is full we must enlarge it                               02020000
         IF    NOT,UNLSEOF,AND,        * Entry is valid?               *02030000
               R_TAB,EQ,R_TABEND       * And table is full?             02040000
          L    R_LEN,UNLDIRSZ          * Retrieve current size          02050000
          SLL  R_LEN,1                 * Double current size            02060000
          STORAGE OBTAIN,              * Allocate new buffer           *02070000
               LENGTH=(R_LEN),         *                               *02080000
               LOC=ANY                 *                                02090000
          CPY  R_TAB,R1                * Save ptr to new table          02100000
          CPY  R_LEN,UNLDIRSZ          * Reload old table size          02110000
          CPY  R_TMP,UNLDIRP           * Point existing table           02120000
          CPY  ((R_TAB),(R_LEN)),((R_TMP),(R_LEN)) *                    02130000
          STORAGE RELEASE,             * Free the old buffer           *02140000
               LENGTH=(R_LEN),         *                               *02150000
               ADDR=(R_TMP)            *                                02160000
          CPY  UNLDIRP,R_TAB           * Save ptr to start of new table 02170000
          AR   R_TAB,R_LEN             * Add old size, point free entry 02180000
          CPY  UNLDIRFP,R_TAB          * Set current free pointer       02190000
          SLL  R_LEN,1                 * Size of new table              02200000
          CPY  UNLDIRSZ,R_LEN          * Set new table size             02210000
         ENDIF ,                       *                                02220000
*                                                                       02230000
* Copy entry to table, advance free entry pointer                       02240000
         IF    NOT,UNLSEOF             * A valid entry to process?      02250000
          MVC  0(PDS_LEN,R_TAB),PDS    * Copy entry to table            02260000
          INC  R_TAB,PDS_LEN           * Point next entry               02270000
          CPY  UNLDIRFP,R_TAB          * Update free entry ptr          02280000
         ENDIF ,                       *                                02290000
*                                                                       02300000
         ENDSR ,                       *                                02310000
*********************************************************************** 02320000
*                                                                       02330000
* Routine to read thru all members in sequence                          02340000
*                                                                       02350000
*********************************************************************** 02360000
RDLIB    BEGSR ,                       *                                02370000
*                                                                       02380000
* Create BSAM DCB and open it.                                          02390000
         MVPL  UNLDCB2,UNL_DCB2        * Copy DCB for PDS               02400000
         MVPL  UNLDCBE2,UNL_DCBE       * Copy DCBE for PDS              02410000
         USE   DCB,UNLDCB2             * Set DCB fields addressable     02420000
         USE   DCBE,UNLDCBE2           * Set DCBE fields addressable    02430000
         SET   DCBDCBE,UNLDCBE2        * Point from DCB to DCBE         02440000
         SET   DCBEEODA,LIST_EODAD     * Set ptr to end-of-member rtn   02450000
*                                                                       02460000
         MVPL  UNLOPEN,UNL_OPEN        * Copy OPEN parmlist             02470000
         OPEN  (UNLDCB2,INPUT),        * Open the input dataset        *02480000
               MF=(E,UNLOPEN)          *                                02490000
         ABND  TSTRC,RCD=R_RCD         *                                02500000
*                                                                       02510000
* RECFM must be F, FB, V, or VB                                         02520000
         IF    NM,TM,DCBRECFM,DCBRECF+DCBRECV * Either bit must be on   02530000
          ABND ,                       * RECFM=U: error                 02540000
         ENDIF ,                                                        02550000
*                                                                       02560000
* Allocate a buffer                                                     02570000
         CPY   R_LEN,DCBBLKSI          * Retrieve block size            02580000
         STORAGE OBTAIN,               * Allocate buffer for block     *02590000
               LENGTH=(R_LEN),         *                               *02600000
               LOC=ANY                 *                                02610000
         CPY   UNLBUFP,R1              * Save ptr to buffer             02620000
         CPY   UNLBUFSZ,R_LEN          * and save length of buffer      02630000
*                                                                       02640000
* Create output DCB and open it.                                        02650000
         MVPL  UNLDCBO,UNL_DCBO        * Copy DCB for output dataset    02660000
         MVPL  UNLOPEN,UNL_OPEN        * Copy OPEN parmlist             02670000
         OPEN  (UNLDCBO,OUTPUT),       * Open the output dataset       *02680000
               MF=(E,UNLOPEN)          *                                02690000
         ABND  TSTRC,RCD=R_RCD         *                                02700000
*                                                                       02710000
* Create jcl statements                                                 02720000
         EXSR  CRTJCL                  *                                02730000
*                                                                       02740000
* Set up table pointer                                                  02750000
         USE   PDS,R_TAB               * Set direntry addressable       02760000
         CPY   R_TAB,UNLDIRP           * Point first entry              02770000
*                                                                       02780000
* Loop thru direntries in table                                         02790000
         DO    WHILE,R_TAB,LT,UNLDIRFP * UNLDIRFP points unused entry   02800000
          CPY  R1,R_TAB                * Set ptr                        02810000
          EXSR RDMEM                   * Read the member                02820000
          INC  R_TAB,PDS_LEN           * Point next entry               02830000
         ENDDO ,                       *                                02840000
*                                                                       02850000
* Create terminating control statement for IEBUPDTE                     02860000
         L     R_TMP,=A(CNTLEND)       * Point prototype end statement  02870000
         MVC   UNLBUFO,0(R_TMP)        * Copy prototype control line    02880000
         PUT   UNLDCBO,UNLBUFO         * Write control line to output   02890000
*                                                                       02900000
* Create terminating JCL statement for SYSIN dataset                    02910000
         CLEAR UNLBUFO,C' '            * Pre-fill with spaces           02920000
         MVC   UNLBUFO(2),=C'()'       * Insert eof-marker for sysin    02930000
         PUT   UNLDCBO,UNLBUFO         * Write JCL line to output       02940000
*                                                                       02950000
* Close output dataset                                                  02960000
         MVPL  UNLCLOS,UNL_CLOS        * Copy CLOSE plist               02970000
         CLOSE (UNLDCBO),MF=(E,UNLCLOS) * Close the input dataset       02980000
         ABND  TSTRC,RCD=R_RCD         *                                02990000
*                                                                       03000000
* Close input dataset                                                   03010000
         MVPL  UNLCLOS,UNL_CLOS        * Copy CLOSE plist               03020000
         CLOSE (UNLDCB2),MF=(E,UNLCLOS) * Close the input dataset       03030000
         ABND  TSTRC,RCD=R_RCD         *                                03040000
*                                                                       03050000
         ENDSR ,                       *                                03060000
*********************************************************************** 03070000
*                                                                       03080000
* Routine to read 1 member from the library                             03090000
*                                                                       03100000
* On entry R1 points to the current directory entry in the table        03110000
*                                                                       03120000
*********************************************************************** 03130000
RDMEM    BEGSR ,                       *                                03140000
*                                                                       03150000
* Set up addressability                                                 03160000
         USE   PDS,R_TAB               * Set direntry addressable       03170000
         CPY   R_TAB,R1                * Point current entry            03180000
*                                                                       03190000
         USE   DCB,UNLDCB2             * Set DCB fields addressable     03200000
         USE   DECB,UNLDECB2           * Set DECB fields addressable    03210000
*                                                                       03220000
* Create control statement for IEBUPDTE                                 03230000
         L     R_TMP,=A(CNTLADD)       * Point prototype add statement  03240000
         MVC   UNLBUFO,0(R_TMP)        * Copy prototype control line    03250000
         MVC   UNLBUFO+12(8),PDSNAME   * Insert member name             03260000
         PUT   UNLDCBO,UNLBUFO         * Write control line to output   03270000
*                                                                       03280000
* Point to start of member                                              03290000
         CPY   UNLTTRN,PDSTTRN         * Copy TTR value for member      03300000
         CLEAR UNLTTRN_.TTRNINDC       * Append hex zeroes              03310000
         POINT UNLDCB2,UNLTTRN         * Point to start of dataset      03320000
         ABND  TSTRC,RCD=R_RCD         * Abend on error                 03330000
*                                                                       03340000
* Loop thru all member blocks                                           03350000
         SETOF UNLSEOF                 * Reset end-of-member bit        03360000
         DO    UNTIL,UNLSEOF           * Until end-of-member            03370000
          MVPL UNLDECB2,UNL_DECB       * Set up prototype DECB          03380000
          CPY  R_TMP,UNLBUFP           * Point to block buffer          03390000
          READ UNLDECB2,SF,            * Read forward                  *03400000
               UNLDCB2,(R_TMP),'S',    *   1 member data block         *03410000
               MF=E                    *                                03420000
          CHECK UNLDECB2               * Wait for read to complete      03430000
          IF   NOT,UNLSEOF             * A valid block was read?        03440000
* For Fixed records: use IOB to determine end-of-buffer                 03450000
* For Variable records: use BDW to determine end-of-buffer              03460000
           IF  DCBRECF                 * Fixed or FB records?           03470000
            CPY R_LEN,DCBBLKSI         * Load block length              03480000
R_IOB       EQUREG ,                   * Assign IOB ptr                 03490000
            USE IOBSTDRD,R_IOB         * Set IOB addressable            03500000
            CPY R_IOB,DECIOBPT         * And point to IOB               03510000
            CPY R_TMP,IOBRESCT         * Load residual count            03520000
            DROP R_IOB                 * IOB no longer needed           03530000
            SR R_LEN,R_TMP             * Nr of bytes in input buffer    03540000
            A  R_LEN,UNLBUFP           * Point past end-of-data         03550000
            ST R_LEN,UNLBUFND          * Save end-of-block ptr          03560000
            CPY UNLRCDP,UNLBUFP        * Set ptr to first record        03570000
           ELSE  ,                     * Must be variable or VB records 03580000
R_BUF       EQUREG ,                   * Assign buffer ptr              03590000
            USE BDW,R_BUF              * Address block descriptor word  03600000
            CPY R_BUF,UNLBUFP          * Point to filled buffer         03610000
            CPY R_LEN,BDWBLKLN         * Retrieve length of block       03620000
            A  R_LEN,UNLBUFP           * Point past end-of-data         03630000
            ST R_LEN,UNLBUFND          * Save end-of-block ptr          03640000
            INC R_BUF,BDW_LEN          * Point to first RDW in buffer   03650000
            CPY UNLRCDP,R_BUF          * Set ptr to current record      03660000
            DROP R_BUF                 * Buffer ptr no longer needed    03670000
           ENDIF ,                     *                                03680000
           EXSR CPYBLK                 * Go copy a block to output      03690000
          ENDIF ,                      *                                03700000
         ENDDO ,                       *                                03710000
*                                                                       03720000
         ENDSR ,                       *                                03730000
*********************************************************************** 03740000
*                                                                       03750000
* Routine to copy a whole block of data to the output dataset           03760000
*                                                                       03770000
*********************************************************************** 03780000
CPYBLK   BEGSR ,                       *                                03790000
*                                                                       03800000
* Set up to loop thru the block                                         03810000
R_REC    EQUREG ,                      * Assign record ptr              03820000
         USE   RDW,R_REC               * Assume RECFM=V or VB           03830000
*                                                                       03840000
         USE   DCB,UNLDCB2             * Set DCB fields addressable     03850000
*                                                                       03860000
* For each record in the buffer:                                        03870000
* - determine length, advance current record pointer                    03880000
* - copy record, truncate if too long, pad if too short                 03890000
* - write record to output dataset                                      03900000
*                                                                       03910000
         DO    WHILE,UNLRCDP,LT,UNLBUFND * For each record in buffer    03920000
*         Determine length, advance current record pointer              03930000
          CPY  R_REC,UNLRCDP           * Copy ptr to current record     03940000
          IF   DCBRECF                 * Fixed record length:           03950000
           CPY R_LEN,DCBLRECL          * Retrieve rec length from DCB   03960000
           CPY R_TMP,R_REC             * Copy current record ptr        03970000
           INC R_TMP,(R_LEN)           * Point to next record           03980000
           CPY UNLRCDP,R_TMP           * Update current record ptr      03990000
          ELSE ,                       * Variable records:              04000000
           CPY R_LEN,RDWRECLN          * Retrieve length of record      04010000
           CPY R_TMP,R_REC             * Copy current record pointer    04020000
           INC R_TMP,(R_LEN)           * Point next record in buffer    04030000
           CPY UNLRCDP,R_TMP           * Update current record pointer  04040000
           INC R_REC,RDW_LEN           * Point to start of record data  04050000
           DEC R_LEN,RDW_LEN           * And adjust data length         04060000
          ENDIF ,                      *                                04070000
*         Copy record, truncate if too long, pad if too short           04080000
          IF   R_LEN,GE,UNLBUFO_LEN    * Truncating move needed?        04090000
           MVC UNLBUFO,0(R_REC)        * Copy 80 bytes of input data    04100000
          ELSE ,                       * Need to pad                    04110000
           CLEAR UNLBUFO               * Pre-fill with blanks           04120000
           EXMVC UNLBUFO(R_LEN),0(R_REC) * Copy whole input record      04130000
          ENDIF ,                      *                                04140000
*         Write record to output dataset                                04150000
          PUT  UNLDCBO,UNLBUFO         * Write record to output dataset 04160000
         ENDDO ,                       *                                04170000
*                                                                       04180000
         ENDSR ,                       *                                04190000
*********************************************************************** 04200000
*                                                                       04210000
* Routine to create jcl statements                                      04220000
*                                                                       04230000
*********************************************************************** 04240000
CRTJCL   BEGSR ,                       *                                04250000
*                                                                       04260000
* Set input DCB subfields addressable                                   04270000
         USE   DCB,UNLDCB2             * Opened input DCB               04280000
*                                                                       04290000
* Retrieve datasetname from JFCB                                        04300000
R_TCBT   EQUREG TEMP=YES               * Assign TCB pointer             04310000
         CPY   R_TCBT,PSATOLD          * Load TCB-address               04320000
         USE   TCB,R_TCBT              * And set it addressable         04330000
R_TIOT   EQUREG ,                      * Assign TIOT pointer            04340000
         CPY   R_TIOT,TCBTIO           * Retrieve TIOT-pointer          04350000
         DROP  R_TCBT                  * TCB no longer needed           04360000
         LTHU  R_LEN,DCBTIOT           * Load TIOT-offset from DCB      04370000
         AR    R_TIOT,R_LEN            * Point to TIOT entry            04380000
         USE   TIOENTRY,R_TIOT         * Set TIOT entry addressable     04390000
*                                                                       04400000
* Find JFCB to retrieve dataset name                                    04410000
         LTA24 R1,TIOEJFCB             * Load JFCB token value          04420000
         DROP  R_TIOT                  * TIOENTRY no longer needed      04430000
*                                                                       04440000
         CLEAR UNLEPAX                 * Clear SWAREQ's EPA             04450000
EPA      USE   UNLD.UNLEPAX            * Set subfields addressable      04460000
         STA24 R1,EPA.SWVA             * Put JFCB token into EPAX       04470000
         SET   UNLEPAPT,UNLEPAX        * Set up pointer to EPAX         04480000
         MVPL  UNLSWARQ,UNL_SWARQ      * Copy prototype SWAREQ plist    04490000
         SWAREQ FCODE=RL,              * Request a read-locate         *04500000
               UNAUTH=YES,             *   in unauthorized mode        *04510000
               EPA=UNLEPAPT,           *   using this EPA pointer      *04520000
               MF=(E,UNLSWARQ)         *   and this parmlist            04530000
         CPY   R_RCD,R15               * Save retcode                   04540000
*                                                                       04550000
* Check validity of the results                                         04560000
         IF    R_RCD,NZ,OR,            * Skip ORCB if SWAREQ erred     *04570000
               EPA.SWLVERS,NZ,OR,      * Only version 0 supported      *04580000
               NOT,EPA.SWJFCBID        * Returned block is JFCB?        04590000
          ABND ,                       * Then we cannot proceed!        04600000
         ENDIF ,                       *                                04610000
R_JFCB   EQUREG ,                      * Assign JFCB pointer            04620000
         LT    R_JFCB,EPA.SWBLKPTR     * Valid JFCB pointer?            04630000
         ABND  Z                       * No: abend                      04640000
         DROP  EPA                     * UNLEPAX no longer needed       04650000
*                                                                       04660000
* R_JFCB now points to the JFCB for the opened DCB                      04670000
         USE   JFCB,R_JFCB             * Set JFCB addressable.          04680000
         MVC   UNLDSN,JFCBDSNM         * Copy data set name             04690000
         CPY   UNLPQTY,JFCBPQTY        * Primary allocation             04700000
         CPY   UNLSQTY,JFCBSQTY        * Secondary allocation           04710000
         CPY   UNLDQTY,JFCBDQTY        * Directory allocation           04720000
         CASE  JFCBCYL                 * Cylinder allocation?           04730000
          SETON UNLALCYL               *                                04740000
         CASE  JFCBTRK                 * Track allocation?              04750000
          SETON UNLALTRK               *                                04760000
         ELSE  ,                       * Must be block allocation       04770000
          SETON UNLALBLK               *                                04780000
         ENDCASE ,                     *                                04790000
         DROP  R_JFCB                  * JFCB no longer needed          04800000
*                                                                       04810000
* Find length of data set name                                          04820000
         L     R_TMP,=AL4(TRTAB1)      * Point to TRT table             04830000
         TRT   UNLDSN(44),0(R_TMP)     * Find first blank in name       04840000
         IF    Z                       * No blanks found:               04850000
          CPY  UNLDSNLN,44             * Length is 44                   04860000
         ELSE  ,                       * R1 points first blank          04870000
          LA   R_TMP,UNLDSN            * Point to start of name         04880000
          SR   R1,R_TMP                * R1 points invalid char         04890000
          CPY  UNLDSNLN,R1             * Save length of DSN             04900000
         ENDIF ,                       *                                04910000
*                                                                       04920000
* Determine allocation sizes                                            04930000
         IF    UNLSQTY,Z               * Secondary quantity valid?      04940000
          CPY  UNLSQTY,10              * No, assume 10                  04950000
         ENDIF ,                       *                                04960000
*                                                                       04970000
         IF    UNLPQTY,Z               * Secondary quantity valid?      04980000
          CPY  R_TMP,UNLSQTY           * No, use secondary space        04990000
          LA   R_TMP,0(R_TMP,R_TMP)    *     times two                  05000000
          CPY  UNLPQTY,R_TMP           *     for primary space          05010000
         ENDIF ,                       *                                05020000
*                                                                       05030000
         IF    UNLDQTY,Z               * Directory quantity valid?      05040000
R_EVEN    EQUREG ODD=R_ODD,PAIR=YES,TEMP=YES * Assign pair of regs      05050000
          CPY  R_ODD,UNLDIRFP          * Point free entry               05060000
          S    R_ODD,UNLDIRP           * Minus start = size of table    05070000
          CLEAR R_EVEN                 * Make it a 64-bit integer       05080000
          LA   R_LEN,12*5              * 5 direntries into a dir block  05090000
          DR   R_EVEN,R_LEN            * using 4 gives some spare room  05100000
          INC  R_ODD,5                 * Add room for 25 more entries   05110000
          CPY  UNLDQTY,R_ODD           *                                05120000
         ENDIF ,                       *                                05130000
*                                                                       05140000
* Set up to loop thru the JCL records                                   05150000
         USE   R_REC                   * Set register in use            05160000
         L     R_REC,=A(JCLTAB)        * Point to JCL table             05170000
         DO    WHILE,R_REC,LT,=A(JCLTAB_END) * For each statement       05180000
          MVC  UNLBUFO,0(R_REC)        * Copy record to buffer          05190000
*         +1 triggers insertion of dataset name                         05200000
          CASE E,CLC,UNLBUFO(2),=C'+1' * Type 1 substitution?           05210000
           MVC UNLBUFO(2),=C'//'       * Make it a decent JCL statement 05220000
           CPY R_LEN,UNLDSNLN          * Retrieve length of DSN         05230000
           EXMVC UNLBUFO+20(R_LEN),UNLDSN * Insert data set name        05240000
           LA  R_TMP,UNLBUFO+20(R_LEN) * Point beyond dataset name      05250000
           MVI 0(R_TMP),C','           * Insert comma                   05260000
*         +2 triggers insertion of allocation parameters                05270000
          CASE E,CLC,UNLBUFO(2),=C'+2' * Type 2 substitution?           05280000
           MVC UNLBUFO(2),=C'//'       * Make it a decent JCL statement 05290000
*          Allocate cylinders, tracks or blocks?                        05300000
           CASE UNLALCYL,NEST=YES      * Allocation is in cylinders?    05310000
            MVC UNLBUFO+22(3),=C'CYL'  *                                05320000
            MVC UNLBUFO+25(52),UNLBUFO+27 * Remove superfluous chars    05330000
            MVC UNLBUFO+78(2),=CL2'  ' * and add trailing spaces        05340000
           CASE UNLALTRK               * Allocation in tracks?          05350000
            MVC UNLBUFO+22(3),=C'TRK'  *                                05360000
            MVC UNLBUFO+25(52),UNLBUFO+27 * Remove superfluous chars    05370000
            MVC UNLBUFO+78(2),=CL2'  ' * and add trailing spaces        05380000
           CASE UNLALBLK               * Allocation in blocks?          05390000
            CPY R_TMP,UNLBLKSI         * Load block size                05400000
            CVD R_TMP,UNLCVD           * Make result decimal            05410000
            UNPK UNLQTY,UNLCVD         * Make result readable           05420000
            OI  UNLQTY+L'UNLQTY-1,C'0' * Without a sign                 05430000
            MVC UNLBUFO+22(L'UNLQTY),UNLQTY * And insert into JCL line  05440000
           ELSE ,                      * Programming error!             05450000
            ABND ,                     *                                05460000
           ENDCASE ,                   *                                05470000
*          Insert primary allocation quantity                           05480000
           CPY  R_TMP,UNLPQTY          * Load primary qty               05490000
           CVD  R_TMP,UNLCVD           * Make result decimal            05500000
           UNPK UNLQTY,UNLCVD          * Make result readable           05510000
           OI   UNLQTY+L'UNLQTY-1,C'0' * Without a sign                 05520000
           MVC  UNLBUFO+29(L'UNLQTY),UNLQTY * And insert into JCL line  05530000
*          Insert secondary allocation quantity                         05540000
           CPY  R_TMP,UNLSQTY          * Load secondary qty             05550000
           CVD  R_TMP,UNLCVD           * Make result decimal            05560000
           UNPK UNLQTY,UNLCVD          * Make result readable           05570000
           OI   UNLQTY+L'UNLQTY-1,C'0' * Without a sign                 05580000
           MVC  UNLBUFO+35(L'UNLQTY),UNLQTY * And insert into JCL line  05590000
*          Insert directory allocation quantity                         05600000
           CPY  R_TMP,UNLDQTY          * Load directory qty             05610000
           CVD  R_TMP,UNLCVD           * Make result decimal            05620000
           UNPK UNLQTY,UNLCVD          * Make result readable           05630000
           OI   UNLQTY+L'UNLQTY-1,C'0' * Without a sign                 05640000
           MVC  UNLBUFO+41(L'UNLQTY),UNLQTY * And insert into JCL line  05650000
*         +3 triggers insertion of step name                            05660000
          CASE E,CLC,UNLBUFO(2),=C'+3' * Type 3 substitution?           05670000
           MVC UNLBUFO(2),=C'//'       * Make it a decent JCL statement 05680000
           IF  UNLSPRM                 * Valid parm was passed?         05690000
            MVC UNLBUFO+2(8),UNLPARM   * Insert step name from parm     05700000
           ENDIF ,                     *                                05710000
          ENDCASE ,                    *                                05720000
*         Write completed JCL record                                    05730000
          PUT  UNLDCBO,UNLBUFO         * Write record to output dataset 05740000
          INC  R_REC,80                * Point next record              05750000
         ENDDO ,                       *                                05760000
         DROP  R_REC                   * Record ptr done                05770000
*                                                                       05780000
         ENDSR ,                       *                                05790000
*********************************************************************** 05800000
*                                                                       05810000
* Constants etc.                                                        05820000
*                                                                       05830000
*********************************************************************** 05840000
         LTORG ,                       *                                05850000
*********************************************************************** 05860000
*                                                                       05870000
* Out-of-line routines                                                  05880000
*                                                                       05890000
*********************************************************************** 05900000
*                                                                       05910000
* EOF-routine for input dataset                                         05920000
LIST_EODAD LABEL H                     *                                05930000
         SETON UNLSEOF                 * Signal EOF reached             05940000
         BR    R14                     * Return to main line            05950000
*********************************************************************** 05960000
*                                                                       05970000
* Indirectly addressable Plists and constants                           05980000
*                                                                       05990000
*********************************************************************** 06000000
UNL_DCB1 DCB   DDNAME=SYSUT1,          * Prototype for DCB             *06010000
               DSORG=PO,               * Directory is sequential       *06020000
               DCBE=UNL_DCBE,          * EODAD in DCBE                 *06030000
               MACRF=R                 * Read blocks only               06040000
*                                                                       06050000
UNL_DCB2 DCB   DDNAME=SYSUT1,          * Prototype for DCB             *06060000
               DSORG=PS,               * Directory is sequential       *06070000
               DCBE=UNL_DCBE,          * EODAD in DCBE                 *06080000
               MACRF=RP                * Read blocks only               06090000
*                                                                       06100000
UNL_DCBO DCB   DDNAME=SYSUT2,          * Prototype for DCB             *06110000
               DSORG=PS,               * output is sequential          *06120000
               MACRF=PM                * use Put in Move mode           06130000
*                                                                       06140000
UNL_DCBE DCBE  EODAD=LIST_EODAD        * DCBE to be used with DCB1/DCB2 06150000
*                                                                       06160000
         READ  UNL_DECB,SF,MF=L        * Read forward DCB1/DCB2         06170000
*                                                                       06180000
UNL_OPEN OPEN  (0,INPUT),MF=L          * Prototype for OPEN             06190000
UNL_CLOS CLOSE (0),MF=L                * Prototype for CLOSE            06200000
*                                                                       06210000
UNL_SWARQ SWAREQ EPA=0,                * Prototype for SWAREQ parmlist *06220000
               MF=L                    *                                06230000
*                                                                       06240000
TRTAB1   TRTAB NOTUC,                  * Uppercase chars are valid     *06250000
               CHARS=(0,1,2,3,4,5,6,7,8,9, * Digits are valid too      *06260000
               C'#',C'@',C'$',C'.')    * Other valid chars              06270000
*                                                                       06280000
JCLTAB   DS    0D                      * Table with JOB jcl             06290000
*                   012345678901234567890123456789012345678901234567890 06300000
         DC    CL80'//BXALOAD  JOB  ,''Load BIXOFT libs'',CLASS=A'      06310000
         DC    CL80'//*'                                                06320000
         DC    CL80'//* This job loads source libraries for BIXXAMS'    06330000
         DC    CL80'//*'                                                06340000
         DC    CL80'+3CRTLIB   EXEC PGM=IEBUPDTE,PARM=NEW'              06350000
         DC    CL80'+1SYSUT2   DD   DSN='                               06360000
         DC    CL80'+2             SPACE=(00080,(00020,00010,00005)),'  06370000
         DC    CL80'//             DISP=(MOD,CATLG),DSORG=PO,'          06380000
         DC    CL80'//             RECFM=FB,LRECL=80,UNIT=SYSALLDA'     06390000
         DC    CL80'//SYSPRINT DD   DUMMY'                              06400000
         DC    CL80'//SYSIN    DD   DATA,DLM=''()'''                    06410000
JCLTAB_END EQU *                                                        06420000
CNTLADD  DC    CL80'./ ADD NAME='                                       06430000
CNTLEND  DC    CL80'./ ENDUP'                                           06440000
*                                                                       06450000
         END                                                            06460000
