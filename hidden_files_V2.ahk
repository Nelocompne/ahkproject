#Requires AutoHotkey v2.0

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

Value := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "Hidden")

If (Value=1)
  Value := 2
Else
  Value := 1

vValue := Value - 1

RegWrite Value, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "Hidden"
RegWrite vValue, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\", "ShowSuperHidden"

PostMessage 0x111, 0x7103, 0,  ,"A"
Return
