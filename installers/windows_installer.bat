@echo off

:: Self-elevate for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin rights... (UAC prompt may appear; enter password if needed)
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Check if Ruby is installed
ruby -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Ruby not found. Downloading and installing latest RubyInstaller...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.4.1-1/rubyinstaller-3.4.1-1-x64.exe' -OutFile 'rubyinstaller.exe'"
    if not exist rubyinstaller.exe (
        echo Download failed. Exiting.
        exit /b 1
    )
    rubyinstaller.exe /silent /tasks=assocfiles,addtopath
    del rubyinstaller.exe
    setx /M PATH "%PATH%"
)

:: Check if ImageMagick is installed
magick -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ImageMagick not found. Downloading and installing latest version...
    powershell -Command "Invoke-WebRequest -Uri 'https://imagemagick.org/archive/binaries/ImageMagick-7.1.2-0-Q16-HDRI-x64-dll.exe' -OutFile 'imagemagick.exe'"
    if not exist imagemagick.exe (
        echo Download failed. Exiting.
        exit /b 1
    )
    imagemagick.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /DIR="C:\ImageMagick"
    setx /M PATH "%PATH%;C:\ImageMagick"
    del imagemagick.exe
)

:: Install Ghostscript for PDF/PS/EPS support
gswin64c -v >nul 2>&1
if %errorlevel% neq 0 (
    echo Ghostscript not found. Downloading and installing for PDF support...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10031/gs10031w64.exe' -OutFile 'ghostscript.exe'"
    if not exist ghostscript.exe (
        echo Download failed. Exiting.
        exit /b 1
    )
    ghostscript.exe /S /NOCANCEL /NORESTART /DIR="C:\Ghostscript"
    setx /M PATH "%PATH%;C:\Ghostscript\bin"
    del ghostscript.exe
)

:: Install Inkscape for full SVG support (as delegate)
inkscape --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Inkscape not found. Downloading and installing for SVG support...
    powershell -Command "Invoke-WebRequest -Uri 'https://media.inkscape.org/dl/resources/file/inkscape-1.3.2_2023-11-25_091e20e-x64.msi' -OutFile 'inkscape.msi'"
    if not exist inkscape.msi (
        echo Download failed. Exiting.
        exit /b 1
    )
    msiexec /i inkscape.msi /quiet /norestart ADDLOCAL=ALL
    setx /M PATH "%PATH%;C:\Program Files\Inkscape\bin"
    del inkscape.msi
)

:: Install gems and OCRA
gem install glimmer-dsl-libui mini_magick ocran

:: Download source files (replace with your actual URLs)
powershell -Command "Invoke-WebRequest -Uri 'https://your-repo.com/image_converter.rb' -OutFile 'image_converter.rb'"
powershell -Command "Invoke-WebRequest -Uri 'https://your-repo.com/icon.png' -OutFile 'icon.png'"

:: Convert icon to ICO
magick convert icon.png icon.ico

:: Create LICENSE.txt for OCRA MIT license
echo (The MIT License) > LICENSE.txt
echo. >> LICENSE.txt
echo Copyright (c) 2009-2020 Lars Christensen >> LICENSE.txt
echo Copyright (c) 2020-2025 The OCRA Committers Team >> LICENSE.txt
echo. >> LICENSE.txt
echo Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: >> LICENSE.txt
echo. >> LICENSE.txt
echo The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. >> LICENSE.txt
echo. >> LICENSE.txt
echo THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. >> LICENSE.txt

:: Package to EXE, including LICENSE.txt
ocran image_converter.rb LICENSE.txt --output ImageConverter.exe --gem-full --add-all-core --icon icon.ico

:: Ask user for desktop placement
set /p choice="Do you want to place a shortcut on the Desktop? (y/n): "
if /i "%choice%"=="y" (
    echo Creating desktop shortcut...
    powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('$env:USERPROFILE\Desktop\Image Converter.lnk'); $s.TargetPath = '%CD%\ImageConverter.exe'; $s.IconLocation = '%CD%\icon.ico'; $s.Save()"
    echo Shortcut created on Desktop.
)

:: Run the app
ImageConverter.exe

:: Clean up
del LICENSE.txt icon.ico