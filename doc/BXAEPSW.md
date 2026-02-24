# BXAEPSW macro

Extract current PSW

## Syntax

``` hlasm
&LABEL   BXAEPSW &REG                  * Register set to be used
```

## REG

specifies an even register. The PSW will be placed in registers &REG and &REG+1.
