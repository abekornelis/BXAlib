//BXAIEWL  PROC MEMB=,PROJ=,LVL=                                        00010000
//*                                                                     00011000
//* Linkage-editor for CRTxxxxx jobs                                    00011101
//*                                                                     00011201
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00012000
//*                                                                     00020000
//* Invoke linkage editor, using default parms                          00030000
//*                                                                     00040000
//LKED     EXEC PGM=IEWL,PARM=('MAP,XREF,LIST')                         00050000
//*             Primary input: LKED source member                       00060000
//SYSLIN   DD   DSN=&HLQ..&PROJ..&LVL..LKED(&MEMB),DISP=SHR             00070000
//*             Additional input: object libraries                      00080000
//OBJECTS  DD   DSN=&HLQ..&PROJ..&LVL..OBJ,DISP=SHR                     00090000
//         DD   DSN=&HLQ..&PROJ..PROD.OBJ,DISP=SHR                      00100000
//*             Linkage editor work data set                            00110000
//SYSUT1   DD   DSN=&&SYSUT1,SPACE=(4096,(120,120),,,ROUND),            00120000
//             UNIT=VIO,DCB=BUFNO=1                                     00130000
//*             Listing data set                                        00140000
//SYSPRINT DD   DSN=&HLQ..&PROJ..&LVL..LKED.LIST(&MEMB),DISP=SHR        00150000
//*             Load module output data set                             00160000
//SYSLMOD  DD   DSN=&HLQ..&PROJ..&LVL..LINKLIB(&MEMB),DISP=SHR          00170000
//*                                                                     00180000
//         PEND                                                         00190000
