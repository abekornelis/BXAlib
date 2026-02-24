//BXAASMA  PROC MEMB=,PROJ=,LVL=                                        00010000
//*                                                                     00011000
//* Assembler for CRTxxxxx jobs                                         00011106
//*                                                                     00011206
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00012000
//*                                                                     00020000
//* Invoke assembler, using default parms for PROD                      00030000
//*                                                                     00040000
//ASM      EXEC PGM=ASMA90,PARM=(OBJECT,NODECK,TERM,                    00050000
//             'SYSPARM(SRLIST,NODBG,OPT)')                             00060000
//*             Primary input: assembly source code                     00070000
//SYSIN    DD   DSN=&HLQ..&PROJ..&LVL..ASM(&MEMB),DISP=SHR              00080001
//*             Macro libraries                                         00090000
//SYSLIB   DD   DSN=SYS1.MACLIB,DISP=SHR                                00100000
//         DD   DSN=SYS1.MODGEN,DISP=SHR                                00110000
//         DD   DSN=&HLQ..ASMPLUS.&LVL..MACLIB,DISP=SHR                 00130005
//         DD   DSN=&HLQ..&PROJ..&LVL..MACLIB,DISP=SHR                  00150005
//*             Assembler temp work dataset                             00160000
//SYSUT1   DD   DSN=&&SYSUT1,SPACE=(4096,(256,256),,,ROUND),            00170000
//             UNIT=VIO,DCB=BUFNO=1                                     00180000
//*             Listing data set                                        00190000
//SYSPRINT DD   DSN=&HLQ..&PROJ..&LVL..ASM.LIST(&MEMB),DISP=SHR         00200001
//*             Terminal listing data set                               00210000
//SYSTERM  DD   SYSOUT=*                                                00220000
//*             Deck output data set                                    00230000
//SYSPUNCH DD   DUMMY                                                   00240000
//*             Object output data set                                  00250000
//SYSLIN   DD   DSN=&HLQ..&PROJ..&LVL..OBJ(&MEMB),DISP=SHR              00260001
//*                                                                     00290003
//         PEND                                                         00300003
