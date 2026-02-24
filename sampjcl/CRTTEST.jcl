//CRTTEST  JOB (7355,710,&SYSUID),'Create Initial',NOTIFY=&SYSUID,      00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//BXAPROCS JCLLIB ORDER=(&HLQ..GOODIES.TEST.PROCLIB,                    00020000
//             &HLQ..GOODIES.PROD.PROCLIB)                              00030000
//*                                                                     00040000
//* Create object and loadmod for BX8TEST                               00050000
//ASMTEST  EXEC BXAASMA,MEMB=BXATEST,PROJ=GOODIES,LVL=PROD              00060000
//LKDTEST  EXEC BXAIEWL,MEMB=BXATEST,PROJ=GOODIES,LVL=PROD              00070000
