RUNBIN := A_Args[1]
FXSDKDIR := "C:\Users\Minn\tmp\javafx-sdk-20.0.1\lib"

RunWait javaw -jar --module-path %FXSDKDIR% --add-modules javafx.controls %RUNBIN%