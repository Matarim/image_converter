#!/bin/bash

if ! command -v ruby &> /dev/null; then
    echo "Ruby not found. Installing via Homebrew... (may prompt for password)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install ruby
    export PATH="/usr/local/opt/ruby/bin:$PATH"
fi

gem install glimmer-dsl-libui mini_magick
if ! command -v platypus &> /dev/null; then
    echo "Platypus not found. Installing via Homebrew... (may prompt for password)"
    brew install --cask platypus
fi

if ! command -v magick &> /dev/null || ! magick identify -list delegate | grep -q 'rsvg'; then
    echo "Installing ImageMagick with full delegate support... (may prompt for password and take time)"
    brew install pkg-config libwebp libheif librsvg ghostscript
    curl -O https://imagemagick.org/archive/ImageMagick.tar.gz
    if [ $? -ne 0 ]; then
        echo "Download failed. Exiting."
        exit 1
    fi
    tar xzvf ImageMagick.tar.gz
    cd ImageMagick-7.1.2-*
    ./configure --prefix=/usr/local --with-webp --with-heif --with-rsvg
    make
    sudo make install
    cd ..
    rm -rf ImageMagick*
fi

curl -O https://github.com/Matarim/image_converter/blob/main/image_converter.rb
if [ $? -ne 0 ]; then
    echo "Download failed. Exiting."
    exit 1
fi
curl -O https://github.com/Matarim/image_converter/blob/main/logo.png
sips -s format icns icon.png --out icon.icns

# Create LICENSE.txt for Platypus BSD 3-Clause license
cat << EOF > LICENSE.txt
Copyright (c) 2003-2025 Sveinbjorn Thordarson

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EOF

platypus -a 'Image Converter' -o None -i icon.icns -p /usr/bin/ruby -f LICENSE.txt image_converter.rb

hdiutil create -volname "Image Converter" -srcfolder "Image Converter.app" -ov -format UDZO ImageConverter.dmg

read -p "Do you want to add Image Converter to your Applications folder? (y/n): " choice
if [ "$choice" = "y" ]; then
    echo "Copying to /Applications... (may prompt for password)"
    sudo cp -R "Image Converter.app" /Applications/
    echo "App placed in Applications. Open via Spotlight or Finder."
else
    echo "App bundle created in current folder. Drag Image Converter.app to Applications manually."
fi

rm icon.icns LICENSE.txt

open "/Applications/Image Converter.app" || open "Image Converter.app"