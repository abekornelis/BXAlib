# SET macro

Turn on a value in a code field                                      

## Syntax format 1

``` hlasm
&LABEL   SET   &CODE                   * Name of code to be SET         
.*                                     * More codes are in SYSLIST      
```

## Syntax format 2

``` hlasm
&LABEL   SET   &FLD1,&FLD2
```

## CODE

specifies the name of a DCL-declared code value. Any number of 
arguments may follow, but they all have to be DCL-declared     
value names too.                                               

## FLD1

Name of an A-type or V-type field                              

## FLD2

Name of a field, or a register                                 

## Macro code

The [SET macro](../bxamac/SET.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.