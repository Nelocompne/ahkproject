
MODSDIR := A_ScriptDir "\addr\"
SAVEDIR := A_ScriptDir "\adds\" 
INIFILE := SAVEDIR "list.txt"

Loop read, INIFILE
{
    Loop parse, A_LoopReadLine, "`n", "`r"
    {
        objs := MODSDIR A_LoopField
        FileMove objs, SAVEDIR
    }
}

Loop read, INIFILE
    {
        Loop parse, A_LoopReadLine, "`n", "`r"
        {
            objs := SAVEDIR A_LoopField
            FileMove objs, MODSDIR
        }
    }
