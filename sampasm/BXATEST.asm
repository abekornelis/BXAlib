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
* This program tests a condition string, which is passed as a           00190000
* parameter on the exec statement. Syntax:                              00200000
* PARM='parm1 oper parm2'                                               00210000
* where parm1 and parm2 are the comparands and                          00220000
* oper is either EQ or NE                                               00230000
* The delimiters are single spaces                                      00240000
*                                                                       00250000
*********************************************************************** 00260000
         PGM   VERSION=V00R00M00,      * Version number                *00270000
               HDRTXT='Bixxams condition tester',                      *00280000
               WORKAREA=BXASAVE,       * Dynamic area                  *00290000
               SAVES=0,                * Internal save-areas           *00300000
               ABND=4090               * Abend code for BXATEST         00310000
*                                                                       00320000
* Assign some global registers                                          00330000
R_RCD    EQUREG ,                      * Assign retcode register        00340000
         USE   R_RCD,SCOPE=CALLED      * Set register in use            00350000
R_TMP    EQU   R_RCD                   * retcode reg also temp reg      00360000
R_PTR1   EQUREG ,                      * Ptr to first operand           00370000
         USE   R_PTR1                  * Set register in use            00380000
R_PTR2   EQUREG ,                      * Ptr to second operand          00390000
         USE   R_PTR2                  * Set register in use            00400000
R_PTROP  EQUREG ,                      * Ptr to operator                00410000
         USE   R_PTROP                 * Set register in use            00420000
R_LEN1   EQUREG ,                      * Length of first operand        00430000
         USE   R_LEN1                  * Set register in use            00440000
R_LEN2   EQUREG ,                      * Length of second operand       00450000
         USE   R_LEN2                  * Set register in use            00460000
R_LENOP  EQUREG ,                      * Length of operator             00470000
         USE   R_LENOP                 * Set register in use            00480000
*                                                                       00490000
* Retrieve JCL parameter - if specified - and save in R_PTR1            00500000
         IF    R1,Z                    * Pointer to parmlist valid?     00510000
          ABND ,                       * No: issue error                00520000
         ENDIF ,                       *                                00530000
         L     R_PTR1,0(,R1)           * Retrieve ptr to JCL parm       00540000
         CLEAR (R_PTR1,*ADDR)          * Wipe hi-order bit              00550000
         IF    R_PTR1,Z                * If it is invalid               00560000
          ABND ,                       * issue error                    00570000
         ENDIF ,                       *                                00580000
         LH    R_LEN1,0(R_PTR1)        * First halfword is length       00590000
         INC   R_PTR1,2                * Point start of text of parm    00600000
         IF    R_LEN1,GT,256           * If it is too long              00610000
          ABND ,                       * Issue error                    00620000
         ENDIF ,                       *                                00630000
         IF    R_LEN1,Z                * If no parm was specified       00640000
          ABND ,                       * Issue error                    00650000
         ENDIF ,                       *                                00660000
*                                                                       00670000
* Find first space in input string                                      00680000
         L     R_TMP,=A(TRTAB1)        * Point table to be used         00690000
         EXTRT 0(R_LEN1,R_PTR1),0(R_TMP) * Search first space           00700000
         ABND  Z                       * Abend if no space found        00710000
*                                                                       00720000
* Set pointer to opcode                                                 00730000
         LA    R_PTROP,1(,R1)          * Point first byte of opcode     00740000
         CPY   R_PTR2,R_PTROP          * Start of remainder of string   00750000
*                                                                       00760000
* Determine length of operand 1 and remainder of string                 00770000
         CPY   R_LEN2,R_LEN1           * Copy string length             00780000
         CPY   R_TMP,R1                * Delimiter location             00790000
         SR    R_TMP,R_PTR1            * Nr of chars in first operand   00800000
         ABND  Z                       * Empty operand is error         00810000
         CPY   R_LEN1,R_TMP            * Set length of operand 1        00820000
         SR    R_LEN2,R_LEN1           * Remaining string length        00830000
         DEC   R_LEN2                  *    after delimiter             00840000
         IF    R_LEN2,LE,0             * Something left?                00850000
          ABND ,                       * No: error                      00860000
         ENDIF ,                       *                                00870000
*                                                                       00880000
* Determine length of opcode and remainder of string                    00890000
         L     R_TMP,=A(TRTAB1)        * Point table to be used         00900000
         EXTRT 0(R_LEN2,R_PTR2),0(R_TMP) * Search next space            00910000
         ABND  Z                       * Abend if no space found        00920000
         CPY   R_LENOP,R1              * Point to delimiter             00930000
         SR    R_LENOP,R_PTROP         * Nr of chars in operator        00940000
         ABND  Z                       * No operator: error             00950000
         LA    R_PTR2,1(,R1)           * Point after delimiter          00960000
         SR    R_LEN2,R_LENOP          * Remove operator from length    00970000
         DEC   R_LEN2                  *    and delimiter as well       00980000
         IF    R_LEN2,LE,0             * Something left?                00990000
          ABND ,                       * No: error                      01000000
         ENDIF ,                       *                                01010000
*                                                                       01020000
* Determine length of operand 2                                         01030000
         L     R_TMP,=A(TRTAB1)        * Point table to be used         01040000
         EXTRT 0(R_LEN2,R_PTR2),0(R_TMP) * Search next space            01050000
         IF    NZ                      * Delimiter found                01060000
          CPY  R_LEN2,R1               * Set to delimiter location      01070000
          SR   R_LEN2,R_PTR2           * Nr of chars in operand 2       01080000
          ABND Z                       * Missing operand: error         01090000
         ENDIF ,                       *                                01100000
*                                                                       01110000
* Test for equal comparison?                                            01120000
         IF    E,EXCLC,0(R_LENOP,R_PTROP),=CL2'EQ' * EQ comparison?     01130000
          IF   R_LEN1,NE,R_LEN2        * Lengths should be equal        01140000
           GOTO RETCD4                 * Return mismatch                01150000
          ENDIF ,                      *                                01160000
          EXCLC 0(R_LEN1,R_PTR1),0(R_PTR2) * Operands equal?            01170000
          GOTO RETCD0,E                * Yes: return ok                 01180000
          GOTO RETCD4                  * No: return mismatch            01190000
         ENDIF ,                                                        01200000
*                                                                       01210000
* Test for unequal comparison?                                          01220000
         IF    E,EXCLC,0(R_LENOP,R_PTROP),=CL2'NE' * NE comparison?     01230000
          IF   R_LEN1,NE,R_LEN2        * Lengths should be unequal      01240000
           GOTO RETCD0                 * Return mismatch                01250000
          ENDIF ,                      *                                01260000
          EXCLC 0(R_LEN1,R_PTR1),0(R_PTR2) * Operands unequal?          01270000
          GOTO RETCD0,NE               * Yes: return ok                 01280000
          GOTO RETCD4                  * No: return mismatch            01290000
         ENDIF ,                                                        01300000
*                                                                       01310000
* Invalid operator                                                      01320000
         ABND  ,                       *                                01330000
*                                                                       01340000
* Return 4 when specified condition is not met                          01350000
RETCD4   LABEL ,                       *                                01360000
         LA    R15,4                   * Set retcode                    01370000
         GOTO  EXIT                    *                                01380000
*                                                                       01390000
* Return 0 when specified condition is met                              01400000
RETCD0   LABEL ,                       *                                01410000
         CLEAR R15                     * Set retcode                    01420000
*                                                                       01430000
EXIT     LABEL ,                       * Exit point                     01440000
*                                                                       01450000
* Release registers                                                     01460000
         DROP  R_PTR1                  *                                01470000
         DROP  R_PTR2                  *                                01480000
         DROP  R_PTROP                 *                                01490000
         DROP  R_LEN1                  *                                01500000
         DROP  R_LEN2                  *                                01510000
         DROP  R_RCD                   *                                01520000
*                                                                       01530000
* And exit                                                              01540000
         RETRN RC=*                    * Quit this program              01550000
*********************************************************************** 01560000
*                                                                       01570000
* Constants etc.                                                        01580000
*                                                                       01590000
*********************************************************************** 01600000
         LTORG ,                       *                                01610000
*********************************************************************** 01620000
*                                                                       01630000
* Indirectly addressable Plists and constants                           01640000
*                                                                       01650000
*********************************************************************** 01660000
TRTAB1   TRTAB ,                       * Select no characters          *01670000
               CHARS=(C' ')            * Except space                   01680000
*                                                                       01690000
         END                                                            01700000
