//BLDMAPS  JOB (7355,710,&SYSUID),'Build Loadmod',NOTIFY=&SYSUID,       00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//BXAPROCS JCLLIB ORDER=(&HLQ..GOODIES.TEST.PROCLIB,                    00020000
//             &HLQ..GOODIES.PROD.PROCLIB)                              00030000
//*                                                                     00040000
//* Create objects and loadmod                                          00050000
//ASMMAPS  EXEC BXAASM,MEMB=BXAMAPS,PROJ=GOODIES,LVL=PROD               00060000
//ASMPROD.SYSLIB DD                                                     00070000
//         DD                                                           00080000
//         DD                                                           00090000
//         DD                                                           00100000
//         DD   DSN=&HLQ..BIXXAMS.PROD.MACLIB,DISP=SHR                  00110000
//         DD   DSN=&HLQ..BIXXAMS.PROD.MACLIB,DISP=SHR                  00120000
//LKDMAPS  EXEC BXALKED,MEMB=BXAMAPS,PROJ=GOODIES,LVL=PROD              00130000
