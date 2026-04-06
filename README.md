<h1 align="center">Kosy</h1>

<p align="center">
  <b>A collection of interesting math problems for interview preparation.</b>
</p>

<p align="center">
  English | <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/houchen-li/kosy/actions/workflows/ubuntu-x64.yml"><img src="https://github.com/houchen-li/kosy/actions/workflows/ubuntu-x64.yml/badge.svg" alt="ubuntu-x64"></a>
  <a href="https://github.com/houchen-li/kosy/actions/workflows/darwin-arm64.yml"><img src="https://github.com/houchen-li/kosy/actions/workflows/darwin-arm64.yml/badge.svg" alt="darwin-arm64"></a>
  <a href="https://github.com/houchen-li/kosy/actions/workflows/windows-x64.yml"><img src="https://github.com/houchen-li/kosy/actions/workflows/windows-x64.yml/badge.svg" alt="windows-x64"></a>
  <img src="https://img.shields.io/badge/C%2B%2B-23-blue.svg" alt="C++23">
  <img src="https://img.shields.io/badge/Python-%E2%89%A53.14-3776AB.svg?logo=python&logoColor=white" alt="Python ≥ 3.14">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-yellow.svg" alt="MIT"></a>
</p>

---

Kosy works through classic math and HPC problems three ways: modern **C++23** implementations, optional **CUDA** kernels, and **Python** for exploration and plotting, with [nanobind](https://github.com/wjakob/nanobind) bridging C++ into Python.

## What's inside

| Component                            | Language     | Description                                                                                         |
| ------------------------------------ | ------------ | --------------------------------------------------------------------------------------------------- |
| `kosy.Polynomial` / `polynomial.hpp` | C++ → Python | Polynomial evaluation, derivatives, and vectorized Newton–Raphson for real and complex coefficients |
| `vecadd`, `matmul`                   | CUDA         | Vector addition and matrix multiplication kernels (built with `KOSY_USE_CUDA`)                      |
| `kosy/utils`                         | C++          | spdlog logging, aligned allocators and PMR resources, timing helpers, type traits and concepts      |
| `tests/kosy/julia_set.py`            | Python       | Newton fractal of z³ − 1 on the complex plane, rendered with Matplotlib                             |

## Getting started

The easiest environment is the devcontainer (`.devcontainer/`: GCC 15, Clang 21, CUDA 13.3, CMake, xmake, uv; started with `--gpus=all`). On your own machine you need CMake ≥ 3.31, Ninja, a C++23 compiler (CI covers GCC, Clang, and MSVC), Python ≥ 3.14 with [uv](https://docs.astral.sh/uv/), and optionally the CUDA Toolkit 13.x and ccache. Every C++ dependency is fetched by [CPM](https://github.com/cpm-cmake/CPM.cmake).

```bash
git clone --recursive https://github.com/houchen-li/kosy.git && cd kosy

# Python environment first: CMake/xmake locate nanobind in .venv
uv venv --system-site-packages
uv sync --no-install-project

# Build and test with a preset (linux-gcc-x64, linux-clang-x64, darwin-{gcc,clang}-arm64, windows-msvc-x64)
cmake --preset linux-gcc-x64            # add -DKOSY_USE_CUDA=OFF without a CUDA toolkit or GPU
cmake --build --preset linux-gcc-x64
ctest --preset linux-gcc-x64
uv run pytest

# ...or with xmake
xmake f -m release && xmake build && xmake test
```

### Options

| CMake                 | xmake                 | Default | Description                                   |
| --------------------- | --------------------- | ------- | --------------------------------------------- |
| `KOSY_BUILD_TESTING`  | `kosy_build_testing`  | `ON`    | Build unit tests                              |
| `KOSY_USE_CUDA`       | `kosy_use_cuda`       | `ON`    | Build the CUDA targets; always `OFF` on macOS |
| `KOSY_ENABLE_INSTALL` | `kosy_enable_install` | `ON`    | Install and export rules                      |
| `BUILD_SHARED_LIBS`   | `--kind=shared`       | `OFF`   | Build shared libraries                        |

## Example

```python
import numpy as np

from kosy import Polynomial

# f(z) = z³ − 1: find all three cube roots of unity at once
f = Polynomial[np.complex128]([-1 + 0j, 0j, 0j, 1 + 0j])
z0s = np.array([0.9 + 0.05j, -0.4 + 0.9j, -0.4 - 0.9j], dtype=np.complex128)
roots, _, iters = f.newton_raphson(z0s, abs_tol=1e-12, rel_tol=1e-12, max_iter=400)
# roots ≈ [1, -0.5 + 0.866j, -0.5 - 0.866j]

p = Polynomial(np.array([2.0, 3.0, 4.0]))  # 2 + 3z + 4z², dtype inferred
p(np.array([0.0, 1.0, 2.0]))                # array([ 2.,  9., 24.])
```

Run `uv run python tests/kosy/julia_set.py` to plot the Newton fractal.

## Contributing

Conventions for humans and coding agents are in [`AGENTS.md`](AGENTS.md) and [`.claude/rules/`](.claude/rules). Every change keeps CMake and xmake in sync, adds tests, and is formatted with `clang-format` / `ruff format`.

## License

[MIT](LICENSE).

Kosy builds on
[Boost](https://www.boost.org/),
[cxxopts](https://github.com/jarro2783/cxxopts),
[doctest](https://github.com/doctest/doctest),
[Matplot++](https://github.com/alandefreitas/matplotplusplus),
[Microsoft Proxy](https://github.com/microsoft/proxy),
[nanobind](https://github.com/wjakob/nanobind),
[spdlog](https://github.com/gabime/spdlog),
[stdexec](https://github.com/NVIDIA/stdexec),
[Taskflow](https://github.com/taskflow/taskflow),
[zpp_bits](https://github.com/eyalz800/zpp_bits),
[NumPy](https://numpy.org/), and
[Matplotlib](https://matplotlib.org/) — thank you to their authors.
