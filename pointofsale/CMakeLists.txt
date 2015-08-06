# Find the Qt components we need.

find_package(Qt5Quick REQUIRED)
find_package(Qt5Core REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Xml REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Sql REQUIRED)
find_package(Qt5XmlPatterns REQUIRED)
find_package(Qt5Concurrent REQUIRED)
find_package(Qt5Svg REQUIRED)
find_package(Qt5QuickWidgets REQUIRED)
find_package(Qt5Location REQUIRED)
find_package(Qt5Script REQUIRED)
find_package(Qt5Declarative REQUIRED)
find_package(Qt5PrintSupport REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5OpenGL REQUIRED)
find_package(Qt5OpenGLExtensions REQUIRED)
find_package(Qt5Positioning REQUIRED)

#find_package(Qt5WebEngineWidgets REQUIRED)
#find_package(Qt5WebEngineCore REQUIRED)
#find_package(Qt5WebKit REQUIRED)
#find_package(Qt5WebView REQUIRED)
#find_package(Qt5WebEngine REQUIRED)
#find_package(Qt5WebKitWidgets REQUIRED)

set(pointofsale_srcs
  main.cpp
  posprinter.cpp
  escimage.cpp
)

qt5_wrap_ui(ui_srcs

)

qt5_add_resources(rcc_srcs qml.qrc)

# Need to add current binary dir to include path for UI file headers
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# if we are building statically then we need HDF5 targets
if(NOT BUILD_SHARED_LIBS)
  # find_package(HDF5 REQUIRED COMPONENTS C)
endif()


# Handle Mac OS X specific icons etc.
if(APPLE)
  list(APPEND pointofsale_srcs image_source/osx_icon.icns)
  set(MACOSX_BUNDLE_ICON_FILE osx_icon.icns)
  set(MACOSX_BUNDLE_BUNDLE_VERSION "${PointOfSale_VERSION}")
  set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.tualo.PointOfSale")
  set_source_files_properties(image_source/osx_icon.icns PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources)

  #set(MACOSX_BUNDLE_INFO_FILE Resources/Info.plist.in)
  message("current source ${CMAKE_CURRENT_SOURCE_DIR}")
  set(MACOSX_BUNDLE_INFO_FILE "${CMAKE_CURRENT_SOURCE_DIR}/MacOSXBundleInfo.plist.in")
  set(MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/MacOSXBundleInfo.plist.in")


elseif(UNIX)
message("fix me")
#  install(FILES "image_source/avogadro2.desktop" DESTINATION "${INSTALL_XDG_APPS_DIR}")
#  install(FILES "icons/avogadro.png" DESTINATION "${INSTALL_XDG_ICON_DIR}" RENAME "avogadro2.png")
elseif(WIN32)
  list(APPEND pointofsale_srcs app.rc)
endif()



add_executable(pointofsale WIN32 MACOSX_BUNDLE
  ${pointofsale_srcs} ${ui_srcs} ${rcc_srcs})
qt5_use_modules(pointofsale Widgets OpenGL Network Concurrent)


qt5_use_modules(pointofsale
  Quick
  Core
  Qml
  Xml
  Gui
  Network
  Sql
  XmlPatterns
  Concurrent
  Svg
  QuickWidgets
  Location
  Script
  Declarative
  PrintSupport
  Widgets
  OpenGL
  OpenGLExtensions
  Positioning
  )


if(WIN32)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:MSVCRTD")
  target_link_libraries(pointofsale Qt5::WinMain)
endif()
set_target_properties(pointofsale PROPERTIES AUTOMOC TRUE)



if(APPLE)
  set_target_properties(pointofsale PROPERTIES OUTPUT_NAME ${MACOSX_BUNDLE_NAME})
else()
  set_target_properties(pointofsale PROPERTIES OUTPUT_NAME "pointofsale2")
endif()

install(TARGETS pointofsale
  RUNTIME DESTINATION ${INSTALL_RUNTIME_DIR}
  BUNDLE DESTINATION .
  )
