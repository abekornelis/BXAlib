//BLDALL   JOB (7355,710,&SYSUID),'Build GOODIES',NOTIFY=&SYSUID,       00010001
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//BXAPROCS JCLLIB ORDER=(&HLQ..GOODIES.TEST.PROCLIB,                    00020000
//             &HLQ..GOODIES.PROD.PROCLIB)                              00030000
//*                                                                     00040000
//* Submit build-jobs for all GOODIES.PROD loadmods                     00050000
//* DO need to submit CRT-jobs first: these loadmods might not yet      00060000
//*    exist in the GOODIES.PROD environment                            00070000
//* DO make sure the JOB cards specify a class with only 1 initiator!   00071000
//*                                                                     00072000
//SUBMIT   EXEC PGM=IKJEFT1A                                            00080000
//SYSTSPRT DD   SYSOUT=*                                                00090000
//SYSTSIN  DD   *                                                       00100000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(CRTCOPY)'               00110000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(CRTTEST)'               00120000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(BLDIO)'                 00130000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(BLDIO00)'               00140000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(BLDLOWPG)'              00150000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(BLDMAPS)'               00160000
           SUBMIT 'TCL2KOR.BXA.GOODIES.PROD.JCL(BLDUNLD)'               00170000
/*                                                                      00180000
