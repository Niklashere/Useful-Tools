
$userpath = $env:USERPROFILE;
$time = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

function main {
    Write-Host "Welcome to Useful Tools"
    Write-Host "I - Install"
    Write-Host "R - Recover"
    Write-Host "B - Backup"
    $mode = (Read-Host "Please select the mode").ToLower()
    switch ($mode) {
        'i' {
            Write-Host "You selected Install Mode"
            Install
            break
        }
        'r' {
            Write-Host "You selected Recover Mode"
            Recover
            break
        }
        'b' {
            Write-Host "You selected Backup Mode"
            CreateBackup
            break
        }
        default {
            Write-Host "Invalid selection. Exiting."
        }
    }
}

function install {
    $wingetPrograms = @(
        "Chocolatey.Chocolatey",
        "Ytmdesktop.Ytmdesktop",
        "RARLab.WinRAR",
        "SomePythonThings.WingetUIStore",
        "Ubisoft.Connect",
        "Valve.Steam",
        "WhirlwindFX.SignalRgb",
        "RealtekSemiconductorCorp.RealtekAudioCon\u2026",
        "JetBrains.PyCharm.Professional",
        "JetBrains.PHPStorm",
        "JetBrains.IntelliJIDEA.Ultimate",
        "TechPowerUp.NVCleanstall",
        "Notepad++.Notepad++",
        "Nextcloud.NextcloudDesktop",
        "Microsoft.VisualStudioCode",
        "Microsoft.Office",
        "Logitech.GHUB",
        "LabyMediaGmbH.LabyModLauncher",
        "ItchIo.Itch",
        "GOG.Galaxy",
        "Git.Git",
        "EpicGames.EpicGamesLauncher",
        "EclipseAdoptium.Temurin.20.JRE",
        "EclipseAdoptium.Temurin.20.JDK",
        "ElectronicArts.EADesktop",
        "Discord.Discord",
        "Anki.Anki"
    )
    $chocolatey = @(
        "chocolatey-windowsupdate.extension",
        "chocolatey-core.extension",
        "chocolatey-compatibility.extension",
        "amd-ryzen-master",
        "amd-ryzen-chipset"
    )
    $urls = @("https://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwNDYxNjAy&cmp=ABX&lang=DE")

    foreach ($program in $wingetPrograms) {
        winget install --id $program --exact --accept-source-agreements --disable-interactivity --accept-source-agreements --force
    }

    foreach ($program in $chocolatey) {
        choco install $program -y
    }

    foreach($program in $urls) {
        Invoke-WebRequest -Uri $program -OutFile "program.exe"
        Start-Process -FilePath ".\program.exe" -Wait
        Remove-Item ".\program.exe"
    }
    
}

function recover {
    if (Test-Path "C:\Program Files\WinRAR") {
        $loc = Get-Location
        $arguments = "x """ + $loc + "\Backup_*.zip"" """ + $loc + """ -ad"
        Start-Process -FilePath "C:\Program Files\WinRAR\WinRAR.exe" -ArgumentList $arguments -Wait
    } else {
        Expand-Archive -Path '.\Backup_*.zip'
    }

    Copy-Item ".\Backup_*\AppData\Roaming\*" -Recurse -Destination $userpath"\AppData\Roaming\"
}

function createBackup {
    $appdataFolders = @(
        ".minecraft", "Anki2", "Code", "discord", "JetBrains", "LabyMod", "LabyMod Launcher",
        "ludusavi", "Nextcloud", "Notepad++", "youtube-music-desktop-app"
    )

    $backupPath = Join-Path $userpath "\AppData\Local\Temp\toolsbackup"
    
    if (Test-Path $backupPath) {
        Remove-Item $backupPath -Recurse -Force
    }

    New-Item -Path $backupPath -ItemType Directory | Out-Null
    
    foreach($programm in $appdataFolders) {
        $sourcePath = $userpath + "\AppData\Roaming\" + $programm + "\*"
        $destinationPath = $backupPath + "\AppData\Roaming\" + $programm
        New-Item -Path $destinationPath -ItemType Directory
        Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse

    }

    $filename = "Backup_$time.zip"
    
    if (Test-Path "C:\Program Files\WinRAR") {
        $arguments = "a """ + $filename + """ " + $backupPath + "\AppData -ep1"
        Start-Process -FilePath "C:\Program Files\WinRAR\WinRAR.exe" -ArgumentList $arguments -Wait
        
    } else {
        Compress-Archive -Path $backupPath -DestinationPath $filename -Force

    }

    if (Test-Path $backupPath) {
        Remove-Item $backupPath -Recurse -Force
    }
    Write-Host "Successfully created $filename."
}

main