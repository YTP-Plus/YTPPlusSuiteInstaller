;modified from http://forums.winamp.com/showthread.php?t=325143

!define CreateJunction "!insertmacro CreateJunction"

Function CreateJunction
  Exch $4
  Exch
  Exch $5
  Push $1
  Push $2
  Push $3
  Push $6
  CreateDirectory "$5"
  System::Call "kernel32::CreateFileW(w `$5`, i 0x40000000, i 0, i 0, i 3, i 0x02200000, i 0) i .r6"

  ${If} $0 = "-1"
    StrCpy $0 "0"
    RMDir "$5" 
    goto create_junction_end  
  ${EndIf}
  
  CreateDirectory "$4"  ; Windows XP requires that the destination exists
  StrCpy $4 "\??\$4"
  StrLen $0 $4
  IntOp $0 $0 * 2  
  IntOp $1 $0 + 2
  IntOp $2 $1 + 10
  IntOp $3 $1 + 18
  System::Call "*(i 0xA0000003, &i4 $2, &i2 0, &i2 $0, &i2 $1, &i2 0, &w$1 `$4`, &i2 0)i.r2"
  System::Call "kernel32::DeviceIoControl(i r6, i 0x900A4, i r2, i r3, i 0, i 0, *i r4r4, i 0) i.r0"
  System::Call "kernel32::CloseHandle(i r6) i.r1"

  ${If} $0 == "0"
    RMDir "$5"  
  ${EndIf}
  
  create_junction_end:
  Pop $6
  Pop $3
  Pop $2
  Pop $1
  Pop $5
  Pop $4        
FunctionEnd

!macro CreateJunction Junction Target
  Push $0
  Push "${Junction}"
  Push "${Target}"
  Call CreateJunction
  Pop $0
!macroend
