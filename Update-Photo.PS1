# 
Write-Host "===============================================" -ForegroundColor Green
Write-Host "        Code by Eng. Haitham Badarin          " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Start-Sleep -Milliseconds 600

# ---------- Path to png profile pic ----------
$DefaultUserPhoto = "$Home\Desktop\Palestine.PNG"

function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }
function Warn([string]$m){ Write-Host $m -ForegroundColor Yellow }
function Err ([string]$m){ Write-Host $m -ForegroundColor Red }
function Ok  ([string]$m){ Write-Host $m -ForegroundColor Green }

# ---------- Validate default photo path ----------
if (-not (Test-Path -PathType Leaf -Path $DefaultUserPhoto)) {
    Err ("❌ Can't find the default photo file: {0}" -f $DefaultUserPhoto)
    return
}

# ---------- Prompt for days back ----------
$daysRaw = Read-Host "Enter DAYS BACK (e.g., 3)"
[int]$DAYS_BACK = 0
if (-not [int]::TryParse($daysRaw, [ref]$DAYS_BACK) -or $DAYS_BACK -le 0) {
    Err "❌ Invalid number of days. Please run again and enter a positive integer."
    return
}

# ---------- Connect to Microsoft Graph ----------
try {
    $ctx = Get-MgContext -ErrorAction SilentlyContinue
    if (-not $ctx) {
        Info "Connecting to Microsoft Graph..."
        Connect-MgGraph -Scopes "User.Read.All","User.ReadWrite.All"
    } else {
        Info "Using existing Microsoft Graph session."
    }
} catch {
    Err ("Failed to connect to Microsoft Graph: {0}" -f $_.Exception.Message)
    return
}

# ---------- Compute time window (UTC) ----------
$sinceUtc = [datetime]::UtcNow.AddDays(-$DAYS_BACK)
$sinceStr = $sinceUtc.ToString("s") + "Z"
Info ("Processing users created since (UTC): {0}" -f $sinceStr)

# ---------- Query users ----------
$userCount = 0
try {
    $Users = Get-MgUser -Count userCount -ConsistencyLevel eventual -Filter "CreatedDateTime ge $sinceStr" -All | Sort-Object DisplayName
} catch {
    Err ("Failed to get users: {0}" -f $_.Exception.Message)
    return
}

if (-not $Users -or $Users.Count -eq 0) {
    Warn ("No users found created in the past {0} day(s)." -f $DAYS_BACK)
    return
}

# ---------- Progress + counters ----------
$updatedDefaultLike = 0
$updatedNoPhoto     = 0
$hasPersonalized    = 0
$failedUpdates      = 0

$ProgDelta  = if ($Users.Count -gt 0) { 100 / $Users.Count } else { 100 }
$CheckCount = 0
$userIndex  = 0

Info ("Found {0} user(s). Scanning photos..." -f $Users.Count)

foreach ($User in $Users) {
    $userIndex++
    $status = "{0} [{1}/{2}]" -f $User.DisplayName, $userIndex, $Users.Count
    Write-Progress -Activity "Checking photo for user account" -Status $status -PercentComplete $CheckCount
    $CheckCount += $ProgDelta

    # Try get photo
    $photo = $null
    try {
        $photo = Get-MgUserPhoto -UserId $User.Id -ErrorAction SilentlyContinue
    } catch {
        $photo = $null
    }

    if ($photo) {
        if (($photo.Height -eq 150) -and ($photo.Width -eq 150)) {
            Warn ("{0} has a default 150x150 photo → updating..." -f $User.DisplayName)
            try {
                Set-MgUserPhotoContent -UserId $User.Id -InFile $DefaultUserPhoto
                $updatedDefaultLike++
            } catch {
                Err ("Failed to update photo for {0}: {1}" -f $User.DisplayName, $_.Exception.Message)
                $failedUpdates++
            }
        } else {
            Write-Host ("{0} already has a personalized photo" -f $User.DisplayName)
            $hasPersonalized++
        }
    } else {
        Warn ("{0} has no photo → uploading default..." -f $User.DisplayName)
        try {
            Set-MgUserPhotoContent -UserId $User.Id -InFile $DefaultUserPhoto
            $updatedNoPhoto++
        } catch {
            Err ("Failed to upload photo for {0}: {1}" -f $User.DisplayName, $_.Exception.Message)
            $failedUpdates++
        }
    }
}

Write-Progress -Activity "Checking photo for user account" -Completed

# ---------- Summary ----------
$line = "-" * 50
Write-Host $line
Ok   ("✅ Finished. Window: last {0} day(s); Since (UTC): {1}" -f $DAYS_BACK, $sinceStr)
Write-Host ("Total users scanned: {0}"                -f $Users.Count)
Write-Host ("Updated (had default-like 150x150): {0}" -f $updatedDefaultLike)
Write-Host ("Updated (had no photo): {0}"             -f $updatedNoPhoto)
Write-Host ("Personalized photos (left as-is): {0}"   -f $hasPersonalized)
if ($failedUpdates -gt 0) {
    Warn ("Failed updates: {0}" -f $failedUpdates)
}
Write-Host $line
