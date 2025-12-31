REM Needs list downloads
REM Needs auto channel downloader // download after dates once all caught up

:START
cls
@echo Enter File
@echo off
REM set /p File=
set File=.Queue
yt-dlp.exe -a "%cd%\Queue\%File%.txt" --download-archive .Archive.txt -x -t mp3 --sponsorblock-remove "sponsor, intro, outro, selfpromo, music_offtopic" --write-auto-subs --sub-format srt --embed-thumbnail --add-metadata -o "%%(uploader)s-%%(upload_date)s-%%(title)s.%%(ext)s"
pause
GOTO START