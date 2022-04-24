<#
.SYNOPSIS
    Sync mp3 files on USB drive from configuration file
.DESCRIPTION
    Removes all files not defined in configuration file.

    Configuration file syntax;
    {
        "Title": "podcast",
        "Source": "\\\\pihl-fs\\Pihl\\Music\\Pod",
        "Age": 14 //Only files from last two weeks.
    },
.NOTES
    2022-04-24 Version 1 Klas.Pihl@gmail.com
.EXAMPLE
    .\sync-audio.ps1 -InformationAction Continue -Verbose

.PARAMETER Path
    Configuration file path

.PARAMETER Age
    If Age of file is omitted in configuration the default age is used.

.PARAMETER Destination
    Destination Path
#>

[cmdletbinding(SupportsShouldProcess=$True)]
param (
    $Path=".\sync-config.json",
    $Age = 365,
    $Destination = 'D:\'
)

try {
    #load and verify configuration file
    [PSCustomObject]$Configuration = get-content -Path $Path | ConvertFrom-Json
    $Date = Get-Date

    #get all files newer then defined age in days.
    $AllFiles = $Configuration | ForEach-Object {
        $AgeFile =  if( $PSitem.Age) {
            $PSitem.Age
        } else {
            $Age
        }
        Write-Verbose "Sync $($PSitem.Title)"
        Get-ChildItem $psitem.source -Recurse -Filter *.mp3 | Where-Object CreationTime -gt $Date.AddDays(-$AgeFile)
    }
    Write-Information "Found $($AllFiles.count) files at source(s)"

    #remove old files from destination
    $AllExistingFiles = Get-ChildItem $Destination -Recurse -Filter *.mp3
    $AlreadySynced = foreach ($File in $AllExistingFiles) {
        $AllFiles | Where-Object {
            $PSItem.Name -eq $File.Name #-and
            #$PSItem.LastWriteTime -eq $File.LastWriteTime
        }
    }
    Write-Information "$($AlreadySynced.count) already synced"

    $NewFiles = $AllFiles | Where-Object {
        $AlreadySynced.Name -notcontains $PSItem.Name
    }
    Write-Information "$($NewFiles.count) missing at destination $Destination"

    #StaleFiles
    $StaleFiles = $AllExistingFiles | Where-Object {
        $AllFiles.Name -notcontains $PSItem.Name
    }
    Write-Information "$($StaleFiles.count) missing at source, removing from $Destination"
    if($StaleFiles) {
        Write-Verbose "$($StaleFiles.Name -join ', ') removed from $Destination"
        $StaleFiles | Remove-Item -Confirm:0
    }

    #copy new files
    if($NewFiles) {
        $NewFiles | ForEach-Object {
            $PSItem | Copy-Item -Destination $Destination
        }

    } else {
        Write-Information "No files found withing age limits" -InformationAction Continue
    }

} catch {
    throw "Errors syncing files defined in '$path' to '$Destination'"

}
