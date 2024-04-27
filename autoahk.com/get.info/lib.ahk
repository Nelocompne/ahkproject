; https://www.autoahk.com/archives/38872

Class GetComInformation {
	OSInfo[] {
		get {
			this.OS:={}
			try {
				;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-operatingsystem?redirectedfrom=MSDN
				osobj := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_OperatingSystem" )._NewEnum()
				if osobj[win] {
					this.OS.BuildNumber:=win.BuildNumber,this.OS.Caption:=win.Caption,this.OS.Version:=win.Version
					,this.OS.Description:=win.Description,this.OS.CodeSet:=win.CodeSet,this.OS.Manufacturer:=win.Manufacturer
					,this.OS.Name:=win.Name,this.OS.OSType:=win.OSType,this.OS.ProductType:=win.ProductType
					,this.OS.SerialNumber:=win.SerialNumber,this.RegisteredUser:=win.RegisteredUser
					,this.OS.ServicePackMajorVersion:=win.ServicePackMajorVersion,this.OS.InstallDate:=win.InstallDate
					,this.OS.CSName:=win.CSName,this.OS.CSDVersion:=win.CSDVersion
				}
				VarSetCapacity(OSVer, 284, 0),NumPut(284, OSVer, 0, "UInt")
				If !DllCall("GetVersionExW", "Ptr", &OSVer)
					return this ; DllCall("kernel32.dll\GetLastError")
				this.OS.MajorVersion  := NumGet(OSVer, 4, "UInt"),this.OS.MinorVersion  := NumGet(OSVer, 8, "UInt")
				this.OS.BuildNumber := NumGet(OSVer, 12, "UInt"),this.OS.PlatformId:= NumGet(OSVer, 16, "UInt")
				this.OS.ServicePackString := StrGet(&OSVer+20, 128, "UTF-16"),this.OS.ServicePackMajor  := NumGet(OSVer, 276, "UShort")
				this.OS.ServicePackMinor  := NumGet(OSVer, 278, "UShort"),this.OS.SuiteMask := NumGet(OSVer, 280, "UShort")
				this.OS.ProductType := NumGet(OSVer, 282, "UChar")
				this.OS.EasyVersion := (this.OS.MajorVersion?this.OS.MajorVersion . ".":"") . (this.OS.MinorVersion?this.OS.MinorVersion . ".":"") . this.OS.BuildNumber
			}
			Return this
		}
	}
	; 获取主板信息
	BIOSInfo[] {
		get {
			this.BIOS:={}
			try {
				;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-bios
				objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . "." . "\root\cimv2")
				colSettings := objWMIService.ExecQuery("Select * from Win32_BIOS")._NewEnum
				if colSettings[objBiosItem] {   ;PropertyList>>["Caption,Description,IdentifyingNumber,Name,SKUNumber,UUID,Vendor,Version"]
					this.BIOS.SerialNumber:= objBiosItem.SerialNumber
				}Else{
					;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-computersystemproduct
					objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . "." . "\root\cimv2")
					colSysProduct := objWMIService.ExecQuery("Select * From Win32_ComputerSystemProduct")._NewEnum
					if colSysProduct[objSysProduct]   ;PropertyList>>["Caption,Description,IdentifyingNumber,Name,SKUNumber,UUID,Vendor,Version"]
						this.BIOS.SerialNumber:= objBiosItem.SerialNumber
				}
			}
			Return this
		}
	}
	; 获取cpu信息
	CpuInfo[] {
		get {
			this.Cpu:={}
			try {
				;https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
				objSWbemObject:=ComObjGet("winmgmts:Win32_Processor.DeviceID='cpu0'")
				if !(this.cpu.CpuProcessorId:=objSWbemObject.ProcessorId){
					;https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
					objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
					colCPU := objWMIService.ExecQuery("Select * From Win32_Processor")._NewEnum
					if colCPU[objCPU]  ;[DeviceID,ProcessorId,Name,SerialNumber,ProcessorType,Family,Description,DataWidth,Caption,AddressWidth]
						this.cpu.CpuProcessorId:= objCPU.ProcessorId,this.cpu.Name:=objCPU.Name,this.cpu.SerialNumber:=objCPU.SerialNumber
						,this.cpu.DeviceID:=objCPU.DeviceID,this.cpu.ProcessorType:=objCPU.ProcessorType,this.cpu.Family:=objCPU.Family,this.cpu.Caption:=objCPU.Caption
				}Else{
					this.cpu.Name:=objSWbemObject.Name,this.cpu.SerialNumber:=objSWbemObject.SerialNumber,this.cpu.Caption:=objSWbemObject.Caption
					,this.cpu.DeviceID:=objSWbemObject.DeviceID,this.cpu.ProcessorType:=objSWbemObject.ProcessorType,this.cpu.Family:=objSWbemObject.Family
				}
			}
			Return this
		}
	}
	MacAddress[]{ ;virtual
		get{
			this.Mac:=[]
			try {
				;https://docs.microsoft.com/zh-cn/windows/win32/cimwin32prov/win32-networkadapterconfiguration
				NetworkConfiguration:=ComObjGet("Winmgmts:").InstancesOf("Win32_NetworkAdapterConfiguration")
				for Mac in NetworkConfiguration
					if Mac.MacAddress  ;!InStr(Mac.Description,"vmware")&&Mac.IPEnabled <> 0
						this.Mac.Push([Mac.MacAddress ,"〔" (Mac.Caption?RegExReplace(Mac.Caption,".+\]\s*"):Mac.Description) "〕"])   ;Mac.Description
			}
			Return this
		}
	}
	NetworkParams[]{
		get {
			this.Network := {}
			static ERROR_SUCCESS := 0
			static ERROR_BUFFER_OVERFLOW := 111, MAX_HOSTNAME_LEN := 128
			static MAX_DOMAIN_NAME_LEN := 128, MAX_SCOPE_ID_LEN := 256
			static NODETYPE := { 1: "BROADCAST", 2: "PEER_TO_PEER", 4: "MIXED", 8: "HYBRID" }
			if (DllCall("iphlpapi\GetNetworkParams", "ptr", 0, "uint*", size) = ERROR_BUFFER_OVERFLOW)
			{
				VarSetCapacity(buf, size, 0)
				if (DllCall("iphlpapi\GetNetworkParams", "ptr", &buf, "uint*", size) = ERROR_SUCCESS)
				{
					addr := &buf, offset := 0
					this.Network["HostName"] := StrGet(addr + offset, MAX_HOSTNAME_LEN + 4, "cp0") , offset += MAX_HOSTNAME_LEN + 4
					this.Network["DomainName"] := StrGet(addr + offset, MAX_DOMAIN_NAME_LEN + 4, "cp0"), offset += MAX_DOMAIN_NAME_LEN + 4
					PIP_ADDR_STRING := NumGet(addr + offset, A_PtrSize, "uptr") , offset += A_PtrSize
					IP_ADDR_STRING  := NumGet(addr + offset, "uptr")
					while (IP_ADDR_STRING)
					{
						this.Network["DnsServerList", "IpAddress", A_Index + 1] := StrGet(IP_ADDR_STRING + A_PtrSize,     "cp0")
						this.Network["DnsServerList", "IpMask", A_Index + 1] := StrGet(IP_ADDR_STRING + A_PtrSize * 3, "cp0")
						IP_ADDR_STRING := NumGet(IP_ADDR_STRING + 0, "uptr")
					}
					this.Network["DnsServerList", "IpAddress", 1] := StrGet(addr + offset + A_PtrSize, "cp0"), offset += A_PtrSize * 2
					this.Network["DnsServerList", "IpMask", 1] := StrGet(addr + offset + A_PtrSize, "cp0"), offset += A_PtrSize * 4
					
					this.Network["NodeType"] := NODETYPE[NumGet(addr + offset, "uint")] , offset += 4
					this.Network["ScopeId"]  := StrGet(addr + offset, MAX_SCOPE_ID_LEN + 4, "cp0") , offset += MAX_SCOPE_ID_LEN + 4
					this.Network["EnableRouting"] := NumGet(addr + offset, "uint") , offset += 4
					this.Network["EnableProxy"] := NumGet(addr + offset, "uint") , offset += 4
					this.Network["EnableDns"] := NumGet(addr + offset, "uint")
					return this
				}
			}
			return this
		}
	}
	IpAddress[] {
		get{
			this.Ip:=[]
			try {
				if ipobj:=this.UrlDownloadToVars("http://ip-api.com/json/?lang=zh-CN",,,,,,,,,2){   ;设定超时时长
					iJson:= this.Json_toObj(ipobj)
					if (iJson["status"]="success"&&iJson["query"]){
						ipLocal:= (iJson["country"]?iJson["country"]:"") . (iJson["regionName"]?iJson["regionName"]:"") . (iJson["city"]?iJson["city"]:"") . (iJson["org"]?"- " iJson["org"]:"")
						this.ip.Push([iJson["query"] , ipLocal])
					}
				}
				Params:=this.NetworkParams.Network
				if (Params.HostName<>""&&Params.DnsServerList.IpAddress.1)
					this.ip.Push([Params.DnsServerList.IpAddress.1 , Params.HostName])
			}
			Return this
		}
	}
	;~ *****************说明*****************
	;~ 此函数与内置命令 UrlDownloadToFile 的区别有以下几点
	;~ 1.直接下载到变量，没有临时文件
	;~ 2.下载速度更快，大概100%
	;~ 3.支持超时，不必死等
	;~ 4.内置命令执行时，整个AHK程序都是卡顿状态。此函数不会
	;~ 5.内置命令下载一些诡异网站（例如“牛杂网”）时，会概率性让进程或线程彻底死掉。此函数不会
	;~ 6.支持设置网页字符集、URL的编码，乱码问题轻松解决
	;~ 7.支持设置Cookie、Referer、User-Agent，网站检测问题轻松解决
	;~ 8.支持设置代理服务器
	;~ 9.支持设置是否开启重定向
	;~ 10.这个版本是 0.5
	;~ *****************参数*****************
	;~ URL 网址，必须包含类似“http://www.”的开头。
	;~ Charset 网页字符集，不能是“936”之类的数字，必须是“gb2312”这样的字符。
	;~ URLCodePage URL的编码，是“936”之类的数字，默认是“65001”。有些网站需要UTF-8，有些网站又需要gb2312
	;~ Proxy 代理服务器，是形如“http://www.tuzi.com:80”的字符。
	;~ ProxyBypassList 代理服务器绕行名单，是形如“*.microsoft.com”的域名。符合域名的网址，将不通过代理服务器访问。
	;~ Cookie ，常用于登录验证。
	;~ Referer 引用网址，常用于防盗链。
	;~ UserAgent 用户信息，常用于防盗链。
	;~ EnableRedirects 重定向，默认获取跳转后的页面信息，0为不跳转。
	;~ Timeout 超时，单位为秒，默认不使用超时（Timeout=-1）。
	UrlDownloadToVars(URL,Charset="",URLCodePage="",Proxy="",ProxyBypassList="",Cookie="",Referer="",UserAgent="",EnableRedirects="",Timeout=-1)
	{
		ComObjError(0)  ;禁用 COM 错误通告。禁用后，检查 A_LastError 的值，脚本可以实现自己的错误处理
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		if (URLCodePage<>"")    ;设置URL的编码
			WebRequest.Option(2):=URLCodePage
		if (EnableRedirects<>"")
			WebRequest.Option(6):=EnableRedirects
		if (Proxy<>"")  ;设置代理服务器。微软的代码 SetProxy() 是放在 Open() 之前的，所以我也放前面设置，以免无效
			WebRequest.SetProxy(2,Proxy,ProxyBypassList)
		WebRequest.Open("GET", URL, true)   ;true为异步获取，默认是false。龟速的根源！！！卡顿的根源！！！
		if (Cookie<>"") ;设置Cookie。SetRequestHeader() 必须 Open() 之后才有效
		{
			WebRequest.SetRequestHeader("Cookie","tuzi")    ;先设置一个cookie，防止出错，见官方文档
			WebRequest.SetRequestHeader("Cookie",Cookie)
		}
		if (Referer<>"")    ;设置Referer
			WebRequest.SetRequestHeader("Referer",Referer)
		if (UserAgent<>"")  ;设置User-Agent
			WebRequest.SetRequestHeader("User-Agent",UserAgent)
		WebRequest.Send()
		WebRequest.WaitForResponse(Timeout) ;WaitForResponse方法确保获取的是完整的响应
		if (Charset="") ;设置字符集
			return,RegExReplace(WebRequest.ResponseText(),"^\s+|\s+$")
		else
		{
			ADO:=ComObjCreate("adodb.stream")   ;使用 adodb.stream 编码返回值。参考 http://bbs.howtoadmin.com/ThRead-814-1-1.html
			ADO.Type:=1 ;以二进制方式操作
			ADO.Mode:=3 ;可同时进行读写
			ADO.Open()  ;开启物件
			ADO.Write(WebRequest.ResponseBody())    ;写入物件。注意 WebRequest.ResponseBody() 获取到的是无符号的bytes，通过 adodb.stream 转换成字符串string
			ADO.Position:=0 ;从头开始
			ADO.Type:=2 ;以文字模式操作
			ADO.Charset:=Charset    ;设定编码方式
			return,RegExReplace(ADO.ReadText(),"^\s+|\s+$")   ;将物件内的文字读出
		}
	}
	Json_toObj(ByRef src, args*)
	{
		static q := Chr(34)
		key := "", is_key := false
		stack := [ tree := [] ]
		is_arr := { (tree): 1 }
		next := q . "{[01234567890-tfn"
		pos := 0
		while ( (ch := SubStr(src, ++pos, 1)) != "" )
		{
			if InStr(" `t`n`r", ch)
				continue
			if !InStr(next, ch, true)
			{
				ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
				col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))
				msg := Format("{}: line {} col {} (char {})"
				,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
				  : (next == "'")     ? "Unterminated string starting at"
				  : (next == "\")     ? "Invalid \escape"
				  : (next == ":")     ? "Expecting ':' delimiter"
				  : (next == q)       ? "Expecting object key enclosed in double quotes"
				  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
				  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
				  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
				  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
				    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
				, ln, col, pos)
				throw Exception(msg, -1, ch)
			}
			is_array := is_arr[obj := stack[1]]
			if i := InStr("{[", ch)
			{
				val := (proto := args[i]) ? new proto : {}
				is_array? ObjPush(obj, val) : obj[key] := val
				ObjInsertAt(stack, 1, val)
				is_arr[val] := !(is_key := ch == "{")
				next := q . (is_key ? "}" : "{[]0123456789-tfn")
			}
			else if InStr("}]", ch)
			{
				ObjRemoveAt(stack, 1)
				next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
			}
			else if InStr(",:", ch)
			{
				is_key := (!is_array && ch == ",")
				next := is_key ? q : q . "{[0123456789-tfn"
			}
			else ; string | number | true | false | null
			{
				if (ch == q) ; string
				{
					i := pos
					while i := InStr(src, q,, i+1)
					{
						val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
						static end := A_AhkVersion<"2" ? 0 : -1
						if (SubStr(val, end) != "\")
							break
					}
					if !i ? (pos--, next := "'") : 0
						continue
					pos := i ; update pos
					  val := StrReplace(val,    "\/",  "/")
					, val := StrReplace(val, "\" . q,    q)
					, val := StrReplace(val,    "\b", "`b")
					, val := StrReplace(val,    "\f", "`f")
					, val := StrReplace(val,    "\n", "`n")
					, val := StrReplace(val,    "\r", "`r")
					, val := StrReplace(val,    "\t", "`t")
					i := 0
					while i := InStr(val, "\",, i+1)
					{
						if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
							continue 2
						; \uXXXX - JSON unicode escape sequence
						xxxx := Abs("0x" . SubStr(val, i+2, 4))
						if (A_IsUnicode || xxxx < 0x100)
							val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
					}
					if is_key
					{
						key := val, next := ":"
						continue
					}
				}
				else ; number | true | false | null
				{
					val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
					static null := "" ; for #Warn
					if InStr(",true,false,null,", "," . val . ",", true) ; if var in
						val := %val%
					else if (Abs(val) == "") ? (pos--, next := "#") : 0
						continue
					val := val + 0, pos += i-1
				}
				is_array? ObjPush(obj, val) : obj[key] := val
				next := obj==tree ? "" : is_array ? ",]" : ",}"
			}
		}
		return tree[1]
	}
}