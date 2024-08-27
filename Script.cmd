

@setlocal DisableDelayedExpansion
@set kidver=V1.5.5 DEV
set "params=%*"

:main
title Kidou_Software %kidver%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 0 /f
cls
echo.
echo Sauvegarde rapide du systeme
echo.
powershell Checkpoint-Computer -Description "Utilisation-du-script-Dev-de-Kidou" -RestorePointType MODIFY_SETTINGS
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v SystemRestorePointCreationFrequency /t REG_DWORD /d 1440 /f
cls
set "hostspath=%windir%\System32\drivers\etc\hosts"
set "tempfile=%temp%\hosts_tmp"

setlocal

set "folder=C:\Kidou"
set "file=Telemetry"

if not exist "%folder%\%file%" (
    set "status=[31mDesactiver[0m"
) else (
    set "status=[32mActiver[0m"
)


:menu
cd %USERPROFILE%\Desktop
cls
echo ===============================================================
echo                 Kidou_Software - Menu Principal
echo ===============================================================
echo.
echo 1.  Reparation de Windows (Automatique)                      
echo 2.  Nettoyage de Windows
echo 3.  Acces au bios (Automatique)                                   
echo 4.  Scan antivirus avance (Automatique, Windows Defender requis)         
echo 5.  Activation Windows 10/11 et Office (Script externe)           
echo 6.  Mode sans echec de Windows (Automatique)
echo 7.  Menu suppression d'application
echo 8.  Information pc
echo 9.  Mise a jour Windows (Automatique)
echo 10. Blockage telemetrie %status%
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
if "%choice%"=="9" goto option9
if "%choice%"=="10" goto option10
if "%choice%"=="0" goto option0

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
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdate" /f
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\edgeupdatem" /f

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

:option9
cls
echo Vous avez choisi l'option "Mise a jour Windows".
timeout /t 4 >nul
cls
echo.
echo Recherche des mises a jour Windows en cours...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Install-Module PSWindowsUpdate -Force -Scope CurrentUser; Import-Module PSWindowsUpdate; Get-WindowsUpdate -Install -AcceptAll"
echo.
echo Mise a jour des pilotes en cours...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WindowsUpdate -MicrosoftUpdate -Install -AcceptAll"
cls
goto menu

:option10
if not exist "%folder%\%file%" (
    sc stop DiagTrack
    sc config DiagTrack start= disabled
    sc stop dmwappushservice
    sc config dmwappushservice start= disabled

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

    set hostspath=%windir%\System32\drivers\etc\hosts

    echo Ajout des domaines à bloquer au fichier hosts...
    (
    echo 127.0.0.1 a-0001.a-msedge.net
    echo 127.0.0.1 a-0002.a-msedge.net
    echo 127.0.0.1 a-0003.a-msedge.net
    echo 127.0.0.1 a-0004.a-msedge.net
    echo 127.0.0.1 a-0005.a-msedge.net
    echo 127.0.0.1 a-0006.a-msedge.net
    echo 127.0.0.1 a-0007.a-msedge.net
    echo 127.0.0.1 a-0008.a-msedge.net
    echo 127.0.0.1 a-0009.a-msedge.net
    echo 127.0.0.1 a1621.g.akamai.net
    echo 127.0.0.1 a1856.g2.akamai.net
    echo 127.0.0.1 a1961.g.akamai.net
    echo 127.0.0.1 a978.i6g1.akamai.net
    echo 127.0.0.1 a.ads1.msn.com
    echo 127.0.0.1 a.ads2.msads.net
    echo 127.0.0.1 a.ads2.msn.com
    echo 127.0.0.1 ac3.msn.com
    echo 127.0.0.1 ad.doubleclick.net
    echo 127.0.0.1 adnexus.net
    echo 127.0.0.1 adnxs.com
    echo 127.0.0.1 ads1.msads.net
    echo 127.0.0.1 ads.msn.com
    echo 127.0.0.1 aidps.atdmt.com
    echo 127.0.0.1 aka-cdn-ns.adtech.de
    echo 127.0.0.1 any.edge.bing.com
    echo 127.0.0.1 a.rad.msn.com
    echo 127.0.0.1 az361816.vo.msecnd.net
    echo 127.0.0.1 az512334.vo.msecnd.net
    echo 127.0.0.1 b.ads1.msn.com
    echo 127.0.0.1 b.ads2.msads.net
    echo 127.0.0.1 bingads.microsoft.com
    echo 127.0.0.1 b.rad.msn.com
    echo 127.0.0.1 bs.serving-sys.com
    echo 127.0.0.1 c.atdmt.com
    echo 127.0.0.1 cdn.atdmt.com
    echo 127.0.0.1 cds26.ams9.msecn.net
    echo 127.0.0.1 choice.microsoft.com
    echo 127.0.0.1 choice.microsoft.com.nsatc.net
    echo 127.0.0.1 compatexchange.cloudapp.net
    echo 127.0.0.1 corpext.msitadfs.glbdns2.microsoft.com
    echo 127.0.0.1 corp.sts.microsoft.com
    echo 127.0.0.1 cs1.wpc.v0cdn.net
    echo 127.0.0.1 db3aqu.atdmt.com
    echo 127.0.0.1 df.telemetry.microsoft.com
    echo 127.0.0.1 diagnostics.support.microsoft.com
    echo 127.0.0.1 e2835.dspb.akamaiedge.net
    echo 127.0.0.1 e7341.g.akamaiedge.net
    echo 127.0.0.1 e7502.ce.akamaiedge.net
    echo 127.0.0.1 e8218.ce.akamaiedge.net
    echo 127.0.0.1 ec.atdmt.com
    echo 127.0.0.1 fe2.update.microsoft.com.akadns.net
    echo 127.0.0.1 feedback.microsoft-hohm.com
    echo 127.0.0.1 feedback.search.microsoft.com
    echo 127.0.0.1 feedback.windows.com
    echo 127.0.0.1 flex.msn.com
    echo 127.0.0.1 g.msn.com
    echo 127.0.0.1 h1.msn.com
    echo 127.0.0.1 h2.msn.com
    echo 127.0.0.1 hostedocsp.globalsign.com
    echo 127.0.0.1 i1.services.social.microsoft.com
    echo 127.0.0.1 i1.services.social.microsoft.com.nsatc.net
    echo 127.0.0.1 lb1.www.ms.akadns.net
    echo 127.0.0.1 live.rads.msn.com
    echo 127.0.0.1 m.adnxs.com
    echo 127.0.0.1 msnbot-65-55-108-23.search.msn.com
    echo 127.0.0.1 msntest.serving-sys.com
    echo 127.0.0.1 oca.telemetry.microsoft.com
    echo 127.0.0.1 oca.telemetry.microsoft.com.nsatc.net
    echo 127.0.0.1 onesettings-db5.metron.live.nsatc.net
    echo 127.0.0.1 pre.footprintpredict.com
    echo 127.0.0.1 preview.msn.com
    echo 127.0.0.1 rad.live.com
    echo 127.0.0.1 redir.metaservices.microsoft.com
    echo 127.0.0.1 reports.wes.df.telemetry.microsoft.com
    echo 127.0.0.1 schemas.microsoft.akadns.net
    echo 127.0.0.1 secure.adnxs.com
    echo 127.0.0.1 secure.flashtalking.com
    echo 127.0.0.1 services.wes.df.telemetry.microsoft.com
    echo 127.0.0.1 settings-sandbox.data.microsoft.com
    echo 127.0.0.1 settings-win.data.microsoft.com
    echo 127.0.0.1 sls.update.microsoft.com.akadns.net
    echo 127.0.0.1 sls.update.microsoft.com.nsatc.net
    echo 127.0.0.1 sqm.df.telemetry.microsoft.com
    echo 127.0.0.1 sqm.telemetry.microsoft.com
    echo 127.0.0.1 sqm.telemetry.microsoft.com.nsatc.net
    echo 127.0.0.1 ssw.live.com
    echo 127.0.0.1 static.2mdn.net
    echo 127.0.0.1 statsfe1.ws.microsoft.com
    echo 127.0.0.1 statsfe2.update.microsoft.com.akadns.net
    echo 127.0.0.1 statsfe2.ws.microsoft.com
    echo 127.0.0.1 survey.watson.microsoft.com
    echo 127.0.0.1 telecommand.telemetry.microsoft.com
    echo 127.0.0.1 telecommand.telemetry.microsoft.com.nsatc.net
    echo 127.0.0.1 telemetry.appex.bing.net
    echo 127.0.0.1 telemetry.urs.microsoft.com
    echo 127.0.0.1 vortex-bn2.metron.live.com.nsatc.net
    echo 127.0.0.1 vortex-cy2.metron.live.com.nsatc.net
    echo 127.0.0.1 vortex.data.microsoft.com
    echo 127.0.0.1 vortex-sandbox.data.microsoft.com
    echo 127.0.0.1 vortex-win.data.microsoft.com
    echo 127.0.0.1 cy2.vortex.data.microsoft.com.akadns.net
    echo 127.0.0.1 watson.live.com
    echo 127.0.0.1 watson.ppe.telemetry.microsoft.com
    echo 127.0.0.1 watson.telemetry.microsoft.com
    echo 127.0.0.1 watson.telemetry.microsoft.com.nsatc.net
    echo 127.0.0.1 win10.ipv6.microsoft.com
    echo 127.0.0.1 www.bingads.microsoft.com
    echo 127.0.0.1 www.go.microsoft.akadns.net
    echo 127.0.0.1 client.wns.windows.com
    echo 127.0.0.1 wdcp.microsoft.com
    echo 127.0.0.1 wdcpalt.microsoft.com
    echo 127.0.0.1 settings-ssl.xboxlive.com
    echo 127.0.0.1 settings-ssl.xboxlive.com-c.edgekey.net
    echo 127.0.0.1 settings-ssl.xboxlive.com-c.edgekey.net.globalredir.akadns.net
    echo 127.0.0.1 e87.dspb.akamaidege.net
    echo 127.0.0.1 insiderservice.microsoft.com
    echo 127.0.0.1 insiderservice.trafficmanager.net
    echo 127.0.0.1 e3843.g.akamaiedge.net
    echo 127.0.0.1 flightingserviceweurope.cloudapp.net
    echo 127.0.0.1 static.ads-twitter.com
    echo 127.0.0.1 www-google-analytics.l.google.com
    echo 127.0.0.1 p.static.ads-twitter.com
    echo 127.0.0.1 hubspot.net.edge.net
    echo 127.0.0.1 e9483.a.akamaiedge.net
    echo 127.0.0.1 stats.g.doubleclick.net
    echo 127.0.0.1 stats.l.doubleclick.net
    echo 127.0.0.1 adservice.google.de
    echo 127.0.0.1 adservice.google.com
    echo 127.0.0.1 googleads.g.doubleclick.net
    echo 127.0.0.1 pagead46.l.doubleclick.net
    echo 127.0.0.1 hubspot.net.edgekey.net
    echo 127.0.0.1 insiderppe.cloudapp.net
    echo 127.0.0.1 livetileedge.dsx.mp.microsoft.com
    echo 127.0.0.1 s0.2mdn.net
    echo 127.0.0.1 view.atdmt.com
    echo 127.0.0.1 geo.settings-win.data.microsoft.com.akadns.net
    echo 127.0.0.1 db5-eap.settings-win.data.microsoft.com.akadns.net
    echo 127.0.0.1 settings-win.data.microsoft.com
    echo 127.0.0.1 db5.settings-win.data.microsoft.com.akadns.net
    echo 127.0.0.1 asimov-win.settings.data.microsoft.com.akadns.net
    echo 127.0.0.1 db5.vortex.data.microsoft.com.akadns.net
    echo 127.0.0.1 v10-win.vortex.data.microsoft.com.akadns.net
    echo 127.0.0.1 geo.vortex.data.microsoft.com.akadns.net
    echo 127.0.0.1 v10.vortex-win.data.microsoft.com
    echo 127.0.0.1 v10.events.data.microsoft.com
    echo 127.0.0.1 v20.events.data.microsoft.com
    echo 127.0.0.1 us.vortex-win.data.microsoft.com
    echo 127.0.0.1 eu.vortex-win.data.microsoft.com
    echo 127.0.0.1 vortex-win-sandbox.data.microsoft.com
    echo 127.0.0.1 alpha.telemetry.microsoft.com
    echo 127.0.0.1 oca.telemetry.microsoft.com
    echo 127.0.0.1 ceuswatcab01.blob.core.windows.net
    echo 127.0.0.1 ceuswatcab02.blob.core.windows.net
    echo 127.0.0.1 eaus2watcab01.blob.core.windows.net
    echo 127.0.0.1 eaus2watcab02.blob.core.windows.net
    echo 127.0.0.1 weus2watcab01.blob.core.windows.net
    echo 127.0.0.1 weus2watcab02.blob.core.windows.net
    ) >> %hostspath%

    mkdir "%folder%\%file%"
) else (
    sc config DiagTrack start= auto
    sc start DiagTrack
    sc config dmwappushservice start= auto
    sc start dmwappushservice

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f

    set "hostspath=%windir%\System32\drivers\etc\hosts"
    
    set "tempfile=%temp%\hosts_tmp"
    
    :: Liste des domaines à supprimer
    set "domains=(
    a-0001.a-msedge.net
    a-0002.a-msedge.net
    a-0003.a-msedge.net
    a-0004.a-msedge.net
    a-0005.a-msedge.net
    a-0006.a-msedge.net
    a-0007.a-msedge.net
    a-0008.a-msedge.net
    a-0009.a-msedge.net
    a1621.g.akamai.net
    a1856.g2.akamai.net
    a1961.g.akamai.net
    a978.i6g1.akamai.net
    a.ads1.msn.com
    a.ads2.msads.net
    a.ads2.msn.com
    ac3.msn.com
    ad.doubleclick.net
    adnexus.net
    adnxs.com
    ads1.msads.net
    ads.msn.com
    aidps.atdmt.com
    aka-cdn-ns.adtech.de
    any.edge.bing.com
    a.rad.msn.com
    az361816.vo.msecnd.net
    az512334.vo.msecnd.net
    b.ads1.msn.com
    b.ads2.msads.net
    bingads.microsoft.com
    b.rad.msn.com
    bs.serving-sys.com
    c.atdmt.com
    cdn.atdmt.com
    cds26.ams9.msecn.net
    choice.microsoft.com
    choice.microsoft.com.nsatc.net
    compatexchange.cloudapp.net
    corpext.msitadfs.glbdns2.microsoft.com
    corp.sts.microsoft.com
    cs1.wpc.v0cdn.net
    db3aqu.atdmt.com
    df.telemetry.microsoft.com
    diagnostics.support.microsoft.com
    e2835.dspb.akamaiedge.net
    e7341.g.akamaiedge.net
    e7502.ce.akamaiedge.net
    e8218.ce.akamaiedge.net
    ec.atdmt.com
    fe2.update.microsoft.com.akadns.net
    feedback.microsoft-hohm.com
    feedback.search.microsoft.com
    feedback.windows.com
    flex.msn.com
    g.msn.com
    h1.msn.com
    h2.msn.com
    hostedocsp.globalsign.com
    i1.services.social.microsoft.com
    i1.services.social.microsoft.com.nsatc.net
    lb1.www.ms.akadns.net
    live.rads.msn.com
    m.adnxs.com
    msnbot-65-55-108-23.search.msn.com
    msntest.serving-sys.com
    oca.telemetry.microsoft.com
    oca.telemetry.microsoft.com.nsatc.net
    onesettings-db5.metron.live.nsatc.net
    pre.footprintpredict.com
    preview.msn.com
    rad.live.com
    redir.metaservices.microsoft.com
    reports.wes.df.telemetry.microsoft.com
    schemas.microsoft.akadns.net
    secure.adnxs.com
    secure.flashtalking.com
    services.wes.df.telemetry.microsoft.com
    settings-sandbox.data.microsoft.com
    settings-win.data.microsoft.com
    sls.update.microsoft.com.akadns.net
    sls.update.microsoft.com.nsatc.net
    sqm.df.telemetry.microsoft.com
    sqm.telemetry.microsoft.com
    sqm.telemetry.microsoft.com.nsatc.net
    ssw.live.com
    static.2mdn.net
    statsfe1.ws.microsoft.com
    statsfe2.update.microsoft.com.akadns.net
    statsfe2.ws.microsoft.com
    survey.watson.microsoft.com
    telecommand.telemetry.microsoft.com
    telecommand.telemetry.microsoft.com.nsatc.net
    telemetry.appex.bing.net
    telemetry.urs.microsoft.com
    vortex-bn2.metron.live.com.nsatc.net
    vortex-cy2.metron.live.com.nsatc.net
    vortex.data.microsoft.com
    vortex-sandbox.data.microsoft.com
    vortex-win.data.microsoft.com
    cy2.vortex.data.microsoft.com.akadns.net
    watson.live.com
    watson.ppe.telemetry.microsoft.com
    watson.telemetry.microsoft.com
    watson.telemetry.microsoft.com.nsatc.net
    win10.ipv6.microsoft.com
    www.bingads.microsoft.com
    www.go.microsoft.akadns.net
    client.wns.windows.com
    wdcp.microsoft.com
    wdcpalt.microsoft.com
    settings-ssl.xboxlive.com
    settings-ssl.xboxlive.com-c.edgekey.net
    settings-ssl.xboxlive.com-c.edgekey.net.globalredir.akadns.net
    e87.dspb.akamaidege.net
    insiderservice.microsoft.com
    insiderservice.trafficmanager.net
    e3843.g.akamaiedge.net
    flightingserviceweurope.cloudapp.net
    static.ads-twitter.com
    www-google-analytics.l.google.com
    p.static.ads-twitter.com
    hubspot.net.edge.net
    e9483.a.akamaiedge.net
    stats.g.doubleclick.net
    stats.l.doubleclick.net
    adservice.google.de
    adservice.google.com
    googleads.g.doubleclick.net
    pagead46.l.doubleclick.net
    hubspot.net.edgekey.net
    insiderppe.cloudapp.net
    livetileedge.dsx.mp.microsoft.com
    s0.2mdn.net
    view.atdmt.com
    geo.settings-win.data.microsoft.com.akadns.net
    db5-eap.settings-win.data.microsoft.com.akadns.net
    settings-win.data.microsoft.com
    db5.settings-win.data.microsoft.com.akadns.net
    asimov-win.settings.data.microsoft.com.akadns.net
    db5.vortex.data.microsoft.com.akadns.net
    v10-win.vortex.data.microsoft.com.akadns.net
    geo.vortex.data.microsoft.com.akadns.net
    v10.vortex-win.data.microsoft.com
    v10.events.data.microsoft.com
    v20.events.data.microsoft.com
    us.vortex-win.data.microsoft.com
    eu.vortex-win.data.microsoft.com
    vortex-win-sandbox.data.microsoft.com
    alpha.telemetry.microsoft.com
    oca.telemetry.microsoft.com
    ceuswatcab01.blob.core.windows.net
    ceuswatcab02.blob.core.windows.net
    eaus2watcab01.blob.core.windows.net
    eaus2watcab02.blob.core.windows.net
    weus2watcab01.blob.core.windows.net
    weus2watcab02.blob.core.windows.net
    )"
    
    set "tempfile=%temp%\hosts_tmp"
    
    copy %hostspath% %tempfile%
    
    for %%d in (%domains%) do (
        findstr /v /c:"127.0.0.1 %%d" %tempfile% > %tempfile%.tmp
        move /y %tempfile%.tmp %tempfile%
    )
    
    move /y %tempfile% %hostspath%

    del "%folder%"
)
cls
goto menu

:option0
exit

:reboot
shutdown /r /t 5 /c "Redemarrage en cours..."
exit
