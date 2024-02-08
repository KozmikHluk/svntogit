@ECHO OFF
ECHO -------------------------------------------------------------------
ECHO --  You are starting the SVN to Git migration                  ----
ECHO --  Call to Git Export                                         ----
ECHO --  performs push to the repo at end                           ----
ECHO -------------------------------------------------------------------

SET REPO_NAME=ANYREPO
::SET REPO_NAME=TCSBI
SET JIRAID=ROB-131
SET GITPROJ=TEST
SET DEFAULTBRANCHID=develop


SET BBInstance=<your-git-instance>
SET UserAccount=<service-account>
SET USERNAME=<service-account>
SET password=
SET REV=279741

:: Set this parameter to 0 to create empty git repos from within here.
:: Set this to 1 to migrate your svn repo to git.
SET SVNREPO=0
ECHO %SVNREPO%
::Set GITPROJ to the project key you are setting up
IF %REPO_NAME%==TCSBI SET GITPROJ=BI
IF %REPO_NAME%==ANYREPO SET GITPROJ=%GITPROJ%
ECHO %REPO_NAME%
::Enter the latest revision from the SVN Repo for the project.
IF %REPO_NAME%==TCSBI SET REV=3844928
::-----------------------------------------------------------------------
:: Setting default value for the Subversion server for standard repos
SET SVNSERVER=<url-to-svn-repo>
::SET SVNPRODURL=%SVNSERVER%/trunk/%REPO_NAME%
:: For special project svn extractions the case is added here.
IF %REPO_NAME%==TCSBI SET SVNREPO_NAME=TCS
IF %REPO_NAME%==TCSBI SET SVNPRODURL=%SVNSERVER%/%SVNREPO_NAME%/trunk
SET SVNextracted=0

ECHO -------------------------------------------------------------------
SET GITSERVERURL=%BBInstance%
ECHO %GITSERVERURL%
ECHO %REPO_NAME%
SET weburlstring=443/projects/%GITPROJ%/repos
SET PROTOCOL=https
IF %PROTOCOL%==https set urlstring=443/scm/%GITPROJ%
IF %PROTOCOL%==ssh set urlstring=7999/%GITPROJ%
IF %PROTOCOL%==ssh set USERNAME=git

ECHO %URLSTRING%
ECHO %GITPROJ%
ECHO %PROTOCOL%://%GITSERVERURL%:%URLSTRING%/%REPO_NAME%.git

ECHO %REV%
ECHO %SVNPRODURL%

GOTO SVNExtract

:CheckLFS
ECHO LFS Checkpoint
ECHO Var LFS=%LFS%
ECHO Var SVNExtracted=%SVNExtracted%
IF EXIST .gitattributes GOTO SVNExtract

SET LFS=1
IF NOT EXIST .gitattributes GOTO ERROR2
IF NOT EXIST .gitignore GOTO ERROR2

:SVNExtract
ECHO ---------------- You  are calling the next script --------------------

ECHO SVNExtract Var SVNExtracted=%SVNExtracted%
ECHO CALL %CD%\CreateGitRepo.bat "%CD%\svnurl_%REPO_NAME%.txt" "%REV%" "%BBInstance%" "%GITPROJ%" "%useraccount%" "*****"
ECHO ----------------------------------------------------------------------
CALL %CD%\CreateGitRepo.bat "%CD%\svnurl_%REPO_NAME%.txt" "%REV%" "%BBInstance%" "%GITPROJ%" "%useraccount%" "%password%" "%JIRAID%"

SET SVNextracted=1
IF %SVNextracted%==0 GOTO ERROR1
ECHO Var SVNExtracted=%SVNExtracted%
IF %SVNextracted%==1 GOTO MoveFiles
GOTO CheckLFS

:MoveFiles
SET MM=%DATE:~4,2%
SET DD=%DATE:~7,2%
SET YYYY=%DATE:~10,4%

ECHO MoveFiles Completed
GOTO END

:ERROR1
ECHO SVN Extract did not completed: Value %SVNextracted%
ECHO To Try again after you fixed issue press any key or press CTRL-C to quit.
GOTO SVNExtract
:ERROR2
ECHO LFS attributes did not completed: 
ECHO To Try again after you fixed issue press any key or press CTRL-C to quit.
GOTO END
:END

ECHO Extraction Completed
