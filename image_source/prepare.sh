#!/bin/bash
# This script converts the logo.svg into all needed transparent png files for
# the osx application icon-set file and windows ico
# Note: imagick convert is needed

echo "Creating OSX Images"
convert +antialias -background transparent  logo.svg -resize 1024x1024 osx.png
mkdir osx_icon.iconset
sips -z 16 16     osx.png --out osx_icon.iconset/icon_16x16.png
sips -z 32 32     osx.png --out osx_icon.iconset/icon_16x16@2x.png
sips -z 32 32     osx.png --out osx_icon.iconset/icon_32x32.png
sips -z 64 64     osx.png --out osx_icon.iconset/icon_32x32@2x.png
sips -z 128 128   osx.png --out osx_icon.iconset/icon_128x128.png
sips -z 256 256   osx.png --out osx_icon.iconset/icon_128x128@2x.png
sips -z 256 256   osx.png --out osx_icon.iconset/icon_256x256.png
sips -z 512 512   osx.png --out osx_icon.iconset/icon_256x256@2x.png
sips -z 512 512   osx.png --out osx_icon.iconset/icon_512x512.png
cp osx.png osx_icon.iconset/icon_512x512@2x.png
iconutil -c icns osx_icon.iconset
rm -R osx_icon.iconset


echo "Creating Windows ICO"

#convert osx.png -bordercolor white -border 0  -clone 0 -resize 16x16  -clone 0 -resize 24x24  -clone 0 -resize 32x32 -clone 0 -resize 40x40 -clone 0 -resize 48x48 -clone 0 -resize 64x64 -clone 0 -resize 256x256 -delete 0 -alpha off -colors 256 icon.ico
mkdir win
convert osx.png +antialias -background transparent -bordercolor white -border 0 -resize 256x256 win/icon-256.png
convert win/icon-256.png -resize 16x16 win/icon-16.png
convert win/icon-256.png -resize 24x24 win/icon-24.png
convert win/icon-256.png -resize 32x32 win/icon-32.png
convert win/icon-256.png -resize 64x64 win/icon-64.png
convert win/icon-256.png -resize 128x128 win/icon-128.png
convert win/icon-16.png win/icon-32.png win/icon-24.png win/icon-64.png win/icon-128.png win/icon-256.png  -alpha off -colors 256 icon.ico


echo "Creating Android PNG"

#convert osx.png -bordercolor white -border 0  -clone 0 -resize 16x16  -clone 0 -resize 24x24  -clone 0 -resize 32x32 -clone 0 -resize 40x40 -clone 0 -resize 48x48 -clone 0 -resize 64x64 -clone 0 -resize 256x256 -delete 0 -alpha off -colors 256 icon.ico
mkdir Android
mkdir Android/drawable-hdpi
mkdir Android/drawable-xhdpi
mkdir Android/drawable-xxhdpi
mkdir Android/drawable-mdpi
convert +antialias -background transparent logo.svg -resize 256x256 Android/icon-256.png
convert +antialias -background transparent logo.svg -resize 72x72 Android/drawable-hdpi/ic_launcher.png
convert +antialias -background transparent logo.svg -resize 48x48 Android/drawable-mdpi/ic_launcher.png
convert +antialias -background transparent logo.svg -resize 96x96 Android/drawable-xhdpi/ic_launcher.png
convert +antialias -background transparent logo.svg -resize 144x144 Android/drawable-xxhdpi/ic_launcher.png

rm osx.png
