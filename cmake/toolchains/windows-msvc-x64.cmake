include(${CMAKE_CURRENT_LIST_DIR}/../../vcpkg/scripts/buildsystems/vcpkg.cmake)

# set(CMAKE_SYSTEM_NAME Windows CACHE STRING "System name is Windows")
# set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "System processor is x86_64")

set(CMAKE_AR lib.exe CACHE FILEPATH "MSVC AR")

set(CMAKE_C_COMPILER_LAUNCHER ccache.exe CACHE FILEPATH "Enable ccache")
set(CMAKE_CXX_COMPILER_LAUNCHER ccache.exe CACHE FILEPATH "Enable ccache")
set(CMAKE_CUDA_COMPILER_LAUNCHER ccache.exe CACHE FILEPATH "Enable ccache")

set(CMAKE_C_COMPILER cl.exe CACHE FILEPATH "MSVC C compiler")
set(CMAKE_CXX_COMPILER cl.exe CACHE FILEPATH "MSVC C++ compiler")
set(CMAKE_CUDA_COMPILER nvcc.exe CACHE FILEPATH "NVIDIA CUDA compiler")
set(CMAKE_CUDA_HOST_COMPILER cl.exe CACHE FILEPATH "Host compiler used by nvcc")

set(CMAKE_LINKER_TYPE MSVC CACHE STRING "MSVC linker")

set(CMAKE_CUDA_ARCHITECTURES native CACHE STRING "Target GPU architectures")

set(CMAKE_C_FLAGS "/arch:AVX2 /EHsc /utf-8 /GS /guard:cf /wd4244 /wd4267 /wd4834 /permissive- /D_USE_MATH_DEFINES" CACHE STRING "C compiler flags")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C++ compiler flags")
set(CMAKE_CUDA_FLAGS "-Xcompiler=/utf-8" CACHE STRING "CUDA compiler flags")

set(CMAKE_C_FLAGS_DEBUG "/Od" CACHE STRING "C compiler flags for debug builds")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}" CACHE STRING "C++ compiler flags for debug builds")
set(CMAKE_CUDA_FLAGS_DEBUG "-O0 -g" CACHE STRING "CUDA compiler flags for debug builds")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_DEBUG False CACHE BOOL "Interprocedural optimization for debug builds")

set(CMAKE_C_FLAGS_RELEASE "/O2 /DNDEBUG" CACHE STRING "C compiler flags for release builds")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}" CACHE STRING "C++ compiler flags for release builds")
set(CMAKE_CUDA_FLAGS_RELEASE "-O2 -DNDEBUG" CACHE STRING "CUDA compiler flags for release builds")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE True CACHE BOOL "Interprocedural optimization for release builds")

set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O2 /DNDEBUG" CACHE STRING "C compiler flags for release with debug info builds")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}" CACHE STRING "C++ compiler flags for release with debug info builds")
set(CMAKE_CUDA_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG" CACHE STRING "CUDA compiler flags for release with debug info builds")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO True CACHE BOOL "Interprocedural optimization for release with debug info builds")

set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /DNDEBUG" CACHE STRING "C compiler flags for minimum size release builds")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}" CACHE STRING "C++ compiler flags for minimum size release builds")
set(CMAKE_CUDA_FLAGS_MINSIZEREL "-O1 -DNDEBUG" CACHE STRING "CUDA compiler flags for minimum size release builds")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_MINSIZEREL True CACHE BOOL "Interprocedural optimization for minimum size release builds")

set(CMAKE_MSVC_RUNTIME_LIBRARY
  "$<IF:$<BOOL:${BUILD_SHARED_LIBS}>,$<IF:$<CONFIG:Debug>,MultiThreadedDebugDLL,MultiThreadedDLL>,$<IF:$<CONFIG:Debug>,MultiThreadedDebug,MultiThreaded>>"
  CACHE STRING "MSVC runtime library selection"
)

set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT
  "$<$<CONFIG:Debug>:ProgramDatabase>$<$<CONFIG:RelWithDebInfo>:ProgramDatabase>"
  CACHE STRING "MSVC debug information format"
)
