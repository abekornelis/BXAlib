# Strong Types

Strong types in assembler language - that may seem strange.

But it's not - other languages use strong typing to *restrict* what one can do with a field or variable.

In Bixoft eXtended Assembly language we try not to restrict, but rather *augment* function.
Strong typing is is used to provide the programmer with warning messages when doing something 'unusual'.

It is also used to generate correct code when moving or comparing fields of different types.
The purpose is not to restrict the programmer, but rather to make the life of the programmer easier.

## Bit type

The bit type is not available in High Level Assembler.
Instead we define a flag byte with `DC` or `DS`, then define the bit masks using `EQU`.

To define a bit field in Bixoft eXtended Assembly language,
we use the [DCL macro](DCL.md) like this:
``` hlasm
DUCESTAT DCL   *BITS,                  * Status bits                   *
               DUCECAT,                * 0: dataset is cataloged       *
               DUCEPDS,                * 1: dataset is a pds(e) member *
               DUCEIN,                 * 2: dataset is open for input  *
               DUCEOUT                 * 3: dataset is open for out/upd
```

To set or reset individual bits, you can use the [SET macro](SET.md) and the 
[RESET macro](RESET.md).

Then, to test the bit value, the code need not explicitly refer to the field
where the bit is located. That information is implicit. However, when you are using
labelled USINGs, you can still prefix the bit name with the appropriate label.

For example, in the following snippet, IDCB is defined as a USING label,
and the `IF` statement tests `IDCB.DCBOFOPN` - no need to remember the name of
the field that holds the DCBOFOPN flag bit.
``` hlasm
* Assign DCB pointer
R_DCB    EQUREG ,                      * Assign ptr to DCB
IDCB     USING DCB,R_DCB               * Set DCB addressable
         CPY   R_DCB,DAPLIDCB          * Point to internal DCB
         IF    IDCB.DCBOFOPN           * DCB already open?
         ...                           * Code to resume open DCB
         ELSE  ,                       * DCB not open yet
         ...                           * Code to open the DCB
         ENDIF ,                       *
```

*Notes:*
1. misremembering the field name is a common source of error - and hard to find on top of that.
2. having to look up the field name - to make sure you got the right one - is avoidable time loss.
3. the [EQUREG macro](EQUREG.md) allocates an available register and creates a register `EQU` for it.
   Therefore, the register number assigned to R_DCB depends on what registers are in use/available.

## Coded value type

Another frequently used field type that is not natively supported by the assemler
is the coded value field. A typical example are the verb codes used with `DYNALLOC`.
Or order status in an application managing sales (or purchase) orders.

Defined codes are typically declared as `EQU` statements - not tied to the storage field
that they logically belong to.

To define a coded vaqlue field in Bixoft eXtended Assembly language,
we use the [DCL macro](DCL.md) like this:
``` hlasm
BDSPLFUN DCL   *CODE,XL1,              * Function code field           *
               (BDSPLALC,1),           * 1 = allocate                  *
               BDSPLDAL                * 2 = de-allocate
```

To set or reset athe applicable value , you can use the [SET macro](SET.md).

Then, to test the actual value, the code need not explicitly refer to the field
where the value is located. That information is implicit. However, when you are using
labelled USINGs, you can still prefix the value name with the appropriate label.

For example, in the following snippet, IN is defined as a USING label,
covering an input parameter list. The `IF` statement tests `IN.BDSPLALC` - no need to remember the name of
the field that holds the BDSPLALC code value.

``` hlasm
* Return pointer to caller.
         IF    IN.BDSPLALC,            * Allocated something?          *
               AND,R15,LT,8            * And allocation was ok?
          CPY  R1,IN.BDSPLPTR          * Load ptr to allocated block
          CPY  AR1,AR_BDS              * Which is in the dataspace
         ELSE  ,                       * Otherwise
          CLEAR (R1,AR1)               * Set return ptr to zero
         ENDIF ,                       *
         DROP  IN                      * Input parmlist done now
```

## Conditions

The code generated for a comparison (as used in the [IF macro](IF.md)
caters to differences in format and length. This applies to the following macros:
- [IF](IF.md)
- [CASE](CASE.md)
- [DO UNTIL](DO.md); [DO WHILE](DO.md)
- [LOOP](LOOP.md)
- [LEAVE](LEAVE.md)
- [GOTO](GOTO.md)
- [EXSR](EXSR.md)

Yes, indeed: all of these macros - even GOTO and EXSR (EXecute SubRoutine) - can be coded with
any of the 9 condition syntaxes supported by the IF macro.

## Copying data

Our programs move (or rather: copy) data items all the time.
From register to storage, or vice versa, from one storage location to another, etc.

The format and length of fields matters. Bixoft eXtended Assembly language
provides the [CPY macro](CPY.md) that generates the right code sequence for whichever
source and target types.

The programmer retains the option of copying data in different ways: use of CPY is optional.

## Declaring fields

Supported field types are documented with the [EQU macro](EQU.md).

## Overriding vendor definitions

When using IBM-supplied mapping macros, or other mapping macros that you cannot easily change,
the Bixoft-defined types cannot normally be implemented.

To circumvent this problem the library contains [DC](DC.md), [DS](DS.md), and [EQU](EQU.md) replacement macros.
They are supplemented by [DCOVR](DCOVR.md), [DSOVR](DSOVR.md) and [EQUOVR](EQUOVR.md)macros.
These allow you to create overrides for the definitions supplied in the standard mapping macro.

The overrides allow you to redefine field types, tie flag equates to the associated flag byte's label,
and tie defined values to the coded value field they relate to.

The BXA macro library contains over a 100 examples of MAP\* macros. They all follow a comparable structure.
Check some of them and let yourself be inspired to create your own.

There's a [list by macro]($INDEX.md#Mappings-and-overrides) and a [list by control block acronym]($DOC.md#Control-blocks-available-for-DCL).

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.