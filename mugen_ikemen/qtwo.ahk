#Requires AutoHotkey v2.0
SetWorkingDir A_InitialWorkingDir

CHAR := '"' A_Args[1] '"'
PLAYA := " -p1.ai 1 -p1 " CHAR
PLAYB := " -p2.ai 1 -p2 kfm"
;PLAYA := " -p1 " CHAR
;PLAYB := " -p2 kfmZ"
ikemenARGG := ' -time 100'

if FileExist("Ikemen_GO.exe"){
    BIN := "Ikemen_GO.exe"
    PLAYB := " -p2.ai 1 -p2 kfmZ"
}
else if FileExist("mugen.exe"){
    BIN := 'mugen.exe'
    ikemenARGG := ' '
}
else if FileExist("winmugen.exe"){
    BIN := 'winmugen.exe'
    ikemenARGG := ' '
}
else {
    MsgBox "no"
}

FIN := BIN PLAYA PLAYB ikemenARGG

;msgbox BIN
;msgbox PLAYA 
;msgbox PLAYB 
;msgbox ARGG
;msgbox FIN
RUN FIN