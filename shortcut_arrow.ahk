#Requires AutoHotkey v2.0
; 快捷方式小箭头去除、恢复，测试win7/10通过。

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}


if (A_Is64bitOS)
    OS_is := "64"
else
    OS_is := "32"

SetRegView OS_is

TestValue := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons", "29", 0)

if (TestValue = "C:\Windows\system32\imageres.dll`,197")
  RegDelete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons\", "29"
Else
  RegWrite "C:\Windows\system32\imageres.dll`,197", "REG_SZ", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons\", "29"
ProcessClose "explorer.exe"
Return
