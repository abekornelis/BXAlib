//TSTUNLD  JOB (7355,710,&SYSUID),'Test Loadmod',NOTIFY=&SYSUID,        00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//JOBLIB   DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00020000
//*                                                                     00030000
//DELETE   EXEC PGM=IEFBR14                                             00040000
//EHRMAN   DD   DSN=&HLQ..EHRMAN.UNLOAD,DISP=(OLD,DELETE,DELETE)        00050001
//*                                                                     00060000
//BXAUNLD  EXEC PGM=BXAUNLD,PARM='EHRMAN'                               00070000
//SYSUT1   DD   DSN=&HLQ..EHRMAN.PROD.ASM,DISP=OLD                      00080000
//SYSUT2   DD   DSN=&HLQ..EHRMAN.UNLOAD,DISP=(NEW,CATLG,CATLG),         00090000
//             SPACE=(TRK,(10,10),RLSE),UNIT=SYSALLDA,                  00100000
//             DCB=(LRECL=80,BLKSIZE=27920,RECFM=FB)                    00110000
