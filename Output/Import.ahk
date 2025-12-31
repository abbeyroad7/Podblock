Import:
{
#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
DetectHiddenWindows, On
SetTitleMatchMode, RegEx
}

IniRead, PodcastDefault, %A_ScriptDir%\KeepLocal.ini, Default, KeepLocal
loop, Files, %A_ScriptDir%\*, D
{
    If (A_LoopFileName=".stfolder") OR If (A_LoopFileName=".Waiting2Import")
        continue
    Count:=0, Podcast:=A_LoopFileName, PodcastLimit:=""
    IniRead, PodcastLimit, %A_ScriptDir%\KeepLocal.ini, PodcastSpecific, %A_LoopFileName%, %PodcastDefault%

    ;Msgbox % A_LoopFileName PodcastLimit
    loop, Files, %A_ScriptDir%\%A_LoopFileName%\*.mp3, FR
        Count++
    ;Msgbox % A_LoopFileName Count

    If (Count < PodcastLimit)
    {
        LoopCount:=PodcastLimit-Count, Episode:=""
        ;Msgbox % A_LoopFileName LoopCount
        Loop, Files, %A_ScriptDir%\.Waiting2Import\%A_LoopFileName%\*.mp3, FR
        {
            Episode:=A_LoopFileName
            FileMove, %A_ScriptDir%\.Waiting2Import\%Podcast%\%Episode%, %A_ScriptDir%\%Podcast%\%Episode%
            If (A_Index=LoopCount)
                break
        }
    }
}
Msgbox,,, Podcasts updated.,5
ExitApp