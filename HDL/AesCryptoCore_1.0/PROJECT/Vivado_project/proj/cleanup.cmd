@echo off
rem delete all files from subfolders
#for /d /r %%i in (*) do del /f /q %%i\*
rem delete all subfolders
#for /d %%i in (*) do rd /S /Q %%i

rem unmark read only from all files
#attrib -R .\* /S

rem mark read only those we wish to keep
attrib +R .\create_project.tcl
attrib +R .\cleanup.sh
attrib +R .\cleanup.cmd
attrib +R .\.gitignore

rem delete all non read-only
del /Q /A:-R .\*

rem unmark read-only
attrib -R .\*

