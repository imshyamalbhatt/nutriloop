# Builds every icon from design/logo-source.png: the in-app logo, web/PWA icons, and the
# Android launcher icons (written to android/res, copied into the APK by build-apk.ps1).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path $PSScriptRoot -Parent
$src = [System.Drawing.Image]::FromFile("$repo\design\logo-source.png")
# the source is the green tile on a white page: crop to the tile (measured on the 1254 px source)
$k = $src.Width / 1254
$logoRect = New-Object System.Drawing.Rectangle ([int](51 * $k)), ([int](55 * $k)), ([int](1150 * $k)), ([int](1150 * $k))
$deep = [System.Drawing.ColorTranslator]::FromHtml('#023A26')

function Save-Icon($path, $size, $scale, $bg, $round) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'
  if ($bg) { $g.Clear($bg) } else { $g.Clear([System.Drawing.Color]::Transparent) }
  $d = [int]($size * $scale); $o = [int](($size - $d) / 2)
  if ($round) {                                   # clip to the tile's own rounded corners (white page hidden)
    $r = [int]($d * 0.235); $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc($o, $o, 2 * $r, 2 * $r, 180, 90); $p.AddArc($o + $d - 2 * $r, $o, 2 * $r, 2 * $r, 270, 90)
    $p.AddArc($o + $d - 2 * $r, $o + $d - 2 * $r, 2 * $r, 2 * $r, 0, 90); $p.AddArc($o, $o + $d - 2 * $r, 2 * $r, 2 * $r, 90, 90)
    $p.CloseFigure(); $g.SetClip($p)
  }
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle $o, $o, $d, $d), $logoRect, [System.Drawing.GraphicsUnit]::Pixel)
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}

Save-Icon "$repo\assets\logo.png" 256 1 $null $true
Save-Icon "$repo\icon-192.png" 192 1 $null $true
Save-Icon "$repo\icon-512.png" 512 1 $null $true
Save-Icon "$repo\icon-maskable-512.png" 512 1.12 $deep $true

# Android: legacy square/round icons plus adaptive foreground (tile inside the 72dp visible part of the
# 108dp canvas, so round launcher masks don't clip the leaf tip; background colour is #023A26)
$dens = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
foreach ($kd in $dens.Keys) {
  $s = $dens[$kd]; $dir = "$repo\android\res\mipmap-$kd"
  Save-Icon "$dir\ic_launcher.png" $s 1 $null $true
  Save-Icon "$dir\ic_launcher_round.png" $s 1.12 $deep $true
  Save-Icon "$dir\ic_launcher_foreground.png" ([int]($s * 2.25)) 0.68 $null $true
}

# Launch splash (Android 11 and older; 12+ uses the icon on windowSplashScreenBackground)
$splashBg = [System.Drawing.ColorTranslator]::FromHtml('#04452D')
function Save-Splash($path, $w, $h) {
  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.Clear($splashBg)
  $d = [int]([Math]::Min($w, $h) * 0.32); $x = [int](($w - $d) / 2); $y = [int](($h - $d) / 2)
  $r = [int]($d * 0.235); $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddArc($x, $y, 2 * $r, 2 * $r, 180, 90); $p.AddArc($x + $d - 2 * $r, $y, 2 * $r, 2 * $r, 270, 90)
  $p.AddArc($x + $d - 2 * $r, $y + $d - 2 * $r, 2 * $r, 2 * $r, 0, 90); $p.AddArc($x, $y + $d - 2 * $r, 2 * $r, 2 * $r, 90, 90)
  $p.CloseFigure(); $g.SetClip($p)
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle $x, $y, $d, $d), $logoRect, [System.Drawing.GraphicsUnit]::Pixel)
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}
$sp = @{ mdpi = @(320, 480); hdpi = @(480, 800); xhdpi = @(720, 1280); xxhdpi = @(960, 1600); xxxhdpi = @(1280, 1920) }
foreach ($kd in $sp.Keys) {
  $w = $sp[$kd][0]; $h = $sp[$kd][1]
  Save-Splash "$repo\android\res\drawable-port-$kd\splash.png" $w $h
  Save-Splash "$repo\android\res\drawable-land-$kd\splash.png" $h $w
}
Save-Splash "$repo\android\res\drawable\splash.png" 480 320

# Notification icon: white silhouette of the leaf + loop (status bar icons must be one colour)
$tile = New-Object System.Drawing.Bitmap 256, 256
$g = [System.Drawing.Graphics]::FromImage($tile); $g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, 256, 256), $logoRect, [System.Drawing.GraphicsUnit]::Pixel); $g.Dispose()
$mask = New-Object System.Drawing.Bitmap 256, 256
for ($yy = 0; $yy -lt 256; $yy++) { for ($xx = 0; $xx -lt 256; $xx++) {
  # outside the tile's rounded corners is the white page: skip it
  $cx = [Math]::Max(0, [Math]::Max(64 - $xx, $xx - 191)); $cy = [Math]::Max(0, [Math]::Max(64 - $yy, $yy - 191))
  $c = $tile.GetPixel($xx, $yy); $a = if ($cx * $cx + $cy * $cy -gt 3600) { 0 } else { [Math]::Max(0, [Math]::Min(255, [int](($c.G - 150) * 6))) }
  $mask.SetPixel($xx, $yy, [System.Drawing.Color]::FromArgb($a, 255, 255, 255))
} }
$tile.Dispose()
$st = @{ mdpi = 24; hdpi = 36; xhdpi = 48; xxhdpi = 72; xxxhdpi = 96 }
foreach ($kd in $st.Keys) {
  $s = $st[$kd]; $bmp = New-Object System.Drawing.Bitmap $s, $s
  $g = [System.Drawing.Graphics]::FromImage($bmp); $g.InterpolationMode = 'HighQualityBicubic'; $g.Clear([System.Drawing.Color]::Transparent)
  $g.DrawImage($mask, (New-Object System.Drawing.Rectangle 0, 0, $s, $s))
  New-Item -ItemType Directory -Force "$repo\android\res\drawable-$kd" | Out-Null
  $bmp.Save("$repo\android\res\drawable-$kd\ic_stat_leaf.png", [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}
$mask.Dispose()
$src.Dispose()
"Icons written."
