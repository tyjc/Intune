# Remove Microsoft bloatware/crapware
# Original file https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388#file-remove-hpbloatware-ps1 
# Modified by Jeroen Burgerhout https://github.com/BurgerhoutJ/scripts/blob/main/remove-bloatware/RemoveHPBloatware.ps1#L46
# Further modified by Ty Collins to remove windows apps(@tyjc)

if (-not (Test-Path "$($env:ProgramData)\Bloatware\RemoveMSBloatware")) {
    Mkdir "$($env:ProgramData)\Bloatware\RemoveMSBloatware"
}
Set-Content -Path "$($env:ProgramData)\Bloatware\RemoveMSBloatware\RemoveMSBloatware.ps1.tag" -Value "Installed"

Start-Transcript "$($env:ProgramData)\Bloatware\RemoveMSBloatware\RemoveMSBloatware.log"

#MS installed Bloat Appx Packages
$Packages = @(
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object { ($Packages -contains $_.Name) }
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { ($Packages -contains $_.DisplayName) }

#MS installed bloat programs
$Programs = @(
    "Microsoft 365 - en-us"
    "Office 16 Click-to-Run Extensibility Component"
    "Office 16 Click-to-Run Licensing Component"
    "Microsoft OneDrive"
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