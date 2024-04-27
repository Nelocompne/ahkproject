#Requires AutoHotkey v1.0

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
;@Ahk2Exe-SetMainIcon clash.ico

MsgBox,,, 启动初始化中, 0.5
FileCreateDir, config
FileCreateDir, bin
FileInstall, clash.ico, clash.ico
FileInstall, bg.png, bg.png
FileInstall, config\config.yaml, config\config.yaml
MsgBox, , , 下载资源中, 0.5
UrlDownloadToFile, https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb, config\Country.mmdb
MsgBox, , , 资源下载完成, 0.5
;FileInstall, config\Country.mmdb, %A_ScriptDir%\config\Country.mmdb
FileInstall, bin\clash.exe, bin\clash.exe
FileInstall, bin\cm.exe, bin\cm.exe
FileInstall, bin\cp.exe, bin\cp.exe
FileInstall, bin\ec.exe, bin\ec.exe
MsgBox,,, 初始化完成, 0.5

Menu, Tray, Icon , clash.ico
Gui Font, s9, Segoe UI
Gui Add, Picture, x277 y-58 w851 h458 +BackgroundTrans , bg.png
Gui Add, Button, x946 y105 w76 h30, &启动
Gui Add, Link, x1028 y245 w120 h23, <a href="https://github.com/Dreamacro/clash">关于</a>
Gui Add, Radio, vC x74 y61 w120 h23 vC, Clash
Gui Add, Radio, vCP x226 y61 w120 h23 vCP, Clash Premium
Gui Add, Radio, vEC x378 y61 w120 h23 vEC, Experimental Clash
Gui Add, Radio, vMC x532 y61 w120 h23 vMC, Meta Clash
Gui Add, Button, x747 y105 w110 h30, &编辑配置文件
Gui Add, Text, x282 y184 w150 h23 +0x200 , 第一步：选择内核
Gui Add, Text, x42 y96 w132 h60 +0x400000 , Clash原版，开源，不支持TUN，不支持Rule Providers
Gui Add, Text, x203 y96 w132 h60 +0x400000 , Clash Premium版，非开源，支持TUN，支持Rule Providers
Gui Add, Text, x364 y96 w132 h60 +0x400000 , Clash实验版，开源，不支持TUN，支持Rule Providers
Gui Add, Text, x525 y96 w132 h60 +0x400000 , Meta版Clash，开源，支持TUN，支持Rule Providers，以及更多
Gui Add, Text, x735 y184 w176 h23 +0x200 , 第二步：编辑配置文件
Gui Add, Text, x950 y179 w94 h30 +0x200 , 最后：启动
Gui Add, Text, x919 y32 w124 h64, 启动后会出现一个黑色窗口进程，关闭这个黑色窗口则关闭Clash

Gui Show, w1077 h273, Clash 启动器 by Minn
Return

Button启动:
    Gui, Submit , NoHide
    if (C = 1) {
        Var = "%A_ScriptDir%\bin\clash.exe"
    }
    Else if (CP = 1) {
        Var = "%A_ScriptDir%\bin\cp.exe"
    }
    Else if (EC = 1) {
        Var = "%A_ScriptDir%\bin\ec.exe"
    }
    Else if (MC = 1) {
        Var = "%A_ScriptDir%\bin\cm.exe"
    }
    Else {
        MsgBox 未选择内核！
        return
    }
    Run, %comSpec% /k %Var% -d %A_ScriptDir%\config
    Run, https://clash.razord.top/#/proxies?host=127.0.0.1&port=9090
return

Button编辑配置文件:
    Run, notepad config\config.yaml
return

GuiEscape:
GuiClose:
ExitApp