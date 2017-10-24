@echo off
%~d0
set currentDir=%~dp0
cd %M2_REPO%

del  *.lastUpdated /f /s /q /a
del  *.lock /f /s /q /a
cd %currentDir%


rem for /f "delims=" %%i in ('dir /b /s "%M2_REPO%\*lastUpdated*"') do (
rem     del /s /q %%i
rem )
rem pause

rem linux
rem find $M2_REPO -name "*lastUpdated*" | xargs rm -rf