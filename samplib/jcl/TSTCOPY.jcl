//TSTCOPY  JOB (7355,710,&SYSUID),'Test Loadmod',NOTIFY=&SYSUID,        00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//JOBLIB   DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00020000
//*                                                                     00030000
//* Test BPAM member copy                                               00040000
//BXACOPYP EXEC PGM=BXACOPY,PARM='MEMBER=TSTCOPY'                       00050000
//SYSUDUMP DD   SYSOUT=*                                                00060000
//INPUT    DD   DSN=&HLQ..GOODIES.TEST.JCL,DISP=SHR                     00070000
//         DD   DSN=&HLQ..GOODIES.PROD.JCL,DISP=SHR                     00080000
//OUTPUT   DD   DSN=&&JCLMEM1,SPACE=(TRK,(10,10),RLSE),                 00090000
//             DCB=(LRECL=80,BLKSIZE=27920),UNIT=SYSALLDA               00100000
//*                                                                     00110000
//* Test BSAM concatenation copy                                        00120000
//BXACOPY  EXEC PGM=BXACOPY,PARM='DATSET=PS'                            00130000
//SYSUDUMP DD   SYSOUT=*                                                00140000
//INPUT    DD   DSN=&HLQ..GOODIES.TEST.JCL(TSTCOPY),DISP=SHR            00150000
//         DD   DSN=&HLQ..GOODIES.PROD.JCL(TSTCOPY),DISP=SHR            00160000
//OUTPUT   DD   DSN=&&JCLMEM2,SPACE=(TRK,(10,10),RLSE),                 00170000
//             DCB=(LRECL=80,BLKSIZE=27920),UNIT=SYSALLDA               00180000
