; Author: Mono
; Time: 2022.08.17
; Class Music
; https://www.autoahk.com/archives/43066
File2KeyArr(Filename, Flags := "r", Encoding := "utf-8")
{
    Res := []
    FileObj := FileOpen(Filename, Flags, Encoding)
    Flag := (FileObj.ReadLine() == "Key::") ? 1 : 0
    
    if Flag
    {
        While !FileObj.AtEOF
        {
            NewLine := StrSplit(FileObj.ReadLine())
            Lst_Flag := 0
            Tmp := []
            
            For i in NewLine
            {
                if i == " "
                    Res.Push(_)
                
                else if i == "+"
                    Res.Push("*0.5")
                
                else if i == "-"
                    Res.Push("*2")
                
                else if i == "("
                {
                    Lst_Flag := 1
                    Continue
                }
                
                else if i == ")"
                {
                    Lst_Flag := 0
                    Res.Push(Tmp.Clone())
                    Tmp := []
                    Continue
                }
                
                else if Lst_Flag
                    Tmp.Push(i)
                
                else if i == "|"
                    Continue
                
                else
                    Res.Push(i)
            }
        }
    }
        
    Return Res
}
LoadMidi()
{
    hModule := DllCall("LoadLibrary", "Str", "winmm.dll")
    Return hModule
}
MidiOutClose(handle)
{
    result := DllCall("winmm.dll\midiOutClose", "UInt", handle)
    
    if result
    {
        Msgbox "There was an error closing the midi output port.  There may still be midi events being processed through it."
        Return -1
    }
    
    Return
}
MidiOutOpen(DeviceID := 0)
{
    dwFlags := 0
    result := DllCall("winmm.dll\midiOutOpen"
                    , "UInt*", &handle := 0
                    , "UInt", DeviceID
                    , "UInt", 0
                    , "UInt", 0
                    , "UInt", dwFlags)
    if result
    {
        Msgbox "There was an error opening the midi port.  The port may be in use.  Try closing and reopening all midi-enabled applications."
        Return -1
    }
    
    Return handle
}
MidiOutShortMsg(handle, voice)
{
    result := DllCall("winmm.dll\midiOutShortMsg"
                    , "UInt", handle
                    , "UInt", voice)
  
    if result
    {
        Msgbox "There was an error sending the midi event."
        Return -1
    }
    
    Return
}
Class Music
{
    Static KeyPlay(Arr, DeviceID := 0, QuitKey := "Esc", Speed := 300, Wait := 0.5)
    {
        handle := MidiOutOpen(DeviceID)
        volume := 0x7f
        voice := 0x0
        SleepTime := Speed
        Lst_Voice := []
        v := Map('Z',C3,'X',D3,'C',E3,'V',F3,'B',G3,'N',A3,'M',B3,
            'A',C4,'S',D4,'D',E4,'F',F4,'G',G4,'H',A4,'J',B4,
            'Q',C5,'W',D5,'E',E5,'R',F5,'T',G5,'Y',A5,'U',B5)
        Print("请按"  QuitKey "键退出演奏")
        
        For i in Arr
        {
            tmp := []
            Lst_i := Type(i) == "Array" ? i : [i]
            
            if GetKeyState(QuitKey)
            {
                MidiOutClose(handle)
                WinClose("Sinet Print")
                Return
            }
            
            For j in Lst_i
            {
                
                if (j == LOW_SPEED || j == HIGH_SPEED || j == MIDDLE_SPEED)
                {
                    SleepTime := j
                    Continue 2
                }
                
                if InStr(j, "*")
                {
                    SleepTime *= StrReplace(j, "*")
                    Continue 2
                }
                
                if (j == _)
                {
                    Sleep(SleepTime * Wait)
                    Continue 2
                }
                
                voice := (volume << 16) + (v[j] << 8) + 0x94
                tmp.Push(voice)
            }
            
            For j in tmp
                MidiOutShortMsg(handle, j)
            
            Lst_Voice.Push(tmp)
            Sleep(SleepTime)
        }
        
        MidiOutClose(handle)
        WinClose("Sinet Print")
        Return Lst_Voice
    }
    
    Static Piano(DeviceID := 0, QuitKey := "Esc")
    {
        handle := MidiOutOpen(DeviceID)
        v := Map('Z',C3,'X',D3,'C',E3,'V',F3,'B',G3,'N',A3,'M',B3,
            'A',C4,'S',D4,'D',E4,'F',F4,'G',G4,'H',A4,'J',B4,
            'Q',C5,'W',D5,'E',E5,'R',F5,'T',G5,'Y',A5,'U',B5)
            
        Print("钢琴已开启，敲击键盘Q-U,A-J,Z-M")
        Print("请按"  QuitKey "键退出`n")
        
        While True
        {
            if GetKeyState(QuitKey)
            {
                MidiOutClose(handle)
                WinClose("Sinet Print")
                Return
            }
            
            For i in Range(Ord('A'), Ord('Z') + 1)
            {
                if GetKeyState(Chr(i))
                {
                    MidiOutShortMsg(handle, (0x007f << 16) + (v[Chr(i)] << 8) + 0x90)
                    Print("已按下" Chr(i) "键")
                    
                    While GetKeyState(Chr(i))
                        Sleep(100)
                }
            }
        }
    }
    
    Static Play(Arr, DeviceID := 0, QuitKey := "Esc", Speed := 300)
    {
        handle := MidiOutOpen(DeviceID)
        volume := 0x7f
        voice := 0x0
        SleepTime := Speed
        Lst_Voice := []
        Print("请按"  QuitKey "键退出演奏")
        
        For i in Arr
        {
            tmp := []
            Lst_i := Type(i) == "Array" ? i : [i]
            
            For j in Lst_i
            {
                if GetKeyState(QuitKey)
                {
                    MidiOutClose(handle)
                    WinClose("Sinet Print")
                    Return
                }
                
                if (j == LOW_SPEED || j == HIGH_SPEED || j == MIDDLE_SPEED)
                {
                    SleepTime := j
                    Continue 2
                }
                
                if InStr(j, "*")
                {
                    SleepTime *= StrReplace(j, "*")
                    Continue 2
                }
                
                if (j == _)
                {
                    Sleep(SleepTime / 2)
                    Continue 2
                }
            
                voice := (volume << 16) + (j << 8) + 0x94
                tmp.Push(voice)
            }
            
            For j in tmp
                MidiOutShortMsg(handle, j)
            
            Lst_Voice.Push(tmp)
            Sleep(SleepTime)
        }
        
        MidiOutClose(handle)
        WinClose("Sinet Print")
        Return Lst_Voice
    }
}
Print(Text*)
{
    Global Print_Gui
    Global Print_Edit
    Print_Text := ""
    Loop Text.Length
    {
        String_Text := ToStringPrint(Text[A_Index])
        
        if SubStr(String_Text, -1) == "," && (Type(Text[A_Index]) == "Array" || Type(Text[A_Index]) == "ComObjArray" || Type(Text[A_Index]) == "Map" || Type(Text[A_Index]) == "Object")
            String_Text := SubStr(String_Text, 1, StrLen(String_Text) - 1)
        
        Print_Text .= String_Text "`n"
    }
    
    Print_Text := SubStr(Print_Text, 1, StrLen(Print_Text) - 1)
    
    if WinExist("Sinet Print")
    {
        WinActivate("Sinet Print")
        Print_Edit.Value .= "`n" Print_Text
        Return
    }
    
    Print_Gui := Gui()
    Print_Gui.Title := "Sinet Print"
    Print_Gui.BackColor := "87CEFA"
    Print_Edit := Print_Gui.Add("Edit", "R30 W800 ReadOnly")
    Print_Edit.SetFont("S12", "Arial")
    Print_Edit.Value := Print_Text
    Print_Gui.Show()
}
Range(start, stop)
{
    tmp := []
    
    Loop stop - start
        tmp.Push(start + A_Index - 1)
    
    Return tmp
}
ToStringPrint(Text)
{
    if Type(Text) == "Array"
    {
        if Text.Length < 1
            Text.InsertAt(1, "")
        
        String_Plus := ""
        String_Text := "[" . ToStringPrint(Text[1])
        
        Loop Text.Length - 1
            String_Plus .= "," . ToStringPrint(Text[A_Index + 1])
        
        String_Text .= String_Plus
        String_Text .= "]"
        
        Return String_Text
    }
    
    else if Type(Text) == "ComObjArray"
    {
        if Text.MaxIndex() < 0
        {
            Text := ComObjArray(VT_VARIANT:=12, 1)
            Text[0] := ""
        }
        
        String_Plus := ""
        String_Text := "[" . ToStringPrint(Text[0])
        
        Loop Text.MaxIndex()
            String_Plus .= "," . ToStringPrint(Text[A_Index])
        
        String_Text .= String_Plus
        String_Text .= "]"
        
        Return String_Text
    }
    
    else if Type(Text) == "Map"
    {
        String_Text := "{"
        
        For i, Value in Text
            String_Text .= ToStringPrint(i) . ":" . ToStringPrint(Value) . ","
        
        if SubStr(String_Text, -1) !== "{"
            String_Text := SubStr(String_Text, 1, StrLen(String_Text) - 1)
        
        String_Text .= "}"
        
        Return String_Text
    }
    
    else if Type(Text) == "Integer" || Type(Text) == "Float" || Type(Text) == "String"
        Return Text
    
    else if Type(Text) == "Object"
    {
        String_Text := "{"
        
        For i, Value in Text.OwnProps()
            String_Text .= ToStringPrint(i) . ":" . ToStringPrint(Value) . ","
        
        if SubStr(String_Text, -1) !== "{"
            String_Text := SubStr(String_Text, 1, StrLen(String_Text) - 1)
        
        String_Text .= "},"
        
        Return String_Text
    }
    
    else
        Return "#Type: " Type(Text) "#"
}
; Scale音阶参数
Rest := 0, C8 := 108, B7 := 107, A7s := 106, A7 := 105, G7s := 104, G7 := 103, F7s := 102, F7 := 101, E7 := 100,
D7s := 99, D7 := 98, C7s := 97, C7 := 96, B6 := 95, A6s := 94, A6 := 93, G6s := 92, G6 := 91, F6s := 90, F6 := 89,
E6 := 88, D6s := 87, D6 := 86, C6s := 85, C6 := 84, B5 := 83, A5s := 82, A5 := 81, G5s := 80, G5 := 79, F5s := 78,
F5 := 77, E5 := 76, D5s := 75, D5 := 74, C5s := 73, C5 := 72, B4 := 71, A4s := 70, A4 := 69, G4s := 68, G4 := 67,
F4s := 66, F4 := 65, E4 := 64, D4s := 63, D4 := 62, C4s := 61, C4 := 60, B3 := 59, A3s := 58, A3 := 57, G3s := 56,
G3 := 55, F3s := 54, F3 := 53, E3 := 52, D3s := 51, D3 := 50, C3s := 49, C3 := 48, B2 := 47, A2s := 46, A2 := 45,
G2s := 44, G2 := 43, F2s := 42, F2 := 41, E2 := 40, D2s := 39, D2 := 38, C2s := 37, C2 := 36, B1 := 35, A1s := 34,
A1 := 33, G1s := 32, G1 := 31, F1s := 30, F1 := 29, E1 := 28, D1s := 27, D1 := 26, C1s := 25, C1 := 24, B0 := 23,
A0s := 22, A0 := 21
; Voice
L1 := C3, L2 := D3, L3 := E3, L4 := F3, L5 := G3, L6 := A3, L7 := B3,
M1 := C4, M2 := D4, M3 := E4, M4 := F4, M5 := G4, M6 := A4, M7 := B4,
H1 := C5, H2 := D5, H3 := E5, H4 := F5, H5 := G5, H6 := A5, H7 := B5,
LOW_SPEED := 600, MIDDLE_SPEED := 300, HIGH_SPEED := 150,
_ := 0XFF