#Include lib.ahk

MacAddress:=""
for each,item In GetComInformation.MacAddress.Mac
	MacAddress.=("MacAddress：" item[1]) . ("`n设备描述：" . item[2]) . (item[3]?"`nIPAddress：" item[3]:"") . "`n***************************************************`n"
MsgBox % MacAddress