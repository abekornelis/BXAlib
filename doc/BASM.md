# BASM macro

- Branch and Save on Mixed condition
- Branch and Save on Minus condition

## Syntax

``` hlasm
&LABEL   BASM  &REG,                   * Register for return address   *
               &LOC,                   * Branch target or (reg)        *
               &TYPE=LOCAL             *                                
```