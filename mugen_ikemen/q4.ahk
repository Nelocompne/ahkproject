#Requires AutoHotkey v2.0

BIN := "1.1\Ikemen_GO.exe"
CHARA := '"' A_Args[1] '"'
CHARB := '"' A_Args[2] '"'
CHARC := '"' A_Args[3] '"'
CHARD := '"' A_Args[4] '"'

PLAYA := " -p1.ai 50 -p1 " CHARA
PLAYB := " -p2.ai 50 -p2 " CHARB
PLAYC := " -p3.ai 50 -p3 " CHARC
PLAYD := " -p4.ai 50 -p4 " CHARD
ARGG := ' -time 100 -rounds 1'

FIN := BIN PLAYA PLAYB PLAYC PLAYD ARGG

;msgbox BIN
;msgbox PLAYA 
;msgbox PLAYB 
;msgbox ARGG
;msgbox FIN
RUN FIN, "C:\1.1"