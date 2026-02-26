# INC macro

Increment a register

## Syntax

``` hlasm
&LABEL   INC   &REG,                   * Register to be incremented    *
               &COUNT                  * Amount to increment
```

## REG

specifies the register to be incremented

## COUNT

specifies the amount by which the register is to be
incremented. May be specified as:
- Literal or symbolic value: must evaluate to a value between 0 and 4095 inclusive.
- (reg): must specify a valid register, 0 not allowed
- (value,reg): both of the above apply
- nothing: defaults to 1

## Macro code

The [INC macro](../bxamac/INC.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.