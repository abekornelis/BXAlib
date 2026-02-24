*PROCESS RENT                                                           00010000
*PROCESS FLAG(SUBSTR)                                                   00020000
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
* Entry for stand-alone testing new mapping macro's                     00190000
         PGM   VERSION=V00R00M00,      * Version number                *00200000
               HDRTXT='Testpgm for GLUE macro',                        *00210000
               ENTRY=MAIN,             * Entry for subroutine          *00220000
               AMODE=24,               * 24-bit addr. mode             *00230000
               RMODE=24,               * Resides below 16 Mb           *00240000
               ABND=4090,              * Abend code for BXALOWPG       *00250000
               MAPS=(BITS,REGS),       * Standard mappings             *00260000
               LIST=NO                 *                                00270000
*                                                                       00280000
R_RCD    EQUREG ,                      * Allocate retcode register      00290000
         USE   R_RCD                   *                                00300000
*                                                                       00310000
         RWTO  'BXALOWPG is now running'                                00320000
         ABND  TSTRC,RCD=R5            * warning messages in assembly   00330000
*                                                                       00340000
         RETRN RC=0                    * Normal return to caller        00350000
*********************************************************************** 00360000
*                                                                       00370000
* Constants etc.                                                        00380000
*                                                                       00390000
*********************************************************************** 00400000
         LTORG ,                       *                                00410000
*                                                                       00420000
         END                                                            00430000
