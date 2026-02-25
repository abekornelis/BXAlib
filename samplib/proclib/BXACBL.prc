//BXACBL   PROC MEMB=,PROJ=,LVL=                                        00010000
//*                                                                     00011000
//* Cobol compiler                                                      00011100
//*                                                                     00011200
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00012000
//*                                                                     00020000
//* Copy source member to be used                                       00030000
//*                                                                     00040000
//COPY     EXEC PGM=BXACOPY,PARM='MEMBER=&MEMB'                         00050000
//STEPLIB  DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00060000
//INPUT    DD   DSN=&HLQ..&PROJ..&LVL..CBL,DISP=SHR                     00070000
//         DD   DSN=&HLQ..&PROJ..PROD.CBL,DISP=SHR                      00080000
//OUTPUT   DD   SPACE=(TRK,(10,10,1),RLSE),DISP=(NEW,PASS,DELETE),      00090000
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920),                   00100000
//             DSN=&&CBL(&MEMB),UNIT=SYSALLDA                           00110001
//*                                                                     00120000
//* Invoke Cobol compiler using default parms                           00130000
//*                                                                     00140000
//CBL      EXEC PGM=IGYCRCTL,REGION=4096K,                              00150000
//             PARM=('RENT')                                            00160000
//STEPLIB  DD   DSNAME=IGY.SIGYCOMP,DISP=SHR                            00170000
//*                                                                     00180000
//*        Primary input: cobol source code                             00190000
//SYSIN    DD   DSN=&&CBL(&MEMB),DISP=(OLD,DELETE,DELETE)               00200000
//*        Compiler temp work datasets                                  00210000
//SYSUT1   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00220000
//SYSUT2   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00230000
//SYSUT3   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00240000
//SYSUT4   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00250000
//SYSUT5   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00260000
//SYSUT6   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00270000
//SYSUT7   DD   UNIT=SYSDA,SPACE=(CYL,(1,1))                            00280000
//*        Listing dataset                                              00290000
//SYSPRINT DD   DSN=&HLQ..&PROJ..&LVL..CBL.LIST(&MEMB),DISP=SHR         00300000
//*        Object output dataset                                        00310000
//SYSLIN   DD   DSN=&HLQ..&PROJ..&LVL..OBJ(&MEMB),DISP=SHR              00320000
//*                                                                     00330000
//         PEND                                                         00340000
