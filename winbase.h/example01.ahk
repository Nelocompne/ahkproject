#NoEnv
SetBatchLines -1
FILE_NOTIFY_CHANGE_FILE_NAME  := 0x1
FILE_NOTIFY_CHANGE_DIR_NAME   := 0x2
FILE_NOTIFY_CHANGE_ATTRIBUTES := 0x4
FILE_NOTIFY_CHANGE_SIZE       := 0x8
notifyFilter := FILE_NOTIFY_CHANGE_FILE_NAME
              | FILE_NOTIFY_CHANGE_DIR_NAME
              | FILE_NOTIFY_CHANGE_ATTRIBUTES
              | FILE_NOTIFY_CHANGE_SIZE
folderPath1 := A_Desktop
folderPath2 := A_ScriptDir
              
Inst1 := new FileMonitoring(folderPath1, notifyFilter, "OnDirectoryChanged1")
Inst2 := new FileMonitoring(folderPath2, notifyFilter, "OnDirectoryChanged2")
Return
OnDirectoryChanged1(filePath, event) 
{
   MsgBox, % ["添加", "移除", "修改", "重命名,旧名字", "重命名, 新名字"][event] ": " filePath
}
OnDirectoryChanged2(filePath, event) 
{
   MsgBox, % ["添加", "移除", "修改", "重命名,旧名字", "重命名, 新名字"][event] ": " filePath
}
class FileMonitoring
{
   __New(folderPath, notifyFilter, UserFunc, watchSubtree := false) {
      this.Event := new this._Event()
      this.SetCapacity("buffer", 1024)
      pBuffer := this.GetAddress("buffer")
      this.SetCapacity("overlapped", A_PtrSize*3 + 8)
      this.pOverlapped := this.GetAddress("overlapped")
      this.Directory := new this._ReadDirectoryChanges( folderPath, notifyFilter, watchSubtree
                                                      , pBuffer, this.pOverlapped, this.Event.handle )
      this.EventSignal := new this._EventSignal(this.Directory, this.Event.handle, pBuffer, UserFunc)
      this.Directory.Read()
   }
   
   __Delete() {
      DllCall("CancelIoEx", "Ptr", this.Directory.handle, "Ptr", this.pOverlapped)
      this.Event.Set()
      this.EventSignal.Clear()
      this.Directory.Clear()
      this.SetCapacity("buffer", 0)
      this.buffer := ""
   }
   
   class _Event 
   {
      __New() {
         this.handle := DllCall("CreateEvent", "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr")
      }
      Set() {
         DllCall("SetEvent", "Ptr", this.handle)
      }
      __Delete() {
         DllCall("CloseHandle", "Ptr", this.handle)
      }
   }
   
   class _ReadDirectoryChanges 
   {
      __New(dirPath, notifyFilter, watchSubtree, pBuffer, pOverlapped, hEvent) {
         static OPEN_EXISTING := 3
              , access := (FILE_SHARE_READ := 1) | (FILE_SHARE_WRITE := 2)
              , flags := (FILE_FLAG_OVERLAPPED := 0x40000000) | (FILE_FLAG_BACKUP_SEMANTICS := 0x2000000)
              
         for k, v in ["notifyFilter", "pBuffer", "pOverlapped", "hEvent"]
            this[v] := %v%
         this.handle := DllCall("CreateFile", "Str", dirPath, "UInt", 1, "UInt", access, "Int", 0
                                            , "UInt", OPEN_EXISTING, "UInt", flags, "Int", 0, "Ptr")
      }
      
      Read() 
      {
         DllCall("RtlZeroMemory", "Ptr", this.pOverlapped, "Ptr", A_PtrSize*3 + 8)
         NumPut(this.hEvent, this.pOverlapped + A_PtrSize*2 + 8, "Ptr")
         ; there is only a Unicode version of this api
         Return DllCall("ReadDirectoryChangesW", "Ptr", this.handle, "Ptr", this.pBuffer, "UInt", 1024, "UInt", watchSubtree
                                               , "UInt", this.notifyFilter, "Ptr", 0, "Ptr", this.pOverlapped, "Ptr", 0)
      }
      
      Clear() 
      {
         DllCall("CloseHandle", "Ptr", this.handle)
      }
   }
   
   class _EventSignal 
   {
      __New(Directory, hEvent, pBuffer, UserFunc) 
      {
         this.WM_EVENTSIGNAL := DllCall("RegisterWindowMessage", "Str", "WM_EVENTSIGNAL", "UInt")
         for k, v in ["Directory", "hEvent", "pBuffer"]
            this[v] := %v%
         this.UserFunc := IsObject(UserFunc) ? UserFunc : Func(UserFunc)
         this.OnEvent := ObjBindMethod(this, "On_WM_EVENTSIGNAL")
         OnMessage(this.WM_EVENTSIGNAL, this.OnEvent)
         this.startAddress := this.CreateWaitFunc(this.hEvent, A_ScriptHwnd, this.WM_EVENTSIGNAL)
         this.Thread := new this._Thread(this.startAddress)
      }
      
      On_WM_EVENTSIGNAL(wp) 
      {
         if !( wp = this.hEvent
            && DllCall("GetOverlappedResult", "Ptr", this.hEvent, "Ptr", this.pBuffer, "UIntP", written, "UInt", false) )
            Return
         
         addr := this.pBuffer
         offset := 0
         Loop 
         {
            addr += offset
            eventType  := NumGet(addr + 4, "UInt")
            objectName := StrGet(addr + 12, NumGet(addr + 8, "UInt")//2, "UTF-16") ; always in Unicode
            timer := this.UserFunc.Bind(objectName, eventType)
            SetTimer, % timer, -10
         } until !offset := NumGet(addr + 0, "UInt")
         this.Thread.Wait()
         this.Thread := new this._Thread(this.startAddress)
         this.Directory.Read()
      }
      CreateWaitFunc(Handle, hWnd, Msg, Timeout := -1) 
      {
         static params := ["UInt", MEM_COMMIT := 0x1000, "UInt", PAGE_EXECUTE_READWRITE := 0x40, "Ptr"]
         ptr := DllCall("VirtualAlloc", "Ptr", 0, "Ptr", A_PtrSize = 4 ? 49 : 85, params*)
         hModule := DllCall("GetModuleHandle", "Str", "kernel32.dll", "Ptr")
         pWaitForSingleObject := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "WaitForSingleObject", "Ptr")
         hModule := DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr")
         pPostMessageW := DllCall("GetProcAddress", "Ptr", hModule, "AStr", "PostMessageW", "Ptr")
         NumPut(pWaitForSingleObject, ptr*1)
         NumPut(pPostMessageW, ptr + A_PtrSize)
         if (A_PtrSize = 4)  {
            NumPut(0x68, ptr + 8, "UChar")
            NumPut(Timeout, ptr + 9, "UInt"), NumPut(0x68, ptr + 13, "UChar")
            NumPut(Handle, ptr + 14), NumPut(0x15FF, ptr + 18, "UShort")
            NumPut(ptr, ptr + 20), NumPut(0x6850, ptr + 24, "UShort")
            NumPut(Handle, ptr + 26), NumPut(0x68, ptr + 30, "UChar")
            NumPut(Msg, ptr + 31, "UInt"), NumPut(0x68, ptr + 35, "UChar")
            NumPut(hWnd, ptr + 36), NumPut(0x15FF, ptr + 40, "UShort")
            NumPut(ptr+4, ptr + 42), NumPut(0xC2, ptr + 46, "UChar"), NumPut(4, ptr + 47, "UShort")
         }
         else  
         {
            NumPut(0x53, ptr + 16, "UChar")
            NumPut(0x20EC8348, ptr + 17, "UInt"), NumPut(0xBACB8948, ptr + 21, "UInt")
            NumPut(Timeout, ptr + 25, "UInt"), NumPut(0xB948, ptr + 29, "UShort")
            NumPut(Handle, ptr + 31), NumPut(0x15FF, ptr + 39, "UShort")
            NumPut(-45, ptr + 41, "UInt"), NumPut(0xB849, ptr + 45, "UShort")
            NumPut(Handle, ptr + 47), NumPut(0xBA, ptr + 55, "UChar")
            NumPut(Msg, ptr + 56, "UInt"), NumPut(0xB948, ptr + 60, "UShort")
            NumPut(hWnd, ptr + 62), NumPut(0xC18941, ptr + 70, "UInt")
            NumPut(0x15FF, ptr + 73, "UShort"), NumPut(-71, ptr + 75, "UInt")
            NumPut(0x20C48348, ptr + 79, "UInt"), NumPut(0xC35B, ptr + 83, "UShort")
         }
         Return ptr + A_PtrSize*2
      }
      
      class _Thread 
      {
         __New(startAddress) 
         {
            if !this.handle := DllCall("CreateThread", "Int", 0, "Int", 0, "Ptr", startAddress, "Int", 0, "UInt", 0, "Int", 0, "Ptr")
               throw Exception("Failed to create thread.`nError code: " . A_LastError)
         }
         Wait() 
         {
            DllCall("WaitForSingleObject", "Ptr", this.handle, "Int", -1)
         }
         __Delete() 
         {
            DllCall("CloseHandle", "Ptr", this.handle)
         }
      }
      
      Clear() 
      {
         this.Thread.Wait()
         OnMessage(this.WM_EVENTSIGNAL, this.OnEvent, 0)
         this.OnEvent := ""
         DllCall("VirtualFree", "Ptr", this.startAddress - A_PtrSize*2, "Ptr", A_PtrSize = 4 ? 49 : 85, "UInt", MEM_DECOMMIT := 0x4000)
      }
   }
}