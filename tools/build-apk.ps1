# Rebuilds NutriLoop.apk on Shyamal's laptop and copies it to Downloads.
# Only needed for native changes (loader, plugins, icon, app name, android/*). Normal app changes
# just need a push to main: the phone downloads them on next launch.
# Before building a new APK: bump versionCode/versionName in android/native/app.build.gradle,
# then publish it with: gh release create v<version> "$env:USERPROFILE\Downloads\NutriLoop.apk"
$ErrorActionPreference = 'Stop'
$b = "C:\Users\bhatt\android-build"
$repo = Split-Path $PSScriptRoot -Parent
$cap = "$b\nutriloop"
$main = "$cap\android\app\src\main"

Remove-Item "$cap\www\*" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$cap\www" | Out-Null
Copy-Item "$repo\index.html" "$cap\www\app.html"
Copy-Item "$repo\android\loader.html" "$cap\www\index.html"
Copy-Item "$repo\manifest.json", "$repo\icon-192.png", "$repo\icon-512.png", "$repo\icon-maskable-512.png" "$cap\www"
Copy-Item "$repo\assets" "$cap\www\assets" -Recurse
Copy-Item "$repo\android\capacitor.config.json" "$cap\capacitor.config.json" -Force
# native code, manifest, gradle, icons, splash and theme are all kept in the repo
Copy-Item "$repo\android\native\*.java" "$main\java\com\shyamal\nutriloop\" -Force
Copy-Item "$repo\android\native\AndroidManifest.xml" "$main\AndroidManifest.xml" -Force
Copy-Item "$repo\android\native\app.build.gradle" "$cap\android\app\build.gradle" -Force
Copy-Item "$repo\android\res\*" "$main\res\" -Recurse -Force
Remove-Item "$main\res\drawable-v24\ic_launcher_foreground.xml", "$main\res\drawable\ic_launcher_background.xml" -ErrorAction SilentlyContinue # Capacitor's sample icon

$env:JAVA_HOME = "$b\jdk-21.0.12.1+1"; $env:ANDROID_HOME = "$b\sdk"; $env:Path = "$env:JAVA_HOME\bin;$env:Path"
Push-Location $cap; npx cap sync android; Pop-Location
Push-Location "$cap\android"; & .\gradlew.bat assembleDebug --no-daemon -q --console=plain; $code = $LASTEXITCODE; Pop-Location
if ($code -ne 0) { throw "Gradle build failed ($code)" }

Copy-Item "$cap\android\app\build\outputs\apk\debug\app-debug.apk" "$env:USERPROFILE\Downloads\NutriLoop.apk" -Force
"APK ready: $env:USERPROFILE\Downloads\NutriLoop.apk"
