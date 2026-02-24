//ASMUNLD  JOB (7355,710,&SYSUID),'Assemble Source',NOTIFY=&SYSUID,     00010000
//             CLASS=5,MSGCLASS=T,MSGLEVEL=(1,1),REGION=0M              00011000
//*                                                                     00012000
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00013000
//*                                                                     00014000
//BXAPROCS JCLLIB ORDER=(&HLQ..GOODIES.TEST.PROCLIB,                    00020000
//             &HLQ..GOODIES.PROD.PROCLIB)                              00030000
//*                                                                     00040000
//*             Invoke assembler                                        00050000
//ASMUNLD  EXEC BXAASM,MEMB=BXAUNLD,PROJ=GOODIES,LVL=PROD               00060000
//*                                                                     00070000
//* Compile ok? Invoke linkage editor                                   00080000
//         IF   (ASMUNLD.ASMPROD.RC LT 4) THEN                          00090000
//LNKUNLD  EXEC BXALKED,MEMB=BXAUNLD,PROJ=GOODIES,LVL=PROD              00100000
//         ENDIF                                                        00110000
