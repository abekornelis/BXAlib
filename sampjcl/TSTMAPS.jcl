//TSTMAPS  JOB (7355,710,&SYSUID),'Test Loadmod',NOTIFY=&SYSUID,        00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//JOBLIB   DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00020000
//BXAMAPS  EXEC PGM=BXAMAPS                                             00030000
//BXASNAP  DD   SYSOUT=*                                                00040000
//SYSUDUMP DD   SYSOUT=*                                                00050000
