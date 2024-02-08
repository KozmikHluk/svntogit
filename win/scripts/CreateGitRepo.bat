@ECHO OFF
ECHO -------------------------------------------------------------------
ECHO --  You are running the Export of SVN Data to the empty repo   ----
ECHO --                                                             ----
ECHO -------------------------------------------------------------------
setlocal enabledelayedexpansion
:VARIABLES
SET WRKDIR=D:\SVNtoGITScripts\SVNtoGitMigrationScript
SET EXPPATH=D:\s
::SET DEFAULTBRANCHID=main
SET MM=%DATE:~4,2%
SET DD=%DATE:~7,2%
SET YYYY=%DATE:~10,4%
SET UserAccount=%5
SET password=%6
SET BBInstance=%3
SET PROJ=%4
SET JIRAID=%7
ECHO %BBInstance%
ECHO %PROJ%
ECHO Variables have been set

IF %REPO_NAME%==TCSBI goto SVNtoGITMigration
IF %REPO_NAME%==ANYREPO goto NEWGITREPO
GOTO end

:SVNtoGITMigration
:: Updated delimeter from comma to semicolon due to customer names containing commas

FOR /f "tokens=1 delims=;" %%A in (%CD%\svnurl_%REPO_NAME%.txt) do (
SET OLD=%%A
SET NEWREPO=!OLD:~0,7!
ECHO Var: NEWREPO
ECHO !NEWREPO!
IF EXIST !NEWREPO! rd /S /Q !NEWREPO!
ECHO Var:NEWP
SET NEWP=!OLD:/=\!
ECHO !NEWP!
ECHO variable NEWP = !NEWP! > %CD%\ExportdataEscrow-%REPO_NAME%.log
ECHO !REPO_NAME!
ECHO Var:A
ECHO %%A
ECHO Var:OLD
ECHO !OLD!
::PAUSE
MKDIR !NEWREPO!
CD !NEWREPO!
dir
ECHO DIR1
::pause
IF NOT EXIST .gitattributes copy !CD!\..\GITATTRIBUTES\_gitattributes .gitattributes
IF NOT EXIST .gitignore copy !CD!\..\GITATTRIBUTES\_gitignore .gitignore
SET NEWREPOURL=%protocol%://%username%@%GITSERVERURL%:%urlstring%/!NEWREPO!

ECHO -------------- You are calling script to create repo on hosting platform ----
ECHO The Powershell call: powershell.exe -Command "& %CD%\CreateRepo.ps1 -username %username% -password %password% -BBInstance %BBInstance% -project %GITPROJ% -Repo !NEWREPO! -Desc !OLD! -defaultBranchId %DEFAULTBRANCHID%"
powershell.exe -Command "& %CD%\CreateRepo.ps1 -username %useraccount% -password %password% -BBInstance %BBInstance% -project %GITPROJ% -Repo !NEWREPO! -Desc '!OLD!' -defaultBranchId %DEFAULTBRANCHID%"

SET LFS=1
git init
git add .gitattributes
git add .gitignore
git commit * -m "JIRA ID: %JIRAID% New Repository"
git remote add origin !newrepourl!
git branch -m master main

IF NOT EXIST repoconfig.json copy !CD!\..\repoconfig.json repoconfig.json

git add .
git commit -m"JIRA ID: %JIRAID% New Repository"
git remote -v
git branch %DEFAULTBRANCHID%

git push --all
cd ..
IF EXIST !NEWREPO! rd /S /Q !NEWREPO!
)

GOTO END

:NEWGITREPO
:: Updated delimeter from comma to semicolon due to customer names containing commas
FOR /f "tokens=1 delims=;" %%A in (%CD%\svnurl_%REPO_NAME%.txt) do (
SET OLD=%%A
SET NEWREPO=!OLD!
ECHO Var: NEWREPO
ECHO !NEWREPO!
IF EXIST !NEWREPO! rd /S /Q !NEWREPO!
ECHO Var:NEWP
SET NEWP=!OLD:/=\!
ECHO !NEWP!
ECHO variable NEWP = !NEWP! > %CD%\ExportdataEscrow-%REPO_NAME%.log
ECHO !REPO_NAME!
ECHO Var:A
ECHO %%A
ECHO Var:OLD
ECHO !OLD!
MKDIR !NEWREPO!
CD !NEWREPO!
IF NOT EXIST .gitattributes copy !CD!\..\GITATTRIBUTES\_gitattributes .gitattributes
IF NOT EXIST .gitignore copy !CD!\..\GITATTRIBUTES\_gitignore .gitignore

SET NEWREPOURL=%protocol%://%username%@%GITSERVERURL%:%urlstring%/!NEWREPO!

ECHO The Powershell call: powershell.exe -Command "& %CD%\CreateRepo.ps1 -username %username% -password %password% -BBInstance %BBInstance% -project %GITPROJ% -Repo !NEWREPO! -Desc !OLD! -defaultBranchId %DEFAULTBRANCHID%"
powershell.exe -Command "& %CD%\CreateRepo.ps1 -username %useraccount% -password %password% -BBInstance %BBInstance% -project %GITPROJ% -Repo '!NEWREPO!' -Desc '!OLD!' -defaultBranchId %DEFAULTBRANCHID%"

SET LFS=1
git init
git add .gitattributes
git add .gitignore
git commit * -m "JIRA ID: %JIRAID% New Repository"
git remote add origin !newrepourl!
git branch -m master main

IF NOT EXIST repoconfig.json copy !CD!\..\repoconfig.json repoconfig.json

git add .
git commit -m"JIRA ID: %JIRAID% New Repository"
git remote -v
git branch %DEFAULTBRANCHID%

git push --all
cd ..
IF EXIST !NEWREPO! rd /S /Q !NEWREPO!
)

GOTO END

:CheckLFS
ECHO LFS Checkpoint
ECHO Var LFS=%LFS%
::PAUSE
IF EXIST .gitattributes GOTO SVNExtract

IF NOT EXIST .gitattributes copy %CD%\..\GITATTRIBUTES\_gitattributes .gitattributes
SET LFS=1
IF NOT EXIST .gitattributes GOTO ERROR2
GOTO END

:StandardRepoTrunk
GOTO GITOPS

:END

