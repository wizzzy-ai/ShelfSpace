param(
    [Parameter(Mandatory = $true)]
    [string]$Archive,
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('shelfspace-icons-' + [guid]::NewGuid().ToString('N'))
Expand-Archive -LiteralPath ([System.IO.Path]::GetFullPath($Archive)) -DestinationPath $tempRoot
try {
    $source = Join-Path $tempRoot 'original\icon-1024.png'
    $androidRes = Join-Path $tempRoot 'android\res'
    $iconMaster = Join-Path $ProjectRoot 'assets\icons\app_icon.png'
    New-Item -ItemType Directory -Force -Path (Split-Path $iconMaster) | Out-Null
    Copy-Item $source $iconMaster -Force

    # Android density icons and adaptive launcher foreground.
    $androidTarget = Join-Path $ProjectRoot 'android\app\src\main\res'
    foreach ($density in @('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi')) {
        Copy-Item (Join-Path $androidRes "mipmap-$density\ic_launcher.png") (Join-Path $androidTarget "mipmap-$density\ic_launcher.png") -Force
        Copy-Item (Join-Path $androidRes "mipmap-$density\ic_launcher_round.png") (Join-Path $androidTarget "mipmap-$density\ic_launcher_round.png") -Force
    }
    Copy-Item $source (Join-Path $androidTarget 'drawable\ic_launcher_foreground.png') -Force
    $playStore = Join-Path $ProjectRoot 'android\playstore'
    New-Item -ItemType Directory -Force -Path $playStore | Out-Null
    Copy-Item (Join-Path $tempRoot 'android\playstore\play_store_icon.png') (Join-Path $playStore 'play_store_icon.png') -Force

    # iOS asset catalog is provided as a complete Xcode AppIcon set.
    $iosTarget = Join-Path $ProjectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
    Copy-Item (Join-Path $tempRoot 'ios\AppIcon.appiconset\*') $iosTarget -Force

    # Web favicon, touch icon, and PWA assets. Keep the Flutter manifest paths.
    $webTarget = Join-Path $ProjectRoot 'web'
    $webIcons = Join-Path $webTarget 'icons'
    Copy-Item (Join-Path $tempRoot 'web\favicon-32x32.png') (Join-Path $webTarget 'favicon.png') -Force
    Copy-Item (Join-Path $tempRoot 'web\favicon.ico') (Join-Path $webTarget 'favicon.ico') -Force
    Copy-Item (Join-Path $tempRoot 'web\apple-touch-icon.png') (Join-Path $webTarget 'apple-touch-icon.png') -Force
    Copy-Item (Join-Path $tempRoot 'web\icon-192.png') (Join-Path $webIcons 'Icon-192.png') -Force
    Copy-Item (Join-Path $tempRoot 'web\icon-512.png') (Join-Path $webIcons 'Icon-512.png') -Force
    Copy-Item (Join-Path $tempRoot 'web\icon-192-maskable.png') (Join-Path $webIcons 'Icon-maskable-192.png') -Force
    Copy-Item (Join-Path $tempRoot 'web\icon-512-maskable.png') (Join-Path $webIcons 'Icon-maskable-512.png') -Force

    # macOS AppIcon set.
    $image = [System.Drawing.Bitmap]::new($source)
    try {
        $macTarget = Join-Path $ProjectRoot 'macos\Runner\Assets.xcassets\AppIcon.appiconset'
        foreach ($size in @(16, 32, 64, 128, 256, 512, 1024)) {
            $bitmap = [System.Drawing.Bitmap]::new($size, $size)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($image, 0, 0, $size, $size)
                $bitmap.Save((Join-Path $macTarget "app_icon_$size.png"), [System.Drawing.Imaging.ImageFormat]::Png)
            } finally { $graphics.Dispose(); $bitmap.Dispose() }
        }

        # Linux bundle and Windows multi-size ICO.
        $linuxTarget = Join-Path $ProjectRoot 'linux\packaging\shelfspace.png'
        $linuxBitmap = [System.Drawing.Bitmap]::new(512, 512)
        $graphics = [System.Drawing.Graphics]::FromImage($linuxBitmap)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($image, 0, 0, 512, 512)
            $linuxBitmap.Save($linuxTarget, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally { $graphics.Dispose(); $linuxBitmap.Dispose() }

        $icoSizes = @(16, 32, 48, 64, 128, 256)
        $pngs = @{}
        foreach ($size in $icoSizes) {
            $bitmap = [System.Drawing.Bitmap]::new($size, $size)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $stream = [System.IO.MemoryStream]::new()
            try {
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($image, 0, 0, $size, $size)
                $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
                $pngs[$size] = $stream.ToArray()
            } finally { $stream.Dispose(); $graphics.Dispose(); $bitmap.Dispose() }
        }
        $icoStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.BinaryWriter]::new($icoStream)
        try {
            $writer.Write([UInt16]0); $writer.Write([UInt16]1); $writer.Write([UInt16]$icoSizes.Count)
            $offset = 6 + (16 * $icoSizes.Count)
            foreach ($size in $icoSizes) {
                $dimension = if ($size -eq 256) { [byte]0 } else { [byte]$size }
                $writer.Write($dimension); $writer.Write($dimension)
                $writer.Write([byte]0); $writer.Write([byte]0); $writer.Write([UInt16]1); $writer.Write([UInt16]32)
                $writer.Write([UInt32]$pngs[$size].Length); $writer.Write([UInt32]$offset)
                $offset += $pngs[$size].Length
            }
            foreach ($size in $icoSizes) { $writer.Write($pngs[$size]) }
            [System.IO.File]::WriteAllBytes((Join-Path $ProjectRoot 'windows\runner\resources\app_icon.ico'), $icoStream.ToArray())
        } finally { $writer.Dispose(); $icoStream.Dispose() }
    } finally { $image.Dispose() }
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}
