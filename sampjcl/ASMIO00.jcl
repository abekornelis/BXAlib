//ASMIO00  JOB (7355,710,&SYSUID),'Assemble Source',NOTIFY=&SYSUID,     00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//BXAPROCS JCLLIB ORDER=(&HLQ..GOODIES.TEST.PROCLIB,                    00020000
//             &HLQ..GOODIES.PROD.PROCLIB)                              00030000
//*                                                                     00040000
//*             Invoke assembler                                        00050000
//ASMIO00  EXEC BXAASM,MEMB=BXAIO00,PROJ=GOODIES,LVL=PROD,              00060000
//             PARM.ASMPROD=(OBJECT,NODECK,TERM,                        00070000
//             'SYSPARM(NODEBUG,OPT)')                                  00071000
//*                                                                     00080000
//* Compile ok? Invoke linkage editor                                   00090000
//         IF   (ASMIO00.ASMPROD.RC LT 4) THEN                          00100000
//LNKIO00  EXEC BXALKED,MEMB=BXAIO00,PROJ=GOODIES,LVL=PROD              00110000
//         ENDIF                                                        00120000
