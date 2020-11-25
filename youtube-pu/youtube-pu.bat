@echo off
:: Youtube-pu
:: By ThePirate42, 2020
:: Source: https://github.com/ThePirate42/youtube-pu
set _version=git

:: Settings loading

if NOT exist %~dp0youtube-pu.conf echo youtube-pu.conf not found! & goto :end
setlocal EnableDelayedExpansion
for /F "tokens=*" %%g in (%~dp0youtube-pu.conf) do (%%g)
endlocal & set "_buildpath=%_buildpath%" & set "_default_youtube-dl_path=%_default_youtube-dl_path%" & set "_enable_cmdow=%_enable_cmdow%" & set "_update_pyinstaller=%_update_pyinstaller%" & set "_pull_patches=%_pull_patches%" & set "_python_version=%_python_version%"

:: Dependency check

for /F "tokens=*" %%g in ('where jq 2^> nul') do (set _jqpath=%%g)
if ""=="%_jqpath%" echo jq not found! & goto :end
for /F "tokens=*" %%g in ('where curl 2^> nul') do (set _curlpath=%%g)
if ""=="%_curlpath%" echo curl not found! & goto :end
for /F "tokens=*" %%g in ('where git 2^> nul') do (set _gitpath=%%g)
if ""=="%_gitpath%" echo git not found! & goto :end
for /F "tokens=*" %%g in ('where py 2^> nul') do (set _pypath=%%g)
if ""=="%_pypath%" echo py not found! & goto :end
setlocal EnableDelayedExpansion
if NOT ""=="%_python_version%" (
set "_pyver= -%_python_version%"
for /F "tokens=*" %%g in ('py!_pyver! -c "print(""test"")" 2^> nul') do (set _python_test=%%g)
if NOT "test"=="!_python_test!" echo Python v%_python_version% not found^^! & goto :end
)
endlocal & set "_pyver=%_pyver%"
for /F "tokens=*" %%g in ('py%_pyver% -c "import os, sys; print(os.path.dirname(sys.executable))"') do (set _pyinstallerpath=%%g\Scripts\pyinstaller.exe)
if NOT "true"=="%_update_pyinstaller%" (if NOT exist "%_pyinstallerpath%" echo pyinstaller not found! & goto :end )
for /F "tokens=*" %%g in ('where cmdow 2^> nul') do (set _cmdowpath=%%g)
if "true"=="%_enable_cmdow%" (if ""=="%_cmdowpath%" echo cmdow not found! & goto :end )
if exist "%_buildpath%" echo The build folder already exists! & goto :end

:: "cmdow @ /MAX" maximizes the window, you can disabe it from the configuration

if "true"=="%_enable_cmdow%" cmdow @ /MAX

:: Check for youtube-pu updates

for /F "tokens=*" %%h in ('curl -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/thepirate42/youtube-pu/releases/latest ^| jq -r .tag_name') do (set _currentscriptversion=%%h)
if NOT %_version%==git (if NOT %_version%==%_currentscriptversion% echo A new youtube-pu version [%_currentscriptversion%] is available!)

:: I know, the following code contains too much goto, sorry!

echo [7mChecking for updates...[0m
for /F "tokens=*" %%g in ('where youtube-dl 2^> nul') do (set _localpath=%%g)
if ""=="%_localpath%" set _localpath=%_default_youtube-dl_path%
for /F "tokens=*" %%h in ('curl -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest ^| jq -r .tag_name') do (set _currentversion=%%h)
if NOT exist "%_localpath%" goto :install
for /F "tokens=*" %%g in ('"%_localpath%" --version') do (set _localversion=%%g)
if NOT %_currentversion% == %_localversion% (goto :update ) ELSE (goto :noupdate )
:install
set _installmode=0
choice /M "It seems that youtube-dl isn't present in the system. Do you want to install version (%_currentversion%) in (%_localpath%)"
if %ERRORLEVEL% EQU 2 goto :end
goto :build
:update
set _installmode=1
echo A new version is available! (%_localversion% --^> %_currentversion%)
choice /M "Do you want to update"
if %ERRORLEVEL% EQU 2 goto :end
goto :build
:build
md "%_buildpath%"
echo [7mDownloading...[0m
set _sourcefoldername=youtube-dl_%_currentversion%
git clone -b %_currentversion% https://github.com/ytdl-org/youtube-dl.git "%_buildpath%\%_sourcefoldername%"
if NOT ""=="%_pull_patches%" (
echo [7mPatching...[0m
pushd "%_buildpath%\%_sourcefoldername%"
for %%g in ("%_pull_patches:_=" "%") do (
git pull origin pull/%%~g/head
)
popd
)
echo [7mCompiling...[0m
if "true"=="%_update_pyinstaller%" py%_pyver% -m pip install --upgrade pyinstaller > nul
"%_pyinstallerpath%" "%_buildpath%\%_sourcefoldername%\youtube_dl\__main__.py" --log-level WARN --onefile --name youtube-dl --specpath "%_buildpath%" --distpath "%_buildpath%\dist" --workpath "%_buildpath%\build"
echo [0m
echo [7mChecking executable...[0m
for /F "tokens=*" %%g in ('"%_buildpath%\dist\youtube-dl.exe" --version') do (set _newversion=%%g)
if NOT "%_currentversion%" == "%_newversion%" goto :problem
echo [7mFinal operations...[0m
move /Y "%_buildpath%\dist\youtube-dl.exe" "%_localpath%" > nul
rd /S /Q "%_buildpath%"
if %_installmode% == 1 (echo Update completed!) else (echo Installation completed!)
goto :end
:problem
echo [41;97mSomething has gone wrong :-([0m
echo Press enter to erase temporary files
pause
rd /S /Q "%_buildpath%"
goto :end
:noupdate
set _installmode=2
echo youtube-dl is up-to-date! (%_currentversion%)
goto :end
:end
pause