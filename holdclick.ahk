#NoEnv
SendMode Input

$^n::
    if (GetKeyState("LButton", "P") = 0) {
        Click down left
    } else {
        Click up left
    }
return
