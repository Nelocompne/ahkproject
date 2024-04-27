#Requires AutoHotkey v1.0
RUNBIN := A_Args[1]
FileRead, FXSDKDIR, without_javafx.ini

RunWait javaw -jar --module-path %FXSDKDIR% --add-modules javafx.controls %RUNBIN%