; AHK v1
; 隐藏文件切换，win10测试通过

RegRead,value,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\, Hidden
If(value=1)
  value = 2
Else
  value = 1
RegWrite, REG_DWORD, HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\, Hidden, %Value%
RegWrite, REG_DWORD, HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\, ShowSuperHidden, %Value%-1
PostMessage,0x111,0x7103,0,SHELLDLL_DefView1,A
return
