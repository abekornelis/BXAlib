# MVPL macro

Copy a parameter list from program storage to dynamic storage

## Syntax

``` hlasm
&LABEL   MVPL  &TO,                    * Destination                   *
               &FROM                   * Source
```

## TO

specifies the destination location label. No length should be specified.

## FROM

specifies the label of the prototype plist in the program.

## Macro code

The [MVPL macro](../bxamac/MVPL.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.