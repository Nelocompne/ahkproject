; http://thinkai.net/p/726
#Requires AutoHotkey v1.0

mac := RegExReplace(GetMacAddress(),"-",":")
 
;检查配置文件
IfExist, %A_ScriptDir%\ipinfo.ini
{
    IniRead, ip, %A_ScriptDir%\ipinfo.ini, ipinfo, ip
    IniRead, netmask, %A_ScriptDir%\ipinfo.ini, ipinfo, netmask
    IniRead, gateway, %A_ScriptDir%\ipinfo.ini, ipinfo, gateway
    IniRead, dns, %A_ScriptDir%\ipinfo.ini, ipinfo, dns
}
else
{
    MsgBox, 4112, 错误, %A_ScriptDir%\ipinfo.ini 文件不存在，已生成，请修改后再使用！
    IniWrite, ip, %A_ScriptDir%\ipinfo.ini, ipinfo, ip
    IniWrite, 子网掩码, %A_ScriptDir%\ipinfo.ini, ipinfo, netmask
    IniWrite, 默认网关, %A_ScriptDir%\ipinfo.ini, ipinfo, gateway
    IniWrite, dns, %A_ScriptDir%\ipinfo.ini, ipinfo, dns
    ExitApp
}
 
adaptors := GetAdaptors() ;获取网卡列表
for id,adaptor in adaptors
{
    if(adaptor.mac = mac)
    {
        name := adaptor.name
        Runwait, %ComSpec% /c netsh interface ip set address name=`"%name%`" source=static addr=%ip% mask=%netmask% gateway=%gateway% gwmetric=1, , Hide
        RunWait, %ComSpec% /c netsh interface ip set dns name=`"%name%`" source=static addr=%dns%, ,Hide
    }
}
 
 
GetAdaptors(){
    adaptors := {}
    ipconfig := cmd("ipconfig /all") ;cmd方式兼容XP
    lines := StrSplit(ipconfig,"`n","`r")
    aid = 0
    for id,line in Lines
    {
        if (!RegExMatch(line,"^\s*$"))
        {
            if RegExMatch(line, "^.*(适配器|adapter)\s([^\s].*):$", mn)
            {
                aid++
                adaptors[aid] := {}
                adaptors[aid].name := mn2
            }
            Else
            {
                if RegExMatch(line, "^.*(物理地址|Physical Address).*:\s(\w{2})-(\w{2})-(\w{2})-(\w{2})-(\w{2})-(\w{2})$", mm)
                    adaptors[aid].mac := mm2 ":" mm3 ":" mm4 ":" mm5 ":" mm6 ":" mm7
            }
        }
    }
    return adaptors
}
 
GetMacAddress(){ ;获取当前活动网卡MAC
    res := cmd("getmac /NH")
    RegExMatch(res, ".*?([0-9A-Z].{16})(?!\w\\Device)", mac)
    return %mac1%
}
 
 
cmd(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )
 
            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )
 
    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )
 
    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    While ( 1 )
    { ; Before reading, we check if the pipe has been written to, so we avoid freezings.
        If ( !DllCall( "PeekNamedPipe", Ptr,hStdOutRd, Ptr,0, UInt,0, Ptr,0, UIntP,nTot, Ptr,0 ) )
            Break
        If ( !nTot )
        { ; If the pipe buffer is empty, sleep and continue checking.
            Sleep, 100
            Continue
        } ; Pipe buffer is not empty, so we can read it.
        VarSetCapacity(sTemp, nTot+1)
        DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,nTot, PtrP,nSize, Ptr,0 )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
    }
 
    ; * SKAN has managed the exit code through SetLastError.
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
}