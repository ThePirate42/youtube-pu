@echo off
:: By ThePirate42, 2020
:: Source: https://github.com/ThePirate42/youtube-pu

:: Settings loading

for /F "tokens=*" %%g in (youtube-pu.conf) do (%%g)

:: Dependency check

for /F "tokens=*" %%g in ('where jq 2^> nul') do (set _jqpath=%%g)
if ""=="%_jqpath%" echo jq not found! & goto :eof
for /F "tokens=*" %%g in ('where curl 2^> nul') do (set _curlpath=%%g)
if ""=="%_curlpath%" echo curl not found! & goto :eof
for /F "tokens=*" %%g in ('where git 2^> nul') do (set _gitpath=%%g)
if ""=="%_gitpath%" echo git not found! & goto :eof
for /F "tokens=*" %%g in ('where py 2^> nul') do (set _pypath=%%g)
if ""=="%_pypath%" echo py not found! & goto :eof
for /F "tokens=*" %%g in ('py -c "import os, sys; print(os.path.dirname(sys.executable))"') do (set _pyinstallerpath=%%g\Scripts\pyinstaller.exe)
if NOT [true]==[%_update_pyinstaller%] (if ""=="%_pyinstallerpath%" echo pyinstaller not found! & goto :eof)
for /F "tokens=*" %%g in ('where cmdow 2^> nul') do (set _cmdowpath=%%g)
if [true]==[%_enable_cmdow%] (if ""=="%_cmdowpath%" echo cmdow not found! & goto :eof)
if exist "%_buildpath%" echo The build folder already exists! & goto :eof

:: "cmdow @ /MAX" maximizes the window, you can disabe it from the configuration

if [true]==[%_enable_cmdow%] cmdow @ /MAX

:: I know, the following code contains too much goto, sorry!

echo [7mChecking for updates...[0m
for /F "tokens=*" %%g in ('where youtube-dl 2^> nul') do (set _localpath=%%g)
if ""=="%_localpath%" set _localpath=%_default_youtube-dl_path%
for /F "tokens=*" %%h in ('curl -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest ^| jq -r .tag_name') do (set _currentversion=%%h)
if NOT exist "%_localpath%" goto:install
for /F "tokens=*" %%g in ('"%_localpath%" --version') do (set _localversion=%%g)
if NOT %_currentversion% == %_localversion% (goto:update) ELSE (goto:noupdate)
:install
set _installmode=0
choice /M "It seems that youtube-dl isn't present in the system. Do you want to install version (%_currentversion%) in (%_localpath%)"
if %ERRORLEVEL% EQU 2 goto :end
goto:build
:update
set _installmode=1
echo A new version is available! (%_localversion% --^> %_currentversion%)
choice /M "Do you want to update"
if %ERRORLEVEL% EQU 2 goto :end
goto:build
:build
md "%_buildpath%"
echo [7mDownloading...[0m
set _sourcefoldername=youtube-dl_%_currentversion%
git clone -b %_currentversion% https://github.com/ytdl-org/youtube-dl.git "%_buildpath%\%_sourcefoldername%"
echo [7mPatching...[0m
pushd "%_buildpath%\%_sourcefoldername%"
for %%g in ("%_pull_patches:,=" "%") do (
git pull origin pull/%%~g/head
)
popd
echo [7mCompiling...[0m
if [true]==[%_update_pyinstaller%] py -m pip install --upgrade pyinstaller > nul
"%_pyinstallerpath%" "%_buildpath%\%_sourcefoldername%\youtube_dl\__main__.py" --log-level ERROR --onefile --name youtube-dl --specpath "%_buildpath%" --distpath "%_buildpath%\dist" --workpath "%_buildpath%\build"
echo [0m
echo [7mChecking executable...[0m
for /F "tokens=*" %%g in ('"%_buildpath%\dist\youtube-dl.exe" --version') do (set _newversion=%%g)
if NOT [%_currentversion%] == [%_newversion%] goto:problem
echo [7mFinal operations...[0m
move /Y "%_buildpath%\dist\youtube-dl.exe" "%_localpath%" > nul
rd /S /Q "%_buildpath%"
if %_installmode% == 1 (echo Update completed!) else (echo Installation completed!)
goto:end
:problem
echo [41;97mSomething has gone wrong :-([0m
echo Press enter to erase temporary files
pause
rd /S /Q "%_buildpath%"
goto:end
:noupdate
set _installmode=2
echo youtube-dl is up-to-date! (%_currentversion%)
goto:end
:end
pause