; AHK v2

if (PID := ProcessExist("bin_name.exe"))
    ProcessClose "bin_name.exe"
else
    Run "bin_name.exe command" , ,"Hide"