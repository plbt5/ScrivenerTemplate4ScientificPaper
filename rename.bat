@ECHO OFF

:: ==============
:: Clone and rename the Scrivener project to your likings
::
:: Usage:  RENAME  myProjectName [git@host:user, e.g., git@github.com:user]
::   
::Note: Do not append repo name ('myProjectName') with slash (/)!
:: ==============

:: Check Windows version
SET Error=This batch file requires Windows XP or later
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
SET Error=

SETLOCAL

:: Configurations
SET "ScrivStarterRepo=https://github.com/plbt5/ScrivenerTemplate4ScientificPaper.git"
SET "RemoteRepo="
SET "fname=starter"

:: Check command line arguments
IF     "%~1"=="" GOTO Syntax
IF NOT "%~2"=="" SET "RemoteRepo=%~2"
 
::
:: Check if git command is available
::
WHERE git
IF %ERRORLEVEL% NEQ 0 (
	SET Error=Cannot find the git command
	GOTO Syntax
)

::
:: Check if cloned git project exists and provides for the expected template files
::
IF NOT EXIST "%fname%.scriv\%fname%.scrivx"	 (
	SET /P answer=Clone the Scrivener Starter Project now [y/n]?
	IF "%answer%"=="y" CALL :ScrivGitClone
	ELSE (
		SET Error=Cannot find the expected file (%fname%.scriv) in this git project
		GOTO Syntax
	)
)

::
:: Rename the project.
::
set "newname=%~1"
git mv -- %fname%.scriv %newname%.scriv
git mv -- %newname%.scriv\%fname%.scrivx %newname%.scriv\%newname%.scrivx

::
:: Open with Scrivener and save.
::
ECHO.
ECHO Hit any key to open your '%newname%' Scrivener project and 
ECHO   (1) Select the 'meta-data' item in the Binder
ECHO   (2) Modify the YAML-block to reflect the title, author(s) and more
ECHO Then, come back here to update git!
SET /P answer=<hit any key to open '%newname%'>
start .\%newname%.scriv\%newname%.scrivx
timeout 5
ECHO.
SET /P answer=<hit any key to start updating git>

::
:: Update git with the latest changes
::
git add -u
git commit -m "Initialised Scrivener project as %newname%.scriv, modified YAML meta-data"
ECHO.
ECHO Committed changes to %newname%
ECHO.

::
:: Push to remote
::
IF "%RemoteRepo%"=="" (
	ECHO Adding a remote git server to this local repo:
	SET /P RemoteRepo=Enter the remote git url for %newname% (e.g., https://github.com/user), or <return> to skip
	IF "%RemoteRepo%"=="" GOTO Getlost
)
ELSE ECHO Adding %RemoteRepo% as remote to this local repo:
git remote add origin %RemoteRepo%/%newname%.git
git push

::
:: Create and checkout branch 'dev'
::
ECHO.
ECHO Creating and checking out branch 'dev'
git branch dev
git checkout dev
ECHO.
ECHO Succeeded!
GOTO Getlost

::
:: Subroutines and closure
::

:ScrivGitClone
git clone %ScrivStarterRepo%
GOTO :eof

:Syntax

IF NOT "%Error%"=="" ECHO.
IF NOT "%Error%"=="" ECHO Error: %Error%
SET Error=

ECHO.
ECHO rename.bat,  Version 0.1 for Windows XP and later
ECHO Clone and rename the Scrivener project to your likings
ECHO.
ECHO Usage:  RENAME  myRepoName [git@host:user, e.g., git@github.com:user]
ECHO   Do not append repo name with slash (/)!
ECHO.
ECHO Written by Paul Brandt, TNO, The Netherlands
ECHO Acknowledging: 
ECHO   Rob van der Woude: bat-scripting techniques (http://www.robvanderwoude.com) 
ECHO   Roy Liu: Scrivener Starter Repository (https://github.com/carsomyr/scrivener_starter)

:Getlost
IF "%OS%"=="Windows_NT" ENDLOCAL
