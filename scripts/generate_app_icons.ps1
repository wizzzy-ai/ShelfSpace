param(
    [string]$Source = (Join-Path $PSScriptRoot '..\assets\icons\shelfspace-source.jpg'),
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Save-ResizedPng([System.Drawing.Bitmap]$SourceBitmap, [int]$Size, [string]$Path) {
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(0, 40, 58))
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($SourceBitmap, 0, 0, $Size, $Size)
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

$sourcePath = [System.IO.Path]::GetFullPath($Source)
$image = [System.Drawing.Bitmap]::new($sourcePath)
try {
    # The supplied artwork uses black outside the navy circular field. Match those
    # pixels to the field so the icon remains full bleed when platforms square it.
    for ($y = 0; $y -lt $image.Height; $y++) {
        for ($x = 0; $x -lt $image.Width; $x++) {
            $pixel = $image.GetPixel($x, $y)
            if ($pixel.R -lt 20 -and $pixel.G -lt 65 -and $pixel.B -lt 85) {
                $image.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 0, 40, 58))
            }
        }
    }

    $iconsRoot = Join-Path $ProjectRoot 'assets\icons'
    New-Item -ItemType Directory -Force -Path $iconsRoot | Out-Null
    $master = Join-Path $iconsRoot 'app_icon.png'
    Save-ResizedPng $image 1024 $master

    $outputs = @{}
    $sizes = @(16, 20, 29, 32, 40, 48, 58, 60, 64, 72, 76, 80, 87, 96, 120, 128, 144, 152, 167, 180, 192, 256, 512, 1024)
    foreach ($size in $sizes) {
        $path = Join-Path $iconsRoot ("icon-{0}.png" -f $size)
        Save-ResizedPng $image $size $path
        $outputs[$size] = $path
    }

    $android = Join-Path $ProjectRoot 'android\app\src\main\res'
    foreach ($density in @(@('mdpi',48), @('hdpi',72), @('xhdpi',96), @('xxhdpi',144), @('xxxhdpi',192))) {
        Copy-Item $outputs[$density[1]] (Join-Path $android ("mipmap-{0}\ic_launcher.png" -f $density[0])) -Force
    }
    Copy-Item $master (Join-Path $android 'drawable\ic_launcher_foreground.png') -Force

    $ios = Join-Path $ProjectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
    $iosFiles = @{
        'Icon-App-20x20@1x.png'=20; 'Icon-App-20x20@2x.png'=40; 'Icon-App-20x20@3x.png'=60
        'Icon-App-29x29@1x.png'=29; 'Icon-App-29x29@2x.png'=58; 'Icon-App-29x29@3x.png'=87
        'Icon-App-40x40@1x.png'=40; 'Icon-App-40x40@2x.png'=80; 'Icon-App-40x40@3x.png'=120
        'Icon-App-60x60@2x.png'=120; 'Icon-App-60x60@3x.png'=180
        'Icon-App-76x76@1x.png'=76; 'Icon-App-76x76@2x.png'=152
        'Icon-App-83.5x83.5@2x.png'=167; 'Icon-App-1024x1024@1x.png'=1024
    }
    foreach ($filename in $iosFiles.Keys) { Copy-Item $outputs[$iosFiles[$filename]] (Join-Path $ios $filename) -Force }

    $mac = Join-Path $ProjectRoot 'macos\Runner\Assets.xcassets\AppIcon.appiconset'
    foreach ($size in @(16, 32, 64, 128, 256, 512, 1024)) {
        $filename = "app_icon_{0}.png" -f $size
        Copy-Item $outputs[$size] (Join-Path $mac $filename) -Force
    }

    foreach ($webIcon in @(@('web\favicon.png', 32), @('web\icons\Icon-192.png', 192), @('web\icons\Icon-maskable-192.png', 192), @('web\icons\Icon-512.png', 512), @('web\icons\Icon-maskable-512.png', 512))) {
        Copy-Item $outputs[$webIcon[1]] (Join-Path $ProjectRoot $webIcon[0]) -Force
    }

    # ICO stores one PNG payload per supported Windows size.
    $windowsIcon = Join-Path $ProjectRoot 'windows\runner\resources\app_icon.ico'
    $icoSizes = @(16, 32, 48, 64, 128, 256)
    $entries = foreach ($size in $icoSizes) { [System.IO.File]::ReadAllBytes($outputs[$size]) }
    $stream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.BinaryWriter]::new($stream)
    try {
        $writer.Write([UInt16]0); $writer.Write([UInt16]1); $writer.Write([UInt16]$icoSizes.Count)
        $offset = 6 + (16 * $icoSizes.Count)
        for ($i = 0; $i -lt $icoSizes.Count; $i++) {
            $size = $icoSizes[$i]
            $dimension = if ($size -eq 256) { [byte]0 } else { [byte]$size }
            $writer.Write($dimension); $writer.Write($dimension)
            $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([UInt16]1); $writer.Write([UInt16]32)
            $writer.Write([UInt32]$entries[$i].Length); $writer.Write([UInt32]$offset)
            $offset += $entries[$i].Length
        }
        foreach ($entry in $entries) { $writer.Write($entry) }
        [System.IO.File]::WriteAllBytes($windowsIcon, $stream.ToArray())
    }
    finally { $writer.Dispose(); $stream.Dispose() }

    $linuxIcon = Join-Path $ProjectRoot 'linux\packaging\shelfspace.png'
    New-Item -ItemType Directory -Force -Path (Split-Path $linuxIcon) | Out-Null
    Copy-Item $outputs[512] $linuxIcon -Force

    foreach ($size in $sizes) { Remove-Item $outputs[$size] -Force }
}
finally { $image.Dispose() }
