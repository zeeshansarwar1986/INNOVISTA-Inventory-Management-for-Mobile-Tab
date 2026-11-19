Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\hp\.gemini\antigravity\brain\ac34cebc-19ec-4753-b6de-896127802e1c\.user_uploaded\media_1794573288551_79c79339.jpg"
if (-not (Test-Path $srcPath)) {
    throw "Source image not found: $srcPath"
}

$origImg = [System.Drawing.Image]::FromFile($srcPath)
$origBmp = New-Object System.Drawing.Bitmap($origImg)

$width = $origBmp.Width
$height = $origBmp.Height
$cx = $width / 2.0
$cy = $height / 2.0

# 1. Create a clean 900x900 bitmap with 100% black background outside radius 425
$cleanBmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$black = [System.Drawing.Color]::FromArgb(255, 0, 0, 0)

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $p = $origBmp.GetPixel($x, $y)
        $dist = [Math]::Sqrt([Math]::Pow($x - $cx, 2) + [Math]::Pow($y - $cy, 2))
        
        # If outside circle radius or white/near-white corner pixel, make pure black
        if ($dist -ge 425 -or ($p.R -gt 150 -and $p.G -gt 150 -and $p.B -gt 150 -and $dist -gt 390)) {
            $cleanBmp.SetPixel($x, $y, $black)
        } else {
            $cleanBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $p.R, $p.G, $p.B))
        }
    }
}

# Helper to scale bitmap high quality
function Scale-Bitmap($src, $targetW, $targetH, $bgFillColor = $null, $innerScale = 1.0) {
    $dest = New-Object System.Drawing.Bitmap($targetW, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    if ($bgFillColor -ne $null) {
        $brush = New-Object System.Drawing.SolidBrush($bgFillColor)
        $g.FillRectangle($brush, 0, 0, $targetW, $targetH)
        $brush.Dispose()
    } else {
        $g.Clear([System.Drawing.Color]::Transparent)
    }

    if ($innerScale -eq 1.0) {
        $g.DrawImage($src, 0, 0, $targetW, $targetH)
    } else {
        $w = [int]($targetW * $innerScale)
        $h = [int]($targetH * $innerScale)
        $x = [int](($targetW - $w) / 2.0)
        $y = [int](($targetH - $h) / 2.0)
        $g.DrawImage($src, $x, $y, $w, $h)
    }

    $g.Dispose()
    return $dest
}

$projectDir = "C:\Users\hp\Downloads\app innovista\Innovista Ap"

# 2. Update www/icons
Write-Host "Updating www/icons..."
$icon192 = Scale-Bitmap $cleanBmp 192 192 $black 1.0
$icon192.Save("$projectDir\www\icons\icon-192.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon192.Dispose()

$icon512 = Scale-Bitmap $cleanBmp 512 512 $black 1.0
$icon512.Save("$projectDir\www\icons\icon-512.png", [System.Drawing.Imaging.ImageFormat]::Png)
$icon512.Dispose()

# 3. Update Android project resources (Capacitor)
Write-Host "Updating Android project resources..."
$resDir = "$projectDir\android\app\src\main\res"

# Update values/ic_launcher_background.xml to #000000
$bgXmlPath = "$resDir\values\ic_launcher_background.xml"
$bgXmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#000000</color>
</resources>
"@
[System.IO.File]::WriteAllText($bgXmlPath, $bgXmlContent.Trim())

# Update drawable/ic_launcher_background.xml to solid black vector
$drawBgXmlPath = "$resDir\drawable\ic_launcher_background.xml"
$drawBgContent = @"
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#000000"
        android:pathData="M0,0h108v108h-108z" />
</vector>
"@
[System.IO.File]::WriteAllText($drawBgXmlPath, $drawBgContent.Trim())

# Density mappings
# Standard icon sizes: mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192
# Foreground sizes (108dp): mdpi: 108, hdpi: 162, xhdpi: 216, xxhdpi: 324, xxxhdpi: 432
$densities = @(
    @{ name = "mipmap-mdpi";    iconSize = 48;  fgSize = 108 },
    @{ name = "mipmap-hdpi";    iconSize = 72;  fgSize = 162 },
    @{ name = "mipmap-xhdpi";   iconSize = 96;  fgSize = 216 },
    @{ name = "mipmap-xxhdpi";  iconSize = 144; fgSize = 324 },
    @{ name = "mipmap-xxxhdpi"; iconSize = 192; fgSize = 432 }
)

foreach ($d in $densities) {
    $dir = "$resDir\$($d.name)"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    # Legacy icon (pure black background, full bleed)
    $ic = Scale-Bitmap $cleanBmp $d.iconSize $d.iconSize $black 1.0
    $ic.Save("$dir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $ic.Save("$dir\ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $ic.Dispose()

    # Adaptive foreground (scaled to ~66% safe zone, black background)
    $fg = Scale-Bitmap $cleanBmp $d.fgSize $d.fgSize $black 0.66
    $fg.Save("$dir\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $fg.Dispose()
    Write-Host "Generated $($d.name): icon=$($d.iconSize)x$($d.iconSize), fg=$($d.fgSize)x$($d.fgSize)"
}

$cleanBmp.Dispose()
$origBmp.Dispose()
$origImg.Dispose()
Write-Host "All icons generated successfully with 100% black background!"

