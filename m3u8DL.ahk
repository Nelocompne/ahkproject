#Requires AutoHotkey v1.0
#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

URL := A_Args[1]
Run N_m3u8DL-RE.exe --binary-merge --write-meta-json --check-segments-count False %URL%
