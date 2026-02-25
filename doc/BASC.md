# BASC macro

Branch and Save on condition

## Syntax

``` hlasm
&LABEL   BASC  &COND,                  * Condition                     *
               &REG,                   * Register for return address   *
               &DEST,                  * Destination address or (reg)  *
               &TYPE=LOCAL             * BAS/BASR                       
```