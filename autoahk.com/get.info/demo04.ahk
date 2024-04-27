#Include lib.ahk

IpAddress:="ip信息：`n******************************************`n"
for each,item In GetComInformation.IpAddress.ip
	IpAddress.="IP地址：" item[1] "`n定位或本机帐户名：" item[2] "`n******************************************`n"
MsgBox % IpAddress