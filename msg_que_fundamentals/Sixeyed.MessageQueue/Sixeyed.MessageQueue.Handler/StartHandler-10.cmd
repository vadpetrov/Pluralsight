@echo off
cd bin\debug
for %%i in (1 2 3 4 5 6 7 8 9 10) do start "Message Handler-%%i" Sixeyed.MessageQueue.Handler.exe