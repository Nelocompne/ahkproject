; AHK v1
; 文件名后缀切换，win7/10测试通过

RegRead,Value,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\,HideFileExt
If(value=0)
  value = 1
Else
  value = 0
RegWrite, REG_DWORD,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\,HideFileExt, %Value%
PostMessage,0x111,0x7103,0,SHELLDLL_DefView1,A
return