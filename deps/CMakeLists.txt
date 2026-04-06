find_package(Threads REQUIRED MODULE GLOBAL)
find_package(OpenMP REQUIRED MODULE GLOBAL)
find_package(CUDAToolkit REQUIRED GLOBAL)

include(python/CMakeLists.txt)
include(nanobind/CMakeLists.txt)

add_subdirectory(cpm)

add_subdirectory(cxxopts)
add_subdirectory(doctest)
add_subdirectory(matplotplusplus)
add_subdirectory(msft_proxy4)
add_subdirectory(spdlog)
add_subdirectory(zpp_bits)

add_subdirectory(boost)
add_subdirectory(taskflow)
add_subdirectory(stdexec)
