; AHK v2

;for %x in (powershell.exe) do @echo %~$PATH:x

;Run A_ComSpec " /k for %x in (powershell.exe) do @echo %~$PATH:x"

COMMDD := A_Args[1]
VARC := "for %x in (" COMMDD ") do @echo %~$PATH:x"
MsgBox RunWaitOne(VARC)

RunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    ; 通过 cmd.exe 执行单条命令
    exec := shell.Exec(A_ComSpec " /C " command)
    ; 读取并返回命令的输出
    return exec.StdOut.ReadAll()
}