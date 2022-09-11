#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

ConfFile := A_Args[1]
URL := A_Args[2]
Run yt-dlp --config-location %ConfFile% %URL%
