Import:
{
#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
DetectHiddenWindows, On
SetTitleMatchMode, RegEx
}

loop, Files, %A_ScriptDir%\*.mp3, F
    Rename()
loop, Files, %A_ScriptDir%\*.srt, F
    Rename()
loop, Files, %A_ScriptDir%\*.vtt, F
    Rename()

WinActivate, Whisper UI

Rename()
{
    global
    NewFileName:=RegExReplace(A_LoopFilename, "i)[^a-z0-9-\.]")
    ;Msgbox %NewFileName%
    FileMove, %A_LoopFilename%, %NewFileName%
}
ExitApp