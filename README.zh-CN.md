<h1 align="center">Kosy</h1>

<p align="center">
  <b>一组适合面试准备的有趣数学问题。</b>
</p>

<p align="center">
  <a href="README.md">English</a> | 简体中文
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

Kosy 用三种方式探索经典的数学与高性能计算问题：现代 **C++23** 实现、可选的 **CUDA** 内核，以及用于探索和可视化的 **Python**，并通过 [nanobind](https://github.com/wjakob/nanobind) 将 C++ 暴露给 Python。

## 内容

| 组件                                 | 语言         | 说明                                                       |
| ------------------------------------ | ------------ | ---------------------------------------------------------- |
| `kosy.Polynomial` / `polynomial.hpp` | C++ → Python | 实数与复数系数多项式的求值、求导及向量化 Newton–Raphson 迭代 |
| `vecadd`、`matmul`                   | CUDA         | 向量加法与矩阵乘法内核（需开启 `KOSY_USE_CUDA`）            |
| `kosy/utils`                         | C++          | spdlog 日志、对齐分配器与 PMR 内存资源、计时工具、类型萃取与概念 |
| `tests/kosy/julia_set.py`            | Python       | 复平面上 z³ − 1 的 Newton 分形，使用 Matplotlib 绘制        |

## 快速开始

最省事的环境是 devcontainer（`.devcontainer/`：GCC 15、Clang 21、CUDA 13.3、CMake、xmake、uv；以 `--gpus=all` 启动）。在本机构建需要 CMake ≥ 3.31、Ninja、C++23 编译器（CI 覆盖 GCC、Clang 与 MSVC）、Python ≥ 3.14 与 [uv](https://docs.astral.sh/uv/)，CUDA Toolkit 13.x 与 ccache 可选。所有 C++ 依赖均由 [CPM](https://github.com/cpm-cmake/CPM.cmake) 自动获取。

```bash
git clone --recursive https://github.com/houchen-li/kosy.git && cd kosy

# 先准备 Python 环境：CMake/xmake 需要从 .venv 中找到 nanobind
uv venv --system-site-packages
uv sync --no-install-project

# 使用预设构建与测试（linux-gcc-x64、linux-clang-x64、darwin-{gcc,clang}-arm64、windows-msvc-x64）
cmake --preset linux-gcc-x64            # 没有 CUDA 工具链或 GPU 时加上 -DKOSY_USE_CUDA=OFF
cmake --build --preset linux-gcc-x64
ctest --preset linux-gcc-x64
uv run pytest

# ……或使用 xmake
xmake f -m release && xmake build && xmake test
```

### 构建选项

| CMake                 | xmake                 | 默认值 | 说明                              |
| --------------------- | --------------------- | ------ | --------------------------------- |
| `KOSY_BUILD_TESTING`  | `kosy_build_testing`  | `ON`   | 构建单元测试                      |
| `KOSY_USE_CUDA`       | `kosy_use_cuda`       | `ON`   | 构建 CUDA 目标；macOS 上始终关闭  |
| `KOSY_ENABLE_INSTALL` | `kosy_enable_install` | `ON`   | 安装与导出规则                    |
| `BUILD_SHARED_LIBS`   | `--kind=shared`       | `OFF`  | 构建动态库                        |

## 示例

```python
import numpy as np

from kosy import Polynomial

# f(z) = z³ − 1：一次求出全部三个单位立方根
f = Polynomial[np.complex128]([-1 + 0j, 0j, 0j, 1 + 0j])
z0s = np.array([0.9 + 0.05j, -0.4 + 0.9j, -0.4 - 0.9j], dtype=np.complex128)
roots, _, iters = f.newton_raphson(z0s, abs_tol=1e-12, rel_tol=1e-12, max_iter=400)
# roots ≈ [1, -0.5 + 0.866j, -0.5 - 0.866j]

p = Polynomial(np.array([2.0, 3.0, 4.0]))  # 2 + 3z + 4z²，自动推断 dtype
p(np.array([0.0, 1.0, 2.0]))                # array([ 2.,  9., 24.])
```

运行 `uv run python tests/kosy/julia_set.py` 可绘制 Newton 分形。

## 参与贡献

面向开发者与编码代理的约定见 [`AGENTS.md`](AGENTS.md) 与 [`.claude/rules/`](.claude/rules)。每次改动都需同步 CMake 与 xmake、补充测试，并使用 `clang-format` / `ruff format` 格式化。

## 许可证

[MIT](LICENSE)。

Kosy 构建于
[Boost](https://www.boost.org/)、
[cxxopts](https://github.com/jarro2783/cxxopts)、
[doctest](https://github.com/doctest/doctest)、
[Matplot++](https://github.com/alandefreitas/matplotplusplus)、
[Microsoft Proxy](https://github.com/microsoft/proxy)、
[nanobind](https://github.com/wjakob/nanobind)、
[spdlog](https://github.com/gabime/spdlog)、
[stdexec](https://github.com/NVIDIA/stdexec)、
[Taskflow](https://github.com/taskflow/taskflow)、
[zpp_bits](https://github.com/eyalz800/zpp_bits)、
[NumPy](https://numpy.org/) 与
[Matplotlib](https://matplotlib.org/) 之上，感谢这些项目的作者。
