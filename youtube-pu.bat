::----------------
::    SETTINGS
::----------------

@echo off
set _buildpath=%TEMP%\youtube-dl_update
set _default_youtube-dl_path=C:\Path\youtube-dl.exe
set _cmdow=true
set _update_pyinstaller
set _pull_patches=25296_24649

::--------------
::    SCRIPT
::--------------

if [true]==[%_cmdow%] cmdow @ /MAX
echo [7mControllo aggiornamenti...[0m
for /F "tokens=*" %%g in ('where youtube-dl 2^> nul') do (set _localpath=%%g)
if []==[%_localpath%] set _localpath=%_default_youtube-dl_path%
for /F "tokens=*" %%h in ('curl -sS -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ytdl-org/youtube-dl/releases/latest ^| jq -r .tag_name') do (set _currentversion=%%h)
if NOT exist %_localpath% goto:install
for /F "tokens=*" %%g in ('%_localpath% --version') do (set _localversion=%%g)
if NOT %_currentversion% == %_localversion% (goto:update) ELSE (goto:noupdate)
:install
set _installmode=0
choice /M "Sembra che youtube-dl non sia presente nel sistema. Vuoi installare la versione (%_currentversion%)"
if %ERRORLEVEL% EQU 2 goto :end
goto:build
:update
set _installmode=1
echo Ô disponibile una nuova versione! (%_localversion% --^> %_currentversion%)
choice /M "Vuoi eseguire l'aggiornamento"
if %ERRORLEVEL% EQU 2 goto :end
goto:build
:build
md %_buildpath%
echo [7mDownload in corso...[0m
set _sourcefoldername=youtube-dl_%_currentversion%
git clone -b %_currentversion% https://github.com/ytdl-org/youtube-dl.git %_buildpath%\%_sourcefoldername%
echo [7mApplicazione patch...[0m
pushd %_buildpath%\%_sourcefoldername%
for
git pull origin pull/25296/head
popd
echo [7mCompilazione applicazione...[0m
python -m pip install --upgrade pyinstaller > nul
pyinstaller %_buildpath%\%_sourcefoldername%\youtube_dl\__main__.py --log-level ERROR --onefile --name youtube-dl --specpath %_buildpath% --distpath %_buildpath%\dist --workpath %_buildpath%\build
echo [0m
echo [7mControllo eseguibile...[0m
for /F "tokens=*" %%k in ('%_buildpath%\dist\youtube-dl.exe --version') do (set _newversion=%%k)
if NOT [%_currentversion%] == [%_newversion%] goto:problem
echo [7mOperazioni finali...[0m
move /Y %_buildpath%\dist\youtube-dl.exe %_localpath% > nul
rd /S /Q %_buildpath%
if %_installmode% == 1 (echo Aggiornamento completato!) else (echo Installazione completata!)
goto:end
:problem
echo [41;97mQualcosa Š andato storto :-([0m
echo Premi invio per cancellare i file temporanei
pause
rd /S /Q %_buildpath%
goto:end
:noupdate
set _installmode=2
echo youtube-dl Š aggiornato! (%_currentversion%)
goto:end
:end
pause