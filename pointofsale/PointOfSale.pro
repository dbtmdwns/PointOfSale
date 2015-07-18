TEMPLATE = app

QT += qml quick widgets printsupport

SOURCES += main.cpp \
    posprinter.cpp \
    escimage.cpp

RESOURCES += qml.qrc

win32-g++{
  message(Qt is installed in $$[QT_INSTALL_PREFIX])
  LIBS += $$[QT_INSTALL_PREFIX]\..\..\Tools\mingw491_32\i686-w64-mingw32\lib\libwinspool.a
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
    posprinter.h \
    escimage.h

DISTFILES += \
    README.md
