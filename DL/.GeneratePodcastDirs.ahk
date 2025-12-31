Import:
{
#Requires AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
DetectHiddenWindows, On
SetTitleMatchMode, RegEx
}

ParentDir:=StrReplace(A_ScriptDir, "\DL",,,1)
InputBox, Podcast, Podcast Name:,,, 200, 100
FileCreateDir, %ParentDir%\Archive\%Podcast%
FileCreateDir, %ParentDir%\DL\Queue\%Podcast%
FileCreateDir, %ParentDir%\Output\%Podcast%
FileCreateDir, %ParentDir%\Output\.Waiting2Import\%Podcast%
FileCreateDir, %ParentDir%\PodBlock\%Podcast%
FileCreateDir, %ParentDir%\PodBlock\%Podcast%\Sponsors
FileAppend,, %ParentDir%\PodBlock\%Podcast%\Outro.txt
FileAppend,, %ParentDir%\PodBlock\%Podcast%\Intro.txt

Msgbox Done.
ExitApp