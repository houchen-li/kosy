# Python Conventions

## Style

- **PEP 8** baseline; **ruff** is authoritative for formatting and many lint rules (`pyproject.toml`)
- **pyright** for static typing
- **Type hints** on all public functions and methods

## Types

- Annotate public APIs; use `|` for unions, generics from `collections.abc` or builtins

## Imports

Standard library → third party → local, blank line between groups.

## Modules

- `src/kosy/` holds both the C++/CUDA headers and the Python package: `__init__.py`, pure-Python modules (e.g. `polynomial.py`), and the nanobind `_core` extension (`_core.cpp`, `polynomial_nb.cpp` + generated `_core.pyi`/`py.typed`). `xmake-python`'s wheel builder only recognizes `<name>/` or `src/<name>/` package layouts, which is why C++/CUDA and Python live in the same directory rather than split.
- Avoid empty `__init__.py` unless packaging requires it; prefer explicit imports.

## Build backend

- **Default**: `pyproject.toml` uses **scikit-build-core** driving the CMake presets (`cmake.args = ["--preset=..."]` per platform in `[[tool.scikit-build.overrides]]`).
- **Alternate**: `pyproject.xmake.toml` configures the same package via the **xmake-python** PEP 517 backend instead. Swap it in with `cp pyproject.xmake.toml pyproject.toml && uv sync`; the shared `[project]`/`[tool.ruff]`/`[tool.pyright]`/etc. sections are kept in sync by hand between the two files.
- xmake toolchain selection lives in `xmake.lua` itself (`is_host(...)` branches per platform, overridable with `xmake f --toolchain=...`), not in `pyproject.xmake.toml`.
- **Known limitation**: xmake-python's packaging step always runs a bare `xmake` build (no way to scope it to just the `_core` target), so it also builds every other default-enabled C++/CUDA target in the project (`polynomial`, `vecadd`, `matmul`, `utils_*`). This is unrelated to the Python bindings but means the xmake-python path only succeeds on a toolchain that can build the whole project, including a working CUDA toolkit.

## Sanitizers (Debug / RelWithDebInfo / releasedbg)

- On Linux (GCC/Clang), `_core` and its bundled `nanobind`/`nanobind-static` object files are always compiled with an explicit `-fno-sanitize=address,undefined` (CMake `target_compile_options`/`target_link_options`, guarded by `$<NOT:$<CXX_COMPILER_ID:MSVC>>`; xmake `add_cxflags`/`add_shflags` inside `on_config`, guarded by `not target:has_tool("cxx", "cl")`, both with `{force = true}`), overriding whatever `-fsanitize=` the active Debug/RelWithDebInfo/releasedbg toolchain flags would otherwise apply project-wide. `_core` therefore never needs a sanitizer runtime preloaded, and `uv run pytest` / `import _core` work the same way in every build type with no extra setup. Everything else (doctest C++ test binaries, `polynomial`/`vecadd`/`matmul`) still gets ASan/UBSan normally — only the Python extension module is exempted.
- **Windows/MSVC has no ASan/UBSan coverage at all, by design**, in any build type — the toolchain files never set `/fsanitize=address`. This is a deliberate project decision (not just a `_core` exemption): MSVC's sanitizer support was never actually validated against a real Windows environment in this project's history and was a persistent source of friction (nanobind skips its preload logic entirely on Windows; the DLL/PATH story differs fundamentally from Linux's `LD_PRELOAD`), so the `-fno-sanitize=` guards above exist only to keep `_core`'s CMakeLists.txt/xmake.lua from passing GCC/Clang-only flag syntax to `cl.exe` should MSVC ever gain sanitizer flags again — they're not currently exempting anything, since there's nothing enabled to exempt from.
- CUDA-linked C++ tests (`test_vecadd`, `test_matmul`) additionally need `ASAN_OPTIONS=protect_shadow_gap=0` on Linux — AddressSanitizer's shadow-memory reservation otherwise conflicts with the CUDA driver's own memory mapping and `cudaGetDeviceCount()` reports 0 devices. `kosy_cxx_test` (CMake) and the `kosy.cxx.test` rule (xmake) set this on every test target; it's a no-op for tests that don't touch CUDA.

## Tests

- **pytest** with descriptive `test_*` names
- **Arrange / Act / Assert** structure
- **`@pytest.fixture`** for reusable setup
- **`@pytest.mark.parametrize`** for data-driven cases
- Run via `uv run pytest`

## Adding dependencies

```bash
uv add package_name
uv lock
```

## Tools

```bash
uv run ruff check .
uv run ruff format .
uv run pyright
uv run pytest
```
