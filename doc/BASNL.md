# BASNL macro

Branch and Save on Not-Low condition

## Syntax

``` hlasm
&LABEL   BASNL &REG,                   * Register for return address   *00200000
               &LOC,                   * Branch target or (reg)        *00210000
               &TYPE=LOCAL             *                                00220000
```