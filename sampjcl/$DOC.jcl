//*                                                                     00010000
//* This JCL library contains the following members:                    00020000
//* ASMxxxxx will assemble source BXAxxxxx and link it into the         00030000
//*          load modules where it belongs                              00040000
//* BLDxxxxx will link load module BXAxxxxx after assembling            00050000
//*          all sources that go into it                                00060000
//* CRTxxxxx will create a load module required by the BLDxxxxx         00070000
//*          jobs                                                       00080000
//* LKDxxxxx will link load module BXAxxxxx                             00090000
//*                                                                     00100000
//* Special members:                                                    00110000
//* $DOC     this member                                                00120000
//* BLDALL   will submit all BLDxxxxx jobs to create the complete       00130000
//*          OBJ lib and all load modules for the GOODIES.PROD libs     00140000
//* TSTxxxxx will run the various test programs                         00150000
//*                                                                     00160000
