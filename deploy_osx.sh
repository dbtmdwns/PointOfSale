#~/Qt/5.4/clang_64/bin/macdeployqt bin/PointOfSale.app -dmg -verbose=3
#~/Qt/5.5/clang_64/bin/macdeployqt \
#/Users/thomashoffmann/Documents/Projects/qt/PointOfSale/bin/PointOfSale.app \
#-verbose=3 \
#-qmldir=/Users/thomashoffmann/Documents/Projects/qt/PointOfSale/pointofsale/qml

~/Qt/5.5/clang_64/bin/macdeployqt bin/PointOfSale.app -executable=bin/PointOfSale.app/Contents/MacOS/PointOfSale -qmldir=/Users/thomashoffmann/Documents/Projects/qt/PointOfSale/pointofsale/qml
cp -r ~/Qt/5.5/clang_64/qml bin/PointOfSale.app/Contents/Resources/
find bin/PointOfSale.app/Contents/Resources/qml -name "*_debug*" -exec rm -rf {} \;
