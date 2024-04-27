#Requires AutoHotkey v1.0

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
;@Ahk2Exe-SetMainIcon clash.ico

MsgBox, , , 启动初始化中, 0.5
FileCreateDir, config
FileCreateDir, assts
FileCreateDir, core
FileCreateDir, sysproxy
FileInstall, core\clash.exe, core\clash.exe
FileInstall, core\experimental.exe, core\experimental.exe
FileInstall, core\meta.exe, core\meta.exe
FileInstall, core\premium.exe, core\premium.exe
FileInstall, config\config.yaml, config\config.yaml
MsgBox, , , 下载资源文件, 0.5
UrlDownloadToFile, https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb, config\Country.mmdb
MsgBox, , , 资源文件下载完成, 0.5
FileInstall, assts\cdn.png, assts\cdn.png
FileInstall, assts\logo.png, assts\logo.png
FileInstall, assts\Meta.png, assts\Meta.png
FileInstall, sysproxy\SwitchProxy.exe, sysproxy\SwitchProxy.exe
MsgBox, , , 初始化完成, 0.5

clash = core\clash.exe
experimental = core\experimental.exe
Meta = core\meta.exe
premium = core\premium.exe
dir = config

Menu, Tray, Icon, clash.ico
Gui, Add, Picture, x511 y93 w230 h230 , assts\logo.png
Gui, Add, Picture, x415 y84 w115 h105 , assts\Meta.png
Gui, Add, Picture, x376 y199 w163 h163 , assts\cdn.png
Gui, Add, GroupBox, x31 y16 w326 h230 , 第一步 选择启动内核
Gui, Add, Button, x60 y55 w86 h28 , clash
Gui, Add, Text, x175 y55 w172 h28 , 原版内核（开源）`n不支持：TUN，Rule Provider
Gui, Add, Button, x60 y103 w86 h28 , premium
Gui, Add, Text, x175 y103 w182 h38 , 原版内核（闭源）`n支持：TUN，Rule Provider
Gui, Add, Button, x60 y151 w86 h28 , experimental
Gui, Add, Text, x175 y151 w172 h38 , 官方fork内核（开源）`n支持：Rule Provider`n不支持：TUN
Gui, Add, Button, x60 y199 w86 h28 , meta
Gui, Add, Text, x175 y199 w192 h38 , Meta版fork内核（开源）`n支持：TUN，Rule Provider`n扩展：Xray-core
Gui, Add, GroupBox, x21 y247 w336 h153 , 第二步 管理系统代理
Gui, Add, Button, x213 y276 w76 h28 , web
Gui, Add, Text, x108 y266 w105 h48 +Left, 打开web控制面板`n地址：127.0.0.1`n端口：8787`n密钥：123456
Gui, Add, Text, x194 y343 w124 h28 , 代理监听端口：8765
Gui, Add, Button, x88 y324 w86 h28 , 配置系统代理
Gui, Add, Button, x88 y362 w86 h28 , 清除系统代理

Gui, Show, w748 h433, Clash多内核启动器 v0.2
return

Buttonclash:
    Run, %clash% -d %dir%
return
Buttonpremium:
    Run, %premium% -d %dir%
return
Buttonexperimental:
    Run, %experimental% -d %dir%
return
Buttonmeta:
    Run, %Meta% -d %dir%
return
Buttonweb:
    Run, https://clash.razord.top/
return
Button配置系统代理:
    Run, sysproxy\SwitchProxy.exe
return
Button清除系统代理:
    Run, sysproxy\SwitchProxy.exe
return

GuiClose:
ExitApp