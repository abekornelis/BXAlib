# USE macro

This macro extends the functionality of the normal USING statement.
It sets up USING statements with labeled dependent USINGs
for all of its DCL-declared subfields. And it allows registers to be declared
in use even when not addressing an area of storage.

- May either specify a 'normal' USE statement, which has either the
  lay-out of a labeled or unlabeled USING, or the lay-out of a
  labeled or unlabeled dependent USING.
- May also specify a 'register' USE statement, which has no label and
  specifies only a register.
- May also specify an 'automatic' USE statement, in which case
  only the label and the field to be set addressable are
  supplied. A labeled dependent USING will be generated. The
  field to be set addressable is identified by supplying the
  DSECT-name and the field-name within that DSECT, separated by a
  period.

*Note:* Automatically generated USE-statements for sub-structures are
always normal USE-statements. Automatic USE-statements therefore
are never generated automatically. An automatic USE-statement
generates its own normal USE-statement automatically.

## Syntax

``` hlasm
&LABEL   USE   &DSECT,                 * Control block name            *
               &BASE,                  * Register (or field) for using *
               &START=,                * 1st addressable field         *
               &OVR=,                  * Overriding labels             *
               &SCOPE=LOCAL            * LOCAL/CALLED
```

## LABEL

specifies a USING label, to be used on the main USING
generated to establish addressability to `&DSECT`

## DSECT

specifies the control block to be set addressable.
If specified as DSECTname.fieldname then a dependent using
for that field in the specified DSECT will be generated. The
label for the dependent using will be taken from the label
parm in the USE-statement. For this type of USE-statement
the parameters BASE, PRFX, START, and OVR are ignored.

## BASE

specifies either a register that points to `&DSECT` or a field
that contains a control block of type `&DSECT`.

## START

specifies the name of a field in the dsect, where
addressability starts. If omitted, defaults to the control
block name.

## OVR

specifies overriding labels as follows: `OVR=((field,label),(field,label)...)`

If the specified field is a DCL-declared structure, then the
specified label will override the USING-label specified on
the DCL-statement. If the label field is omitted, an
unlabeled dependent USING will be generated. If a `*NOUSE`
is specified for the overriding label, then no USING will
be generated for the specified field.

## SCOPE

specifies the scope of the USE-statement:
- LOCAL  - valid until DROPped
- CALLED - valid for all subroutines called from the remainder of this subroutine.

## Macro code

The [USE macro](../bxamac/USE.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.