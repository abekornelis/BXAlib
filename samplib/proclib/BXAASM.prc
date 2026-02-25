//BXAASM   PROC MEMB=,PROJ=,LVL=                                        00010000
//*                                                                     00020000
//* Assembler                                                           00020106
//*                                                                     00020206
//         SET  HLQ=TCL2KOR.BXA          High Level Qualifiers          00021001
//*                                                                     00022001
//* Test-level assembly?                                                00023001
//TEST     EXEC PGM=BXATEST,PARM='&LVL EQ TEST'                         00030000
//STEPLIB  DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00040001
//*                                                                     00050000
//* Prod-level assembly?                                                00051001
//PROD     EXEC PGM=BXATEST,PARM='&LVL EQ PROD'                         00060000
//STEPLIB  DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00070001
//*                                                                     00080000
//* Copy source member to be used                                       00090000
//*                                                                     00100000
//COPY     EXEC PGM=BXACOPY,PARM='MEMBER=&MEMB'                         00110000
//STEPLIB  DD   DSN=&HLQ..GOODIES.PROD.LINKLIB,DISP=SHR                 00120003
//INPUT    DD   DSN=&HLQ..&PROJ..&LVL..ASM,DISP=SHR                     00130001
//         DD   DSN=&HLQ..&PROJ..PROD.ASM,DISP=SHR                      00140002
//OUTPUT   DD   SPACE=(TRK,(10,10,1),RLSE),DISP=(NEW,PASS,DELETE),      00150000
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920),                   00160000
//             DSN=&&ASM(&MEMB),UNIT=SYSALLDA                           00170004
//*                                                                     00180000
//* Invoke assembler, using default parms for TEST                      00190000
//*                                                                     00200000
//         IF   (TEST.RC = 0) THEN                                      00210000
//ASMTEST  EXEC PGM=ASMA90,PARM=(OBJECT,NODECK,TERM,                    00220005
//             'SYSPARM(SRLIST,DBG,OPT)')                               00230000
//*             Primary input: assembly source code                     00240000
//SYSIN    DD   DSN=&&ASM(&MEMB),DISP=(OLD,DELETE,DELETE)               00250000
//*             Macro libraries                                         00260000
//SYSLIB   DD   DSN=SYS1.MACLIB,DISP=SHR                                00270000
//         DD   DSN=SYS1.MODGEN,DISP=SHR                                00280000
//         DD   DSN=&HLQ..ASMPLUS.&LVL..MACLIB,DISP=SHR                 00290001
//         DD   DSN=&HLQ..ASMPLUS.PROD.MACLIB,DISP=SHR                  00300001
//         DD   DSN=&HLQ..&PROJ..&LVL..MACLIB,DISP=SHR                  00310001
//         DD   DSN=&HLQ..&PROJ..PROD.MACLIB,DISP=SHR                   00320001
//*             Assembler temp work dataset                             00330000
//SYSUT1   DD   DSN=&&SYSUT1,SPACE=(4096,(256,256),,,ROUND),            00340000
//             UNIT=VIO,DCB=BUFNO=1                                     00350000
//*             Listing data set                                        00360000
//SYSPRINT DD   DSN=&HLQ..&PROJ..&LVL..ASM.LIST(&MEMB),DISP=SHR         00370001
//*             Terminal listing data set                               00380000
//SYSTERM  DD   SYSOUT=*                                                00390000
//*             Deck output data set                                    00400000
//SYSPUNCH DD   DUMMY                                                   00410000
//*             Object output data set                                  00420000
//SYSLIN   DD   DSN=&HLQ..&PROJ..&LVL..OBJ(&MEMB),DISP=SHR              00430001
//*                                                                     00440000
//         ENDIF                                                        00450000
//*                                                                     00460000
//* Invoke assembler, using default parms for PROD                      00470000
//*                                                                     00480000
//         IF   (PROD.RC = 0) THEN                                      00490000
//ASMPROD  EXEC PGM=ASMA90,PARM=(OBJECT,NODECK,TERM,                    00500005
//             'SYSPARM(SRLIST,NODBG,OPT)')                             00510000
//*             Primary input: assembly source code                     00520000
//SYSIN    DD   DSN=&&ASM(&MEMB),DISP=(OLD,DELETE,DELETE)               00530000
//*             Macro libraries                                         00540000
//SYSLIB   DD   DSN=SYS1.MACLIB,DISP=SHR                                00550000
//         DD   DSN=SYS1.MODGEN,DISP=SHR                                00560000
//         DD   DSN=&HLQ..ASMPLUS.PROD.MACLIB,DISP=SHR                  00570001
//         DD   DSN=&HLQ..&PROJ..PROD.MACLIB,DISP=SHR                   00580001
//*             Assembler temp work dataset                             00590000
//SYSUT1   DD   DSN=&&SYSUT1,SPACE=(4096,(256,256),,,ROUND),            00600000
//             UNIT=VIO,DCB=BUFNO=1                                     00610000
//*             Listing data set                                        00620000
//SYSPRINT DD   DSN=&HLQ..&PROJ..PROD.ASM.LIST(&MEMB),DISP=SHR          00630001
//*             Terminal listing data set                               00640000
//SYSTERM  DD   SYSOUT=*                                                00650000
//*             Deck output data set                                    00660000
//SYSPUNCH DD   DUMMY                                                   00670000
//*             Object output data set                                  00680000
//SYSLIN   DD   DSN=&HLQ..&PROJ..PROD.OBJ(&MEMB),DISP=SHR               00690001
//*                                                                     00700000
//         ENDIF                                                        00710000
//*                                                                     00720000
//         PEND                                                         00730000
