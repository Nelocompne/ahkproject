Loop read, "adds\list.txt"
{
    Loop parse, A_LoopReadLine, "`n", "`r"
    {
        objs := Format("addr\" , A_LoopField)
        FileMove objs, "adds"
    }
}
