; V0.1.2
; Todo:
; Automate YT-dlp
; DLQueue inventory checker
; Playlist generator

; Features:
; Custom name defines
; Intro-Outro defines
; Sponsor defines
; Included Adsniffer utility
; Included YT-dlp/Sponsorblock downloader script
; Easy integration with SyncThing
; Included startup script to limit import of synced episodes

Import:
{
#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
DetectHiddenWindows, On
SetTitleMatchMode, RegEx

;Podcast = BehindTheBastards
;InputBox, Podcast, Podcast,,, 200,200
Ext:="", SRTText:="", Outro:="", Intro:="", FileStart:="", FileEnd:="", Start:="", End:=""
FileRecycle, output.txt
FileRecycle, Log.txt
}

ImportFiles()
;##ProcessSponsors()
CombineTimestamps()
ProcessIntroOutro()
FFMpeg()
ExitApp

ImportFiles()
{
    global
    loop, Files, %A_ScriptDir%\*.*, F
    {
        if (InStr(A_LoopFileName, ".srt"))
            SRTFile:=A_LoopFileName, Ext:=".srt"
        if (InStr(A_LoopFileName, ".vtt"))
            SRTFile:=A_LoopFileName, Ext:=".en-US.vtt"
    }

    loop, Files, %A_ScriptDir%\*.mp3, F
	{
        Mp3File:=A_LoopFileName, Mp3Split:=StrSplit(Mp3File, "-"), ChannelName:=Mp3Split.1
        PodcastNamesLookup()
        ;Msgbox % SRTFile Ext
        FileRead, SRTText, %SRTFile%
        SRTText_NoPunc:=RegExReplace(SRTText, "i)[^a-z0-9 '`n.\/%\[\]]")
        ;Msgbox % SRTText_NoPunc
        loop, Files, %PodcastDir%\Sponsors\*.txt, FR
        {
            FileReadLine, FileStart, %A_LoopFileFullPath%, 1
            FileReadLine, FileEnd, %A_LoopFileFullPath%, 2
            ;Msgbox %FileStart%`n%FileEnd%  ;Sponsor filters loaded?
            ProcessSponsors()
        }
	}
}

PodcastNamesLookup()
{
    global
    FileRead, PodcastNamesText, %A_ScriptDir%\DL\.ChannelNames.txt
    Loop, Parse, PodcastNamesText, `n`r
    {
        if (InStr(A_LoopField, ChannelName))
        {
            ChannelName:=StrSplit(A_LoopField, ","), Podcast:=ChannelName.2
            ;Msgbox % Podcast
            break
        }
        Else
            Podcast:=ChannelName
    }
    PodcastDir = %A_ScriptDir%\PodBlock\%Podcast%
    ;Msgbox % PodcastDir
}

ProcessSponsors()
{
    global
    SRTCount:=""
    Loop, Parse, SRTText_NoPunc, `n
    {
        SRTCount++
        if (InStr(A_LoopField, FileStart))
        {
            LineGrabTimestamp()
            ;Msgbox % FileStart
            AdStart:=Start, AdStartTS:=Start, AdInit:="1", SRTCountInit:=SRTCount
        }
        if (InStr(A_LoopField, FileEnd)) && if (AdInit=1) && if (SRTCount > SRTCountInit)
        {
            LineGrabTimestamp()            
            AdEnd:=End, AdInit:="0", SRTCountInit:="0"
            ;Msgbox %A_LoopFileName% %AdStart% - %AdEnd%
            FileAppend, %AdStart% - %AdEnd%`t`t`t%A_LoopFileName%`n, Log.txt
            FileAppend, `n%AdStart%`n%AdEnd%, output.txt
            ;Break
        }
    }
    ;Msgbox %AdStart%`n%AdEnd%
}

LineGrabTimestamp()
{
    global
    Line:=SRTCount - 1
    FileReadLine, TimeStamp, %SRTFile%, %Line%
    ;Msgbox % TimeStamp
    Parts:=StrReplace(TimeStamp, ",", "."), Parts:=StrSplit(Parts, " --> ")
    Start:=Parts.1, End:=Parts.2
}

CombineTimestamps()
{
    global
    FileRead, TimestampOutput, output.txt
    ;Sort, TimestampOutput, U
    TimestampOutput:=Trim(TimestampOutput, "`n`r")
    FileRecycle, output.txt
    ;Msgbox % TimestampOutput
    FileAppend, %TimestampOutput%, output.txt
    ConvertCompressedToSeconds()
    LineCompare(TimestampOutput)
    
}

ConvertCompressedToSeconds()
{
    global
    FileRead, Compressed, Output.txt
    ;Msgbox % Compressed
    ;FileRecycle, output.txt
    LineNo1:=1
    Loop, Parse, Compressed, `n
    {
        FileReadLine, LineCompareA, output.txt, %LineNo1%
        If (Ext=".en-US.vtt")
        {
            ;Msgbox % Ext
            LineCompare1 := StrReplace(LineCompareA, ".", ":")
            LineCompare1 := StrSplit(LineCompare1, ":")
            If (LineCompare1.4 != "")   ;checks if hours stamp exists
                Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + LineCompare1.3 + (LineCompare1.4 / 1000)
            Else
            {
                Line1_total:=(LineCompare1.1 * 60) + LineCompare1.2 + (LineCompare1.3 / 1000)
                ;Msgbox % Line1_total
            }
        }

        If (Ext=".srt")
        {
            ;Msgbox % Ext
            LineCompare1 := StrSplit(StrReplace(LineCompareA, ",", ":"), ":")
            If (LineCompare1.4 != "")   ;checks if hours stamp exists
                Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + (LineCompare1.3) + (LineCompare1.4 / 1000)
            Else
                Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + (LineCompare1.3)
        }

        ;Msgbox %Line1_total%
        Output .= Line1_total "`n"
        LineNo1++
        ;Msgbox % Output
    }
    FileRecycle, Output.txt
    TimestampOutput:=Trim(Output, "`n`r")
    ;Msgbox % Output
    ;Sort, TimestampOutput, U
    FileAppend, %TimestampOutput%, output.txt
}

LineCompare(TimestampOutput)
{
    global
    FileRecycle, Output.txt
    TimestampOutput:=RegExReplace(TimestampOutput, "(\R)+", "$1")
    ;Msgbox %TimestampOutput%
    FileAppend, %TimestampOutput%, output.txt
    FileAppend, %LineCompareB%, output.txt
return
}

ProcessIntroOutro()
{
    global
    FileRead, Outro, %PodcastDir%\Outro.txt
    FileRead, Intro, %PodcastDir%\Intro.txt
    ;Msgbox %PodcastDir%\Outro.txt
    ;Msgbox % Outro "`n`n" Intro
    Loop, Parse, Intro, `n`r
    {
        Intro:=A_LoopField
        Loop, Parse, SRTText_NoPunc, `n
        {
            if (Intro != "") && if (InStr(A_LoopField, Intro))
            {
                ;Msgbox % Intro
                IntroOutroGuts()
                ;Msgbox % Line1_total
                FileAppend, `n0.000000, output.txt
                FileAppend, `n%Line1_total%, output.txt
                FileAppend, %Start% - %End%`t`t`tIntro.txt`n, Log.txt
                Break 2
            }
        }
    }
    Loop, Parse, Outro, `n`r
    {
        Outro:=A_LoopField
        ;Msgbox % Outro
        Loop, Parse, SRTText_NoPunc, `n
        {
            if (Outro != "") && if (InStr(A_LoopField, Outro))
            {
                ;Msgbox % Outro
                IntroOutroGuts()
                ;Msgbox % Line1_total
                FileAppend, `n%Line1_total%, output.txt
                FileAppend, `n99999, output.txt
                FileAppend, %Start% - 99999`t`t`t`tOutro.txt`n, Log.txt
                Break 2
            }
        }
    }
    ;Msgbox Out %Line1_total% `nIn %IntroStart%
    FileRead, TimestampOutput, output.txt
    TimestampOutput:=Trim(TimestampOutput, "`n`r")
    ;Sort, TimestampOutput, N
    FileRecycle, output.txt
    FileAppend, %TimestampOutput%, output.txt
}

IntroOutroGuts()
{
    global
    Line := A_Index - 1
    ;Msgbox %Line%
    FileReadLine, TimeStamp, %SRTFile%, %Line%
    Parts:=StrReplace(TimeStamp, ",", "."), Parts:=StrSplit(Parts, " --> ")
    Start:=Parts.1, End:=Parts.2

    if (Intro != "") && if (InStr(A_LoopField, Intro))
        GutsMode:=End
    if (Outro != "") && if (InStr(A_LoopField, Outro))
        GutsMode:=Start
    
    ;Msgbox %End% %ext%
    If (Ext=".en-US.vtt")
    {
        ;Msgbox % Ext
        LineCompare1 := StrSplit(StrReplace(GutsMode, ".", ":"), ":")
        ;Msgbox % LineCompare1.4
        If (LineCompare1.4 != "")   ;checks if hours stamp exists
        {
            Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + LineCompare1.3 + (LineCompare1.4 / 1000)
            ;Msgbox % Line1_total " no"
        }
        Else
        {
            Line1_total:=(LineCompare1.1 * 60) + LineCompare1.2 + (LineCompare1.3 / 1000)
            ;Msgbox % Line1_total
        }
    }
    If (Ext=".srt")
    {
        ;Msgbox % Ext
        LineCompare1 := StrSplit(StrReplace(GutsMode, ",", ":"), ":")
        If (LineCompare1.4 != "")   ;checks if hours stamp exists
            Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + (LineCompare1.3) + (LineCompare1.4 / 1000)
        Else
            Line1_total:=(LineCompare1.1 * 3600) + (LineCompare1.2 * 60) + (LineCompare1.3)
    } 
}

FFMpeg()
{
    global
    FileRead, Output, output.txt
    FileRead, LogFile, Log.txt
    Sort, LogFile
    FileRecycle, Log.txt
    FileAppend, %LogFile%, Log.txt
    FileAppend, `n%Mp3File%, Log.txt
    
    FFMpegTS:="", Num:="0"
    Loop, Parse, Output, `n
    {
        If (A_Index > 1)
        {
            If (Num=1)
                FFMpegTS .= "`," A_LoopField ")", Num:=0
            Else
                FFMpegTS .= "+between(t`," A_LoopField, Num:=1
        }
        Else
            FFMpegTS .= "between(t`," A_LoopField, Num:=1
    }
    FFMpegTS:=RegExReplace(FFMpegTS, "(\R)+")
    ;Msgbox %FFMpegTS%
    Run, %comspec% /k "ffmpeg -hwaccel cuda -i %Mp3file% -map_metadata 0 -af "aselect='not(%FFMpegTS%)'" Output\.Waiting2Import\%Podcast%\%Mp3File%"
    Try Run, Log.txt
    Msgbox Finish Conversion.
    WinClose, cmd.exe
    WinClose, AdSniffer.ahk
    FileMove, %Mp3File%, %A_ScriptDir%\Archive\%Podcast%
    FileMove, %SRTFile%, %A_ScriptDir%\Archive\%Podcast%
}