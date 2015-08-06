cmake_minimum_required(VERSION 3.1)
project(PointOfSale)

cmake_policy (SET CMP0020 NEW)

SET(CMAKE_BUILD_TYPE "Release")

set(CMAKE_PREFIX_PATH $ENV{QTDIR})
set(CMAKE_MODULE_PATH ${PointOfSale_SOURCE_DIR}/cmake)

set(QT5_PATH $ENV{HOME}/Qt/5.5/clang_64/ CACHE PATH "Path to Qt5")
set(QT5_MODULE_PATH ${QT5_PATH}/lib/cmake)
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${QT5_MODULE_PATH})

message("including ${PointOfSale_SOURCE_DIR}/cmake ")

include(BuildType)
include(BuildLocation)
include(CompilerFlags)
include(InstallLocation)
include(DetermineVersion)


# Set up our version.
set(PointOfSale_VERSION_MAJOR   "0")
set(PointOfSale_VERSION_MINOR   "0")
set(PointOfSale_VERSION_PATCH   "2")
set(PointOfSale_VERSION "${PointOfSale_VERSION_MAJOR}.${PointOfSale_VERSION_MINOR}.${PointOfSale_VERSION_PATCH}")
find_package(Git)
determine_version(${PointOfSale_SOURCE_DIR} ${GIT_EXECUTABLE} "PointOfSale")

if(APPLE)
  set(MACOSX_BUNDLE_NAME "PointOfSale")
  set(prefix "${MACOSX_BUNDLE_NAME}.app/Contents")
  set(INSTALL_INCLUDE_DIR "${prefix}/${INSTALL_INCLUDE_DIR}")
  set(INSTALL_RUNTIME_DIR "${prefix}/MacOS")
  set(INSTALL_LIBRARY_DIR "${prefix}/${INSTALL_LIBRARY_DIR}")
  set(INSTALL_ARCHIVE_DIR "${prefix}/${INSTALL_ARCHIVE_DIR}")
  set(INSTALL_DATA_DIR    "${prefix}/${INSTALL_DATA_DIR}")
  set(INSTALL_DOC_DIR     "${prefix}/${INSTALL_DOC_DIR}")
  set(INSTALL_CMAKE_DIR   "${prefix}/Resources")
  set(MACOSX_BUNDLE_INFO_PLIST "MacOSXBundleInfo.plist.in")
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_subdirectory(pointofsale)

install(
  FILES
    README.md
    CONTRIBUTING.md
    COPYING
  DESTINATION "${INSTALL_DOC_DIR}/pointofsale")
