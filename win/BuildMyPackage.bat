@ECHO OFF

SET WorkingDir=D:\projects\zNewGitRepo

::===========================
MKDIR "%WorkingDir%"
XCOPY /D /E /I "%CD%\Scripts\*" "%WorkingDir%"
XCOPY /D /E /I "%CD%\Files\*" "%WorkingDir%"

:END
