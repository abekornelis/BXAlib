# CPY macro

Copy a field - register or storage                                   

- For oversized packed fields unpacking may be done by processing 
  left to right in clusters of several bytes at a time.            
- For oversized zoned fields packing may be done by processing         
  right to left in a loop.                                         
- For every EQUREG a check must be made whether the source and/or      
  destination registers are in USE. Change EQUREG with a
  NO=(...) keyword.                                                

## Syntax

``` hlasm
&LABEL   CPY   &TO,                    * Destination field             *
               &FROM,                  * Source field                  *
               &WARN                   * NOWARN or nothing              
```

## TO

specifies the field or register to be filled,                 
- or (field,length)     to override the length of the field        
- or (reg,end_reg_name) to copy to a set of registers              
- or (reg,nr_of_regs)   to copy to a set of registers              
- or (gpr_name,ar_name) to copy to 1 or more GPR/AR pairs          
- or ((gpr),len)        to copy to a register-designated area      
- or ((gpr),(gpr))      to copy to a register-designated area      

## FROM

specifies the field or register to be copied,                 
- or (field,length)     to override the length of the field        
- or (reg,nr_of_regs)   to copy from a set of registers            
- or (reg,end_reg_name) to copy from a set of registers            
- or (gpr_name,ar_name) to copy from 1 or more GPR/AR pairs        
- or ((gpr),len)        to copy from a register-designated area    
- or ((gpr),(gpr))      to copy from a register-designated area    
- or `*STACK`           to retrieve registers from the stack       

## WARN

specifies whether or not a warning is to be issued if         
&TO and &FROM designate the same field/register               

## Macro code

The [CPY macro](../bxamac/CPY.mac) is in the BXAmac folder.

=======

(C) Copyright 1999-2026 Abe Kornelis. All rights reserved.