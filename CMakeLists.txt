cmake_minimum_required(VERSION 3.31)

project(kosy
  VERSION
    0.1.0
  DESCRIPTION
    "A Collection of Interesting Math Problems for Interview Preparation."
  HOMEPAGE_URL
    https://github.com/houchen-li/kosy
  LANGUAGES
    C
    CXX
)
set(KOSY_SOVERSION 0 CACHE INTERNAL "kosy shared library version")

set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_COMPILE_WARNING_AS_ERROR ON)

option(CMAKE_UNITY_BUILD "Enable unity build" OFF)
option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)
option(KOSY_BUILD_TESTING "Enable testing" ON)
option(KOSY_ENABLE_INSTALL "Enable install" ON)
option(KOSY_USE_CUDA "Enable CUDA targets" ON)

# There is no CUDA toolkit for macOS: force the CUDA targets off there.
if(APPLE AND KOSY_USE_CUDA)
  message(STATUS "KOSY_USE_CUDA is not supported on Apple platforms, forcing it OFF")
  set(KOSY_USE_CUDA OFF CACHE BOOL "Enable CUDA targets" FORCE)
endif()

if(KOSY_USE_CUDA)
  enable_language(CUDA)
  set(CMAKE_CUDA_STANDARD 23)
  set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

if(NOT PROJECT_IS_TOP_LEVEL)
  set(KOSY_ENABLE_INSTALL OFF)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(CPM_SOURCE_CACHE ${CMAKE_SOURCE_DIR}/third_party CACHE PATH "CPM source cache")

if(KOSY_BUILD_TESTING)
  include(CTest)
  enable_testing()
endif()

include(cmake/utils.cmake)

add_subdirectory(deps)
add_subdirectory(src)
add_subdirectory(tests)

if(KOSY_ENABLE_INSTALL)
  include(cmake/export.cmake)
endif()

if(CMAKE_EXPORT_COMPILE_COMMANDS)
  include(cmake/compile_commands.cmake)
endif()
