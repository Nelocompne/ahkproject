DirName := A_ScriptDir          ; Папка для слежения.
LogFile := A_Desktop . "DirLog.txt"
F10:: WatchDirectory(DirName)   ; Начать слежение.
F11:: WatchDirectory(0)         ; Остановить.
; ================ Функции =====================================================
WM_DIRECTORYCHANGE(BytesReturned, pOutBuf)
{
    Global LogFile
    ;FILE_ACTION_ADDED := 1, FILE_ACTION_REMOVED := 2, FILE_ACTION_MODIFIED := 3
    ;FILE_ACTION_RENAMED_OLD_NAME := 4, FILE_ACTION_RENAMED_NEW_NAME := 5
    Static Actions := ["Файл добавлен:  ", "Файл удалён:    ", "Файл изменён:   "
                     , "Файл переименован с имени: ", "Файл переименован на имя:  "]
    If (pOutBuf = 0) {
        MsgBox, Ошибка в ReadDirectoryChangeW
        Return
    }
    DateTime := A_DD "." A_MM "." A_YYYY " " A_Hour ":" A_Min ":" A_Sec
    Addr := pOutBuf, Next := 0  ; Адрес текущей записи и смещение до следующей.
    Loop    ; Чтение из буфера записей о событиях и реакция на них.
    {
        Addr += Next, Next := NumGet(Addr+0, 0, "uint") ; Смещение следующей записи.
        ActionCode := NumGet(Addr+0, 4, "uint") ; Код события (см. в начале функции).
        If (Action := Actions[ActionCode]) {    ; Описание события из массива.
            cbFile := NumGet(Addr+0, 8, "uint") ; Длина имени файла в байтах.
            FileName := StrGet(Addr+12, cbFile // 2, "utf-16")
            Msg .= DateTime " " Action FileName "`n"
        }
        If (!Next)  ; Если смещение равно 0, больше записей в буфере нет.
            Break
    }
    If (Msg) {
        ToolTip, %Msg%
        If (LogFile)
            FileAppend, %Msg%, %LogFile%
        Sleep, 1000
        ToolTip
    }
    WatchDirectory(-1)  ; Продолжить слежение.
}
WatchDirectory(DirName)
{
    Static hDir, hThread, pData, pThreadStart, OutBuf, OutBufSize := 0x400  ; 1 KB
    Static BytesReturned, WM_DIRECTORYCHANGE := 0x401
    ;FILE_NOTIFY_CHANGE_FILE_NAME := 0x1, FILE_NOTIFY_CHANGE_DIR_NAME := 0x2
    ;FILE_NOTIFY_CHANGE_ATTRIBUTES := 0x4, FILE_NOTIFY_CHANGE_SIZE := 0x8
    ;FILE_NOTIFY_CHANGE_LAST_WRITE := 0x10, FILE_NOTIFY_CHANGE_LAST_ACCESS := 0x20
    ;FILE_NOTIFY_CHANGE_CREATION := 0x40, FILE_NOTIFY_CHANGE_SECURITY := 0x100
    Static NotifyFilter := 0x11     ; Комбинация из флагов выше (сумма).
    If (DirName = -1) {
        DllCall("CloseHandle", "ptr", hThread)
        Goto NewThread
    }
    Else If (DirName = 0) {
        If (hThread) {
            DllCall("TerminateThread", "ptr", hThread, "int", 0)
            DllCall("CloseHandle", "ptr", hThread), hThread := 0
        }
        If (hDir)
            DllCall("CloseHandle", "ptr", hDir), hDir := 0
        Return
    }
    If (hDir)
        WatchDirectory(0) ; Остановить текущее слежение.
    If (!OutBuf) {
        VarSetCapacity(OutBuf, OutBufSize, 0), VarSetCapacity(BytesReturned, 4, 0)
        OnMessage(WM_DIRECTORYCHANGE, "WM_DIRECTORYCHANGE")
        If !(pReadDirectoryChanges := GetProcAddress("kernel32.dll", "ReadDirectoryChangesW"))
            Return Error("GetProcAddress - ReadDirectoryChangesW")
        If !(pPostMessage := GetProcAddress("user32.dll", "PostMessage" . (A_IsUnicode? "W":"A")))
            Return Error("GetProcAddress - PostMessage")
        If !(pThreadStart := CreateMachineFunc())
            Return Error("CreateMachineFunc")
        pData := CreateStruct(pReadDirectoryChanges, hDir, &OutBuf, OutBufSize, 0
                            , NotifyFilter, &BytesReturned, 0, 0
                            , pPostMessage, A_ScriptHwnd, WM_DIRECTORYCHANGE)
    }
    If !(hDir := OpenDirectory(DirName))
        Return Error("OpenDirectory")
    NumPut(hDir, pData+0, A_PtrSize, "ptr")
NewThread:
    If !(hThread := CreateThread(pThreadStart, pData))
        Return Error("CreateThread")
    Return True
}
OpenDirectory(Dir)
{
    Static FILE_LIST_DIRECTORY := 1, FILE_SHARE_READ := 1, FILE_SHARE_WRITE := 2
    Static OPEN_EXISTING := 3, FILE_FLAG_BACKUP_SEMANTICS := 0x02000000
    Static INVALID_HANDLE_VALUE := -1
    hDir := DllCall("CreateFile", "str", Dir, "uint", FILE_LIST_DIRECTORY
            , "uint", FILE_SHARE_READ | FILE_SHARE_WRITE, "ptr", 0, "uint", OPEN_EXISTING
            , "uint", FILE_FLAG_BACKUP_SEMANTICS, "ptr", 0, "ptr")
    Return hDir = INVALID_HANDLE_VALUE? 0:hDir      
}
CreateStruct(Members*)
{
    Static Struct
    cMembers := Members.MaxIndex()
    VarSetCapacity(Struct, cMembers * A_PtrSize, 0)
    addr := &Struct
    Loop, %cMembers%
        addr := NumPut(Members[A_Index], addr+0, 0, "ptr")
    Return &Struct
}
GetProcAddress(Lib, Func)
{
    hLib := DllCall("LoadLibrary", "str", Lib, "ptr")
    If (hLib = 0)
        Return 0
    Return DllCall("GetProcAddress", "ptr", hLib, "astr", Func, "ptr")
}
CreateMachineFunc()
{
    MEM_RESERVE := 0x2000, MEM_COMMIT := 0x1000, PAGE_EXECUTE_READWRITE := 0x40
    If (A_PtrSize = 8) {
        Hex = 
        ( Join LTrim
        488B0151FF7140FF7138FF7130FF71284883EC204C8B49204C8B4118488B5110488B4908FFD04
        C8B5424404D31C985C04D0F454A10498B4230448B00498B5258498B4A5041FF52484883C448C3
        )
    }
    Else {
        Hex =
        ( Join LTrim
        8B54240452FF7220FF721CFF7218FF7214FF7210FF720CFF7208FF7204FF125A85C00F4542088
        B4A1850FF31FF722CFF7228FF5224C20400
        )
    }
    Len := StrLen(Hex) // 2
    pFunc := DllCall("VirtualAlloc", "ptr", 0, "ptr", Len
                                   , "uint", MEM_RESERVE | MEM_COMMIT
                                   , "uint", PAGE_EXECUTE_READWRITE, "ptr")
    If (pFunc = 0)
        Return 0
    Loop, % Len
        NumPut("0x" . SubStr(Hex, A_Index * 2 - 1, 2), pFunc + 0
                                 , A_Index - 1, "uchar")
    Return pFunc
}
CreateThread(StartAddr, Param)
{
    Return DllCall("CreateThread", "ptr", 0, "ptr", 0, "ptr", StartAddr
                                 , "ptr", Param, "uint", 0, "ptr", 0, "ptr")
}
Error(Func)
{
    MsgBox, %Func% failed.
    Return False
}