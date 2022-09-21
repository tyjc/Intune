# Remove Microsoft bloatware/crapware
# Original file https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388#file-remove-hpbloatware-ps1 
# Modified by Jeroen Burgerhout https://github.com/BurgerhoutJ/scripts/blob/main/remove-bloatware/RemoveHPBloatware.ps1#L46
# Further modified by Ty Collins (@tyjc)

if (-not (Test-Path "$($env:ProgramData)\Bloatware\RemoveHPBloatware")) {
    Mkdir "$($env:ProgramData)\Bloatware\RemoveHPBloatware"
}
Set-Content -Path "$($env:ProgramData)\Bloatware\RemoveHPBloatware\RemoveHPBloatware.ps1.tag" -Value "Installed"

Start-Transcript "$($env:ProgramData)\Bloatware\RemoveHPBloatware\RemoveHPBloatware.log"

#HP installed Bloat Appx Packages
$Packages = @(
    "AD2F1837.HPEasyClean"
    "AD2F1837.HPPCHardwareDiagnosticsWindows"
    "AD2F1837.HPPowerManager"
    "AD2F1837.HPPrivacySettings"
    "AD2F1837.HPProgrammableKey"
    "AD2F1837.HPQuickDrop"
    "AD2F1837.HPSupportAssistant"
    "AD2F1837.HPSystemInformation"
    "AD2F1837.HPWorkWell"
    "AD2F1837.myHP"
    "Tile.TileWindowsApplication"
    "ReatltekSemiconductorCorp.HPAudioControl"
)
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object { ($Packages -contains $_.Name) }
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { ($Packages -contains $_.DisplayName) }

#HP installed bloat programs
$Programs = @(
    "HP Client Security Manager"
    "HP Notifications"
    "HP Security Update Service"
    "HP System Default Settings"
    "HP Wolf Security"
    "HP Wolf Security Application Support for Sure Sense"
    "HP Wolf Security Application Support for Windows"
    "HP Documentation"
    "Pen Settings Service"
    "HP Sure Run Module"
    "HP Sure Recover"
    "HP Connection Optimizer"
)
$InstalledPrograms = Get-Package | Where-Object { $Programs -contains $_.Name }

ForEach ($ProvPackage in $ProvisionedPackages) {

    Try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
    }
    Catch { Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]" }
}

ForEach ($AppxPackage in $InstalledPackages) {

    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
    }
    Catch { Write-Warning -Message "Failed to remove provisioned package: [$($AppxPackage.DisplayName)]" }
}

$InstalledPrograms | ForEach-Object {
    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."
    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
    }
    Catch { Write-Warning -Message "Failed to uninstall: [$($_.Name)]" }
}
Stop-Transcript