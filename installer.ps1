# REQURIES App-Installer from the Microsoft Store https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab
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
        # Package Managers
        "Chocolatey.Chocolatey",
        "OpenJS.NodeJS.LTS",

        # Game Launchers
        "Valve.Steam",
        "Ubisoft.Connect",
        "GOG.Galaxy",
        "EpicGames.EpicGamesLauncher",
        "ElectronicArts.EADesktop",
        "LabyMediaGmbH.LabyModLauncher",
        "ItchIo.Itch",
        "SideQuestVR.SideQuest",
        "Meta.Oculus",
        "RiotGames.Valorant.EU",
        "RiotGames.LeagueOfLegends.EUW"

        # Development Tools
        "Microsoft.VisualStudioCode",
        "JetBrains.Toolbox",
        "Termius.Termius",
        "Git.Git",
        "EclipseAdoptium.Temurin.20.JRE",
        "EclipseAdoptium.Temurin.20.JDK",
        "Microsoft.DotNet.SDK.7",
        "xampp",
        "Docker.DockerDesktop",
        "GitHub.GitHubDesktop",

        # Utilitis
        "Notepad++.Notepad++",
        "Notion.Notion",
        "Anki.Anki",
        "TeamViewer.TeamViewer",
        "AnyDeskSoftwareGmbH.AnyDesk",
        "SomePythonThings.WingetUIStore",
        "WhirlwindFX.SignalRgb",
        "RARLab.WinRAR",
        "Ytmdesktop.Ytmdesktop",
        "Nextcloud.NextcloudDesktop",
        "Microsoft.Office",
        "Logitech.GHUB",
        "Mozilla.Firefox",
        "MusicBrainz.Picard",
        "OBSProject.OBSStudio",
        "buchen.portfolio",
        "Surfshark.Surfshark",
        "Rils.TouchPortal",
        "WinDirStat.WinDirStat",

        # Drivers
        "RealtekSemiconductorCorp.RealtekAudioCon\u2026",
        "TechPowerUp.NVCleanstall",

        # Social Media
        "Discord.Discord",
        "TeamSpeakSystems.TeamSpeakClient"

    )
    $chocolatey = @(
        "chocolatey-windowsupdate.extension",
        "chocolatey-core.extension",
        "chocolatey-compatibility.extension",
        "amd-ryzen-master",
        "amd-ryzen-chipset",
        "python3"
    )
    $npm = @(
        "@angular/cli"
    )
    $urls = @(
        "https://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwNDYxNjAy&cmp=ABX&lang=DE",
        "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe"
    )

    foreach ($program in $wingetPrograms) {
        winget install --id Anki.Anki --exact --accept-source-agreements --disable-interactivity --accept-source-agreements --force
    }

    foreach ($program in $chocolatey) {
        choco install $program -y
    }

    foreach ($program in $npm) {
        npm install -g $program
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

    Copy-Item ".\Backup_*\*" -Recurse -Destination $userpath"\"

}

function createBackup {
    $appdataFolders = @(
        ".minecraft", "Anki2", "Code", "discord", "JetBrains", "LabyMod", "LabyMod Launcher",
        "ludusavi", "Nextcloud", "Notepad++", "youtube-music-desktop-app"
    )
    $documentsFolders = @(
        "WhirlwindFX"
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

    foreach($programm in $documentsFolders) {
        $sourcePath = $userpath + "\Documents\" + $programm + "\*"
        $destinationPath = $backupPath + "\Documents\" + $programm
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
