TEMPLATE = app

QT += qml quick widgets printsupport webkitwidgets

SOURCES += main.cpp \
    posprinter.cpp

RESOURCES += qml.qrc

win32-g++{
    LIBS += C:\Qt5.4\Tools\mingw491_32\i686-w64-mingw32\lib\libwinspool.a
}
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
ICON = image_source/osx_icon.icns

OTHER_FILES += \
    app.rc

RC_FILE = app.rc

HEADERS += \
    posprinter.h
