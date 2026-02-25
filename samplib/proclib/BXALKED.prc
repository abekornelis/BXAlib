//BXALKED  PROC MEMB=,PROJ=,LVL=                                        00010000
//*                                                                     00011000
//* Linkage-editor                                                      00011100
//*                                                                     00011200
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00012000
//*                                                                     00020000
//* Copy source member to be used                                       00030000
//*                                                                     00040000
//COPY     EXEC PGM=BXACOPY,PARM='MEMBER=&MEMB'                         00050000
//STEPLIB  DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00060000
//INPUT    DD   DSN=&HLQ..&PROJ..&LVL..LKED,DISP=SHR                    00070000
//         DD   DSN=&HLQ..&PROJ..PROD.LKED,DISP=SHR                     00080000
//OUTPUT   DD   SPACE=(TRK,(10,10,1),RLSE),DISP=(NEW,PASS,DELETE),      00090000
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920),                   00100000
//             DSN=&&LKED(&MEMB),UNIT=SYSALLDA                          00110000
//*                                                                     00120000
//* Invoke linkage editor, using default parms                          00130000
//*                                                                     00140000
//LKED     EXEC PGM=IEWL,PARM=('MAP,XREF,LIST')                         00150000
//*             Primary input: LKED source member                       00160000
//SYSLIN   DD   DSN=&&LKED(&MEMB),DISP=(OLD,DELETE,DELETE)              00170000
//*             Additional input: object libraries                      00180000
//OBJECTS  DD   DSN=&HLQ..&PROJ..&LVL..OBJ,DISP=SHR                     00190000
//         DD   DSN=&HLQ..&PROJ..PROD.OBJ,DISP=SHR                      00200000
//*             Additional input: cobol modules                         00210000
//COBOL    DD   DSN=CEE.SCEELKED,DISP=SHR                               00220003
//*             Additional input: language environment modules          00230000
//LE       DD   DSN=CEE.SCEELKED,DISP=SHR                               00240002
//*             Linkage editor work data set                            00250000
//SYSUT1   DD   DSN=&&SYSUT1,SPACE=(4096,(120,120),,,ROUND),            00260000
//             UNIT=VIO,DCB=BUFNO=1                                     00270000
//*             Listing data set                                        00280000
//SYSPRINT DD   DSN=&HLQ..&PROJ..&LVL..LKED.LIST(&MEMB),DISP=SHR        00290000
//*             Load module output data set                             00300000
//SYSLMOD  DD   DSN=&HLQ..&PROJ..&LVL..LINKLIB(&MEMB),DISP=SHR          00310000
//*                                                                     00320000
//         PEND                                                         00330000
