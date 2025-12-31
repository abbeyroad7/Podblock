Import:
{
#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
DetectHiddenWindows, On
SetTitleMatchMode, RegEx
}

SRTCount:=""
FileRead, Keywords, %A_ScriptDir%\PodBlock\Common.txt

loop, Files, %A_ScriptDir%\*.*, F
{
    if (InStr(A_LoopFileName, ".srt"))
        SRTFile:=A_LoopFileName
    if (InStr(A_LoopFileName, ".vtt"))
        SRTFile:=A_LoopFileName
}
FileRead, SRTText, %SRTFile%

Loop, Parse, Keywords, `n`r
{
    word = %A_LoopField%
    Count = 0
    loop, parse, SRTText, `n
    {
        if (InStr(A_LoopField, Word))
            Count++
    }
    
    If (Count > 0) | If (Count < 50)
        Output .= Word " : " count "`n`n"
    Count:=""
}

Run, %SRTFile%
;Run, PodBlock.ahk
Msgbox % Output
ExitApp