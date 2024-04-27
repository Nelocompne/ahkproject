#Include lib.ahk

OSInformation:=GetComInformation.OSInfo.OS
MsgBox % OSInformation.Caption . (OSInformation.Version?A_Space OSInformation.Version:"") . (A_Is64bitOS?"- 64位":"- 32位") . (OSInformation.BuildNumber?" Build " OSInformation.BuildNumber:"") . (OSInformation.CSDVersion? " - " OSInformation.CSDVersion:OSInformation.ServicePackString? " - " OSInformation.ServicePackString:"")