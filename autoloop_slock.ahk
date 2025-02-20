#Requires AutoHotkey v2.0

; Ctrl+Alt+O 关闭脚本
^!o::
{
  ExitApp
}

; 检测传参，默认2分钟
if A_Args.Length < 1
{
    OUTTIME := '120000'
} else {
    OUTTIME := A_Args[1]
}

loop {
    ;Send "test"
    SetScrollLockState 1
    Sleep 300
    SetScrollLockState 0
    Sleep OUTTIME
}
