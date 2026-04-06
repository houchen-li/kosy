---
paths:
  - "**/*.cu"
  - "**/*.cuh"
  - "**/CMakeLists.txt"
  - "**/xmake.lua"
  - "cmake/**"
  - "xmake/**"
  - "deps/**"
---

# CUDA

CUDA is **optional**: `KOSY_USE_CUDA` (CMake) / `kosy_use_cuda` (xmake) defaults to on, is forced off on macOS (no toolkit), and CI always builds with it off (GitHub-hosted runners have no GPU).

## Targets and dependencies

- Declare `.cu` libraries and their tests inside `if(KOSY_USE_CUDA)` (CMake) and `if is_config("kosy_use_cuda", true) then` (xmake). CPU-only code, including `_core`, must never depend on a CUDA target unconditionally.
- CUDA-only dependency features follow the same option instead of being hard-coded: `find_package(CUDAToolkit)`, `STDEXEC_ENABLE_CUDA`, `TF_BUILD_CUDA`, the stdexec xrepo `cuda` config, and `find_dependency(CUDAToolkit)` in `cmake/Config.cmake.in`.
- CMake enables the language only when the option is on (`enable_language(CUDA)`, `CMAKE_CUDA_STANDARD 23`); never list `CUDA` in `project(LANGUAGES ...)`.

## Toolchains

- nvcc flags live next to the host flags in `cmake/toolchains/*.cmake` (`CMAKE_CUDA_FLAGS*`) and `xmake/toolchains/*.lua` (`cuflags`). Host flags go through a single `-Xcompiler=` list that mirrors the C++ flags.
- `CMAKE_CUDA_ARCHITECTURES` / `add_cugencodes` default to `native`, so a configure with CUDA on needs a visible GPU.
- The Clang presets stay on **libstdc++** (basjoo uses libc++): nvcc's libc++ support is limited and `.cu`/`.cpp` objects must share one standard library.
- Host compiler versions are capped by nvcc support (devcontainer: CUDA 13.3 with GCC 15 / Clang 21). Check NVIDIA's supported host compiler list before bumping the compilers.

## Sanitizers

ASan's shadow-memory reservation collides with the CUDA driver's mappings (`cudaGetDeviceCount()` reports 0 devices). `kosy_cxx_test` (via `ENVIRONMENT_MODIFICATION`) and the `kosy.cxx.test` xmake rule (via `add_runenvs`) prepend `protect_shadow_gap=0` to `ASAN_OPTIONS` on every non-Windows test, keeping any options already set.

## Running

GPU tests (`test_vecadd`, `test_matmul`) need a CUDA device: the devcontainer runs with `--gpus=all`. Without one, configure with `-DKOSY_USE_CUDA=OFF` / `--kosy_use_cuda=n`.
