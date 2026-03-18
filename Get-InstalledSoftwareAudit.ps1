<#
.SYNOPSIS
    Audits installed software and exports recent installs.

.DESCRIPTION
    Collects installed software from registry and attempts to determine install date.
    Uses fallback methods if InstallDate is missing.
    Outputs to CSV or console.

.PARAMETER ExportPath
    Optional path to export results as CSV.

.PARAMETER Days
    Number of days to look back (e.g. 10, 15, 30).

.NOTES
    Author: Bradley Mclaughlan
#>

param (
    [string]$ExportPath = "C:\Temp\software_audit.csv",
    [int]$Days = 10
)

$hostname = $env:COMPUTERNAME
$timestamp = Get-Date
$cutoffDate = (Get-Date).AddDays(-$Days)

# Ensure export folder exists
$folder = Split-Path $ExportPath
if (!(Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

function Convert-InstallDate {
    param ([string]$DateValue)

    if ($DateValue -match '^\d{8}$') {
        try {
            return [datetime]::ParseExact($DateValue, 'yyyyMMdd', $null)
        } catch {}
    }

    try {
        return [datetime]$DateValue
    } catch {}

    return $null
}

$results = @()

foreach ($path in $registryPaths) {
    $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue

    foreach ($app in $apps) {
        if ([string]::IsNullOrWhiteSpace($app.DisplayName)) {
            continue
        }

        $installDate = $null
        $dateSource = "None"

        # 1. Try registry InstallDate
        $installDate = Convert-InstallDate $app.InstallDate
        if ($installDate) {
            $dateSource = "Registry"
        }

        # 2. Fallback: InstallLocation folder timestamp
        if (-not $installDate -and $app.InstallLocation -and (Test-Path $app.InstallLocation)) {
            try {
                $installDate = (Get-Item $app.InstallLocation).LastWriteTime
                $dateSource = "Folder"
            } catch {}
        }

        # Skip if filtering and no date
        if (-not $installDate) {
            continue
        }

        # Apply Days filter
        if ($installDate -lt $cutoffDate) {
            continue
        }

        $results += [PSCustomObject]@{
            ComputerName = $hostname
            Name         = $app.DisplayName
            Version      = $app.DisplayVersion
            Publisher    = $app.Publisher
            InstallDate  = $installDate.ToString("yyyy-MM-dd")
            Source       = $dateSource
        }
    }
}

# Remove duplicates
$results = $results | Sort-Object Name, Version -Unique

if ($results.Count -gt 0) {
    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Output "✅ Found $($results.Count) applications installed in last $Days days"
    Write-Output "📁 Exported to: $ExportPath"
} else {
    Write-Output "⚠️ No software found in last $Days days"
}