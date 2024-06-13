@echo off
@setlocal DisableDelayedExpansion
@set kidver=V1.5.4
set "params=%*"

:main
title Kidou_Software %kidver%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 0 /f
cls
powershell Checkpoint-Computer -Description "Utilisation-du-script-de-Kidou" -RestorePointType MODIFY_SETTINGS
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 1440 /f
cls

:menu
cd %USERPROFILE%\Desktop
cls
echo ===============================================================
echo                  Kidou_Software - Menu Principal
echo ===============================================================
echo.
echo 1. Reparation de Windows (Automatique)                      
echo 2. Nettoyage de Windows
echo 3. Acces au bios (Automatique)                                   
echo 4. Scan antivirus avance (Automatique, Windows Defender requis)         
echo 5. Activation Windows 10/11 et Office (Script externe)           
echo 6. Mode sans echec de Windows (Automatique)
echo 7. Menu suppression d'application
echo 8. Information pc
echo 0. Quitter
echo.                                                  
echo ===============================================================
echo.

set /p choice=Choisissez une option et faites "Entrer" : 

if "%choice%"=="1" goto option1
if "%choice%"=="2" goto option2
if "%choice%"=="3" goto option3
if "%choice%"=="4" goto option4
if "%choice%"=="5" goto option5
if "%choice%"=="6" goto option6
if "%choice%"=="7" goto option7
if "%choice%"=="8" goto option8
if "%choice%"=="0" goto option99

goto menu

:option1
cls
echo.
echo Vous avez choisi l'option "Reparation du systeme".
echo.
timeout /t 4 >nul
cls
echo.
echo Maintenant, il faudra laisser le PC tranquille jusqu'a
echo l'arrivee au bureau de Windows ou a la page de connexion.
timeout /t 15 >nul
cls
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute /t REG_MULTI_SZ /d "autocheck autochk /r \??\C:\0autocheck autochk *" /f
cls
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v AutoChkTimeout /t REG_DWORD /d 1 /f
cls
echo.
sfc /scannow
cls
echo.
DISM /Online /Cleanup-Image /RestoreHealth
cls
echo.
goto reboot

:option2
cls
echo.
echo Vous avez choisi l'option "Nettoyage du systeme"
timeout /t 4 >nul
cls
echo.
echo Selectionnez toutes les cases puis cliquez sur "OK"
echo.
timeout /t 4 >nul
cleanmgr /c
cls
del /s /q %SystemRoot%\SoftwareDistribution\Download\*
cls
netsh int ip reset
netsh winsock reset
cls
echo.
echo Nettoyage du systeme terminee.
echo.
pause
cls
echo.
goto menu

:option3
cls
echo.
echo Vous avez choisi l'option "Acces au bios".
timeout /t 4 >nul
cls
echo.
echo Merci de patienter...
timeout /t 2 >nul
cls
echo.
shutdown.exe /r /fw /t 0
exit

:option4
cls
echo.
echo Vous avez choisi l'option "Scan antivirus".
timeout /t 4 >nul
cls
setlocal
sc query WinDefend | find "STATE" | find "RUNNING" > nul
if %errorlevel% equ 0 (
    echo.
    echo Super, Vous avez Windows Defender d'active.
    timeout /t 5 >nul
    cls
    echo.
    echo Ce scan peut prendre beaucoup de temps suivant la configuration du pc
    timeout /t 10 >nul
    cls
    echo.
    echo Maintenant, il faudra laisser le PC tranquille jusqu'a
    echo l'arrivee au bureau de Windows ou a la page de connexion.
    timeout /t 15 >nul
    cls
    echo.
    powershell -Command "Start-MpWDOScan"
    exit
) else (
    echo.
    echo Desoles, Vous n'avez pas Windows Defender d'active.
    echo.
    pause
    goto menu
)

endlocal

:option5
cls
echo.
echo Vous avez choisi l'option "Activation Windows 10/11 et Office".
timeout /t 4 >nul
cls
echo.
echo le script suivant a ete cree par massgrave, plus d'information sur le site officiel : massgrave.dev
timeout /t 10 >nul
echo.
echo Changement de script en cours
echo.
powershell -Command "irm https://massgrave.dev/get | iex"
exit

:option6
cls
echo.
echo Vous avez choisi l'option "Mode sans echec de Windows".
timeout /t 4 >nul
cls
echo.
echo Pour pouvoir quitter le mode sans echec, il faudra ouvrir le script
echo "WindowsNormal" qui se trouvera sur le bureau de votre ordinateur.
timeout /t 15 >nul

echo.
echo Merci de patienter...
echo.

timeout /t 2 >nul

cd %USERPROFILE%\Desktop

(
echo @echo off
echo bcdedit /deletevalue {current} safeboot
echo shutdown /r /t 5 /c "Desactivation du mode sans echec en cours..."
echo del WindowsNormal.cmd
echo exit
)>"WindowsNormal.cmd"

bcdedit /set {current} safeboot network
shutdown /r /t 5 /c "Activation du mode sans echec en cours..."
exit

:option7
cls
echo ========================================================
echo      Kidou_Software - Menu Suppression D'application
echo ========================================================
echo.
echo 1. Suppression de Edge (Automatique)                      
echo 2. Suppression de Onedrive (Automatique)
echo 0. Menu Principal
echo.                                                  
echo ========================================================
echo.

set /p choice=Choisissez une option et faites "Entrer" : 

if "%choice%"=="1" goto edge
if "%choice%"=="2" goto onedrive
if "%choice%"=="0" goto menu

goto option7

:edge
cls
echo.
echo Vous avez choisi l'option "Suppression de Edge".
timeout /t 4 >nul

if exist "C:\Program Files (x86)\Microsoft\Edge\Application" (
    goto edgeclean
) else (
    echo Edge est deja désinstalle
    pause
    goto menu
)

:edgeclean
cls
cd /d "C:\Program Files (x86)\Microsoft\Edge\Application"
set "max_version="
set "max_version_folder="

for /d %%i in (*) do (
    set "dir_name=%%~nxi"
    echo !dir_name!| findstr /r "^[0-9.]*$" >nul
    if not errorlevel 1 (
        if "!dir_name!" gtr "!max_version!" (
            set "max_version=!dir_name!"
            set "max_version_folder=%%i"
        )
    )
)

cd /d "%dir_name%\Installer"
setup.exe -uninstall -system-level -verbose-logging -force-uninstall
timeout /t 5 >nul
rmdir /s /q "C:\Program Files (x86)\Microsoft\Edge"
rmdir /s /q "C:\Program Files (x86)\Microsoft\EdgeUpdate"
rmdir /s /q "C:\Program Files (x86)\Microsoft\EdgeCore"
rmdir /s /q "C:\Program Files (x86)\Microsoft\Temp"
for /f "tokens=8 delims=\" %%T in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" ^| findstr "Microsoft-Windows-Internet-Browser-Package" ^| findstr "~~"') do (set "edge_legacy_package_version=%%T")
if defined edge_legacy_package_version (
		echo Removing %edge_legacy_package_version%...
		reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\%edge_legacy_package_version%" /v Visibility /t REG_DWORD /d 1 /f
		reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\%edge_legacy_package_version%\Owners" /va /f
		dism /online /Remove-Package /PackageName:%edge_legacy_package_version%
		powershell.exe -Command "Get-AppxPackage *edge* | Remove-AppxPackage" >nul
)
schtasks /Delete /TN "\MicrosoftEdgeUpdateBrowserReplacementTask" /F
schtasks /Delete /TN "\MicrosoftEdgeUpdateTaskMachineUA" /F
schtasks /Delete /TN "\MicrosoftEdgeUpdateTaskMachineCore" /F
sc config "edgeupdate" start=disabled
sc config "edgeupdatem" start=disabled
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f
timeout /t 5 >nul
rmdir /s /q "C:\Program Files (x86)\Microsoft\Edge"

goto menu

:onedrive
cls
echo.
echo Vous avez choisi l'option "Suppression de Onedrive".
timeout /t 4 >nul
cls

   echo --------------------------------------------------------
   echo                      AVERTISSEMENT"
   echo.
   echo   Ce script va supprimer completement et definitivement 
   echo.
   echo              OneDrive de votre ordinateur. 
   echo.
   echo       Assurez-vous que tous les documents OneDrive
   echo.
   echo      stockes localement sont sauvegardes entierement
   echo.
   echo                    avant de proceder.    
   echo.
   echo --------------------------------------------------------
   echo.

   SET /P M=  Appuyez sur 'Y' pour continuer ou sur n'importe quelle autre touche pour retourner au menu.
	if %M% ==Y goto PROCESSKILL
	if %M% ==y goto PROCESSKILL

goto menu

:PROCESSKILL
taskkill /f /im OneDrive.exe
rd "%UserProfile%\OneDrive" /s /q
rd "%LocalAppData%\Microsoft\OneDrive" /s /q
rd "%ProgramData%\Microsoft OneDrive" /s /q
rd "C:\OneDriveTemp" /s /q
del "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" /s /f /q
REG Delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
REG Delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
REG ADD "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f
cls
echo.
echo Desinstallation et nettoyage de OneDrive termines.
echo.
pause
goto menu

:option8
cls
for /f "tokens=2 delims==" %%a in ('wmic baseboard get product /value') do (
    set "modele=%%a"
)

for /f "tokens=2 delims==" %%b in ('wmic baseboard get manufacturer /value') do (
    set "marque=%%b"
)

for /f "tokens=2 delims==" %%c in ('wmic cpu get name /value') do (
    set "processeur=%%c"
)

for /f "tokens=2 delims==" %%d in ('wmic path win32_videocontroller get name /value') do (
    set "carte_graphique=%%d"
)

set "ram_total=0"
for /f %%e in ('powershell "(Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB"') do (
    set "ram_total=%%e"
)

echo Informations sur le systeme :
echo Marque de la carte mere : %marque%
echo Modele de la carte mere : %modele%
echo.
echo Composants principaux :
echo Processeur : %processeur%
echo Carte graphique : %carte_graphique%
echo RAM installee : %ram_total% Go
echo.
Pause
goto menu

:option99
exit

:reboot
shutdown /r /t 5 /c "Redemarrage en cours..."
exit
