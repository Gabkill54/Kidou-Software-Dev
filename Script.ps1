Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 0 -Type DWord
Checkpoint-Computer -Description "Utilisation-du-script-de-Kidou" -RestorePointType MODIFY_SETTINGS
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "SystemRestorePointCreationFrequency" -Value 1440 -Type DWord

#il faudra mettre le code pour cacher la suite ICI

# Importer l'assemblée pour Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Créer la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Kidou_Software V1.6 DEV"
$form.Size = New-Object System.Drawing.Size(390, 415)
$form.StartPosition = "CenterScreen"

# Ajouter un Label pour le menu
$label = New-Object System.Windows.Forms.Label
$label.Text = "Kidou_Software - Menu Principal"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(100, 20)
$form.Controls.Add($label)

# Ajouter les boutons pour chaque option
$buttons = @()
$options = @("Reparation de Windows", "Nettoyage de Windows", "Acces au BIOS", "Scan antivirus avance", "Activation Windows et Office", "Mode sans echec de Windows", "Suppression d'application", "Information PC", "Quitter")
$actions = @(
    {
        # Option 1: Reparation de Windows
        $confirm = [System.Windows.Forms.MessageBox]::Show("L'ordinateur va prochainement redemarrer, etes-vous pret ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($confirm -eq "Yes") {
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -NoExit -Command sfc /scannow" -Wait
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command DISM /Online /Cleanup-Image /RestoreHealth" -Wait
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v BootExecute /t REG_MULTI_SZ /d "autocheck autochk /r \??\C:\0autocheck autochk *" /f
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager" /v AutoChkTimeout /t REG_DWORD /d 1 /f
            shutdown /r /t 5 /c "Redemarrage en cours..."
            Stop-Process -Id $PID
        }
    },
    {
        # Option 2: Nettoyage de Windows
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/c" -NoNewWindow -Wait
        Remove-Item -Path "$env:SystemRoot\SoftwareDistribution\Download\*" -Recurse -Force
        netsh int ip reset
        netsh winsock reset
    },
    {
        # Option 3: Acces au BIOS
        $confirm = [System.Windows.Forms.MessageBox]::Show("L'ordinateur va prochainement redemarrer, etes-vous pret ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($confirm -eq "Yes") {
            shutdown /r /fw /t 5
            Stop-Process -Id $PID
        }
    },
    {
        # Option 4: Scan antivirus avance
        $confirm = [System.Windows.Forms.MessageBox]::Show("L'ordinateur va prochainement redemarrer, etes-vous pret ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($confirm -eq "Yes") {
            $defenderStatus = Get-Service -Name WinDefend
            if ($defenderStatus.Status -eq "Running") {
                Start-MpWDOScan
                Stop-Process -Id $PID
            } else {
                [System.Windows.Forms.MessageBox]::Show("Windows Defender n'est pas active.")
            }
        }
    },
    {
        # Option 5: Activation Windows et Office
        Start-Process -FilePath "powershell.exe" -ArgumentList "-Command irm https://massgrave.dev/get | iex" -NoNewWindow -Wait
    },
    {
        # Option 6: Mode sans echec de Windows
$confirm = [System.Windows.Forms.MessageBox]::Show("L'ordinateur va prochainement redemarrer, etes-vous pret ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo)
if ($confirm -eq "Yes") {
    $confirm2 = [System.Windows.Forms.MessageBox]::Show("Pour pouvoir quitter le mode sans echec, il faudra ouvrir le script `WindowsNormal` qui se trouvera sur le bureau de votre ordinateur.", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::OK)
    if ($confirm2 -eq "OK") {
        bcdedit /set {current} safeboot network
        $desktopPath = [System.Environment]::GetFolderPath('Desktop')
        $scriptPath = "$desktopPath\WindowsNormal.cmd"
        Set-Content -Path $scriptPath -Value "@echo off`nbcdedit /deletevalue {current} safeboot`nshutdown /r /t 5 /c `"Desactivation du mode sans échec en cours...`"`ndel WindowsNormal.cmd`nexit"
        shutdown /r /t 5 /c "Activation du mode sans échec en cours..."}}
        Stop-Process -Id $PID
    },
    {
        # Option 7: Suppression d'application
        # Fonction pour supprimer Edge
# Fonction pour supprimer Edge
function Remove-Edge {
    $maxVersion = ""
    $maxVersionFolder = ""

    $edgeAppPath = "C:\Program Files (x86)\Microsoft\Edge\Application"

    # Trouver la version la plus récente d'Edge
    Get-ChildItem -Path $edgeAppPath -Directory | ForEach-Object {
        if ($_.Name -match "^\d+(\.\d+)*$") {
            if ($_.Name -gt $maxVersion) {
                $maxVersion = $_.Name
                $maxVersionFolder = $_.FullName
            }
        }
    }

    # Supprimer Edge
    if ($maxVersion -ne "") {
        $edgeInstallerPath = Join-Path -Path $maxVersionFolder -ChildPath "Installer"
        Start-Process -FilePath "$edgeInstallerPath\setup.exe" -ArgumentList "-uninstall -system-level -verbose-logging -force-uninstall" -Wait
        Remove-Item -Path $edgeAppPath -Recurse -Force
    }
}


# Fonction pour supprimer OneDrive
function Remove-OneDrive {
    # Afficher une fenêtre de confirmation
    $confirmDialog = [System.Windows.Forms.MessageBox]::Show("Ce script va supprimer completement et definitivement OneDrive de votre ordinateur. Assurez-vous que tous les documents OneDrive stockes localement sont sauvegardes entierement avant de proceder.`n`nVoulez-vous continuer ?", "Avertissement", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)

    if ($confirmDialog -eq "Yes") {
        # Terminer le processus OneDrive
        Stop-Process -Name "OneDrive" -Force

        # Supprimer les répertoires et les fichiers de OneDrive
        $oneDriveFolders = @(
            "$env:USERPROFILE\OneDrive",
            "$env:LOCALAPPDATA\Microsoft\OneDrive",
            "$env:ProgramData\Microsoft OneDrive",
            "C:\OneDriveTemp"
        )

        foreach ($folder in $oneDriveFolders) {
            if (Test-Path $folder) {
                Remove-Item -Path $folder -Recurse -Force
            }
        }

        # Supprimer le raccourci du menu Démarrer
        $startMenuShortcut = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
        if (Test-Path $startMenuShortcut) {
            Remove-Item -Path $startMenuShortcut -Force
        }

        # Supprimer les entrées de registre associées à OneDrive
        Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force
        Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -Force
        New-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -PropertyType DWORD -Force
    }
}

# Créer une fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Suppression d'Applications"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

# Ajouter un Label pour le titre
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Choisissez une application à supprimer :"
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($titleLabel)

# Ajouter un bouton pour supprimer Edge
$edgeButton = New-Object System.Windows.Forms.Button
$edgeButton.Text = "Supprimer Edge"
$edgeButton.Location = New-Object System.Drawing.Point(50, 60)
$edgeButton.Size = New-Object System.Drawing.Size(150, 30)
$edgeButton.Add_Click({ Remove-Edge })
$form.Controls.Add($edgeButton)

# Ajouter un bouton pour supprimer OneDrive
$oneDriveButton = New-Object System.Windows.Forms.Button
$oneDriveButton.Text = "Supprimer OneDrive"
$oneDriveButton.Location = New-Object System.Drawing.Point(50, 100)
$oneDriveButton.Size = New-Object System.Drawing.Size(150, 30)
$oneDriveButton.Add_Click({ Remove-OneDrive })
$form.Controls.Add($oneDriveButton)

# Ajouter un bouton pour quitter
$quitButton = New-Object System.Windows.Forms.Button
$quitButton.Text = "Quitter"
$quitButton.Location = New-Object System.Drawing.Point(250, 130)
$quitButton.Size = New-Object System.Drawing.Size(100, 30)
$quitButton.Add_Click({ $form.Close() })
$form.Controls.Add($quitButton)

# Afficher la fenêtre
$form.ShowDialog()

    },
    {
        # Option 8: Information PC
        $mbManufacturer = (Get-WmiObject -Class Win32_BaseBoard).Manufacturer
        $mbModel = (Get-WmiObject -Class Win32_BaseBoard).Product
        $cpuName = (Get-WmiObject -Class Win32_Processor).Name
        $gpuNames = (Get-WmiObject -Class Win32_VideoController).Name
        $ramSize = [math]::Round((Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
    
        $infoMessage = "Marque de la carte mere: $mbManufacturer`nModele de la carte mere: $mbModel`nProcesseur: $cpuName`n"
    
        $gpuIndex = 1
    foreach ($gpuName in $gpuNames) {
        $infoMessage += "Carte graphique $gpuIndex : $gpuName`n"
        $gpuIndex++
    }
    
    $infoMessage += "RAM installee: $ramSize GB"
    
    [System.Windows.Forms.MessageBox]::Show($infoMessage)
},
    {
    # Option 9: Quitter
    $form.Dispose()
    Stop-Process -Id $PID
    }

)

for ($i = 0; $i -lt $options.Length; $i++) {
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $options[$i]
    $button.Size = New-Object System.Drawing.Size(350, 30)
    $button.Location = New-Object System.Drawing.Point(10, (60 + ($i * 35)))
    $button.Add_Click($actions[$i])
    $form.Controls.Add($button)
    $buttons += $button
}

# Afficher la fenêtre
$form.ShowDialog()
