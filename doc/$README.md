# How to get started

This maclib constitutes a programming environment. Its most 
important elements are the structured programming macros.

You should start your program with the PGM macro, it builds the
environment that all the other macros need to function properly.

To indicate you agree with the license conditions, you have to
include in your sysparm (on the assembler invocation)
`LICENSE=GPL2.0,LICSTAT=IAGREE`
in addition to any other assembly-time parms you may want to pass.

The PGM macro is paired with the END macro, which not only
ends your program and assembly, but also produces a cross reference
of all subroutine invocations.

Subroutines are defined using the BEGSR / ENDSR macros
and invoked using the EXSR macro. <br />
This is an RPG-like style. If you prefer another style, 
you should change or encapsulate the macros according to your taste.

The DCL macro allows you to declare bit fields explicitly.
It also supports coded-value fields.<br />
Use the SETON/SETOF macros to turn bit field on/off using only
the name of the bit. The byte location of the bit need not be 
mentioned explicitly.<br />
Use the SET macro to set a code by its value name.
Again, the location of the value field need not be specified.<br />
DCL can also be used to embed control blocks in a nested structure

If you want the named-bit and named-value facilities for fields
defined in a macro external to the BXA environment (e.g. IBM-supplied)
macros, the use the DCOVR/DSOVR macros. Examples are in the MAPxxxxx
macros supplied in this library.

Another feature of the Bixoft eXtended Assembly language is its
support for dynamically (at assembly-time, that is) allocating
registers. You can use the EQUREG macro to have an available
register assigned. You can indicate whether you need a single reg
or a register pair. The macro uses info from prior USING/DROP
and POP/PUSH invocations to determine which register(s) are eligible.
You can use the USE macro to declare a register in use, even when
it is not addressing any specific area in your program.

Every macro has a short commentary section explaining its purpose
and the syntactical details of how to invoke the macro.

The library can be used with any assembler product:
HLASM, Dignus, Tachyon, z390.

I hope you'll enjoy this library and wish you happy programming.
Abe Kornelis.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.