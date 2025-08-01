# Ruby Image Converter

A simple desktop application built with Ruby, Glimmer DSL for LibUI, and MiniMagick for converting images between various formats, adjusting quality and size.

## Description

Image Converter is a user-friendly GUI tool that allows you to select an input image, detect its format (or choose a new one), adjust quality and size settings, and save the converted image to a specified folder. It supports all formats provided by ImageMagick and handles special cases like ICO resizing limits.

## Features

- **Input Image Selection**: Browse and select an image file; automatically detects and displays the format.
- **Output Format Selection**: Choose from over 150 ImageMagick-supported formats (auto-detected from input if possible).
- **Quality Adjustment**: Select quality levels from 10% to 100% (default 100%).
- **Size Adjustment**: Resize the image by percentage (25% to 100%, default 100%).
- **Output Folder Selection**: Browse and choose where to save the converted file.
- **Error Handling**: User-friendly messages for invalid inputs or conversion errors.
- **Cross-Platform**: Runs on macOS, Windows, and Linux via LibUI's native widgets.

## Installation

### Prerequisites
- Ruby 3.0+ (tested on 3.4.2)
- ImageMagick installed on your system (required for MiniMagick):
    - macOS: `brew install imagemagick`
    - Windows: Download from https://imagemagick.org/script/download.php

### Setup
1. Install the required gems:
2. Download the `image_converter.rb` script to your local machine.
3. Run the app:

For packaging into a standalone executable, refer to the advanced section below.

## Usage

1. Launch the app with `ruby image_converter.rb`.
2. Click "Select Image" to choose your input file (format is auto-detected).
3. Optionally adjust "Output Format", "Quality", and "Size".
4. Click "Select Folder" to choose the output directory.
5. Click "Convert" to process and save the image.
6. Success or error messages will appear in pop-ups.

Example: Convert a PNG to JPG at 80% quality and 75% size.

## Dependencies

- `glimmer-dsl-libui` (~> 0.12.8): For the GUI.
- `mini_magick` (~> 5.3.0): For image processing via ImageMagick.
- ImageMagick (system dependency).

## Advanced: Packaging

To create a standalone app:
- On macOS: Use Platypus to bundle into a .app (install via `brew install --cask platypus`).
- On Windows: Use OCRA (`gem install ocran`) to build an EXE.
- Refer to earlier conversation for installer scripts.

## License

MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributing

Fork the repo, make changes, and submit a pull request. Issues and feature requests welcome!