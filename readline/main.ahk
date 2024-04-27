#Requires AutoHotkey v2.0

; 通过变量控制的目录位置，包括写法
MODSDIR := A_ScriptDir "\addr\"
SAVEDIR := A_ScriptDir "\adds\" 
INIFILE := SAVEDIR "list.txt"


; 读取文件，每行一个，每行一整个读取
; 从mods文件移动到本地文件
Loop read, INIFILE
{
    Loop parse, A_LoopReadLine, "`n", "`r"
    {
        objs := MODSDIR A_LoopField
        FileMove objs, SAVEDIR
    }
}

; 从本地文件移动到mods文件
Loop read, INIFILE
{
    Loop parse, A_LoopReadLine, "`n", "`r"
    {
        objs := SAVEDIR A_LoopField
        FileMove objs, MODSDIR
    }
}

; 读取文件，每行一个，然后将每行的第二个参数装进对象中，移动它
Loop read, INIFILE
{
    Loop parse, A_LoopReadLine, "`n", "`r"
    {
        word_array := StrSplit(A_LoopField, ",")
        objs := SAVEDIR word_array[2]
        FileMove objs, MODSDIR
    }
}



INIFILE := "list.txt"

Loop read, INIFILE
    {
        Loop parse, A_LoopReadLine, "`n", "`r"
        {
            word_array := StrSplit(A_LoopField, ",")
            if (word_array[1] = "modsdir" ) {
                MODSDIR := word_array[2]
                MsgBox "mods地址为: " MODSDIR
            }
            if (word_array[1] = "savedir") {
                SAVEDIR := word_array[2]
                MsgBox "本地目录地址为: " SAVEDIR
            } else {
                objs := word_array[2]
                MsgBox MODSDIR "\" objs
            }
        }
    }
