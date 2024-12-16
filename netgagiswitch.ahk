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

aa := InternetCheckConnection("http://www.baidu.com")

if (aa="1") {
  Run "netsh interface set interface name=`"本地连接`" admin=DISABLED"
  Run "netsh interface set interface name=`"以太网`" admin=DISABLED"
}else {
  Run "netsh interface set interface name=`"本地连接`" admin=ENABLED"
  Run "netsh interface set interface name=`"以太网`" admin=ENABLED"
}

; https://meta.appinn.net/t/topic/38058/5

InternetCheckConnection(Url) {
  return DllCall("Wininet.dll\InternetCheckConnectionW" , "Str",Url, "Int",1, "Int",0)
}