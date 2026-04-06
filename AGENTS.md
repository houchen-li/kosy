# AGENTS.md — kosy

kosy is a **C++23 / CUDA / Python** collection of interesting math problems for interview preparation: C++ implementations exposed to Python through **nanobind**, optional CUDA kernels, and Python tooling for exploration and visualization. MIT License.

This file is the single source of truth for coding agents (Claude Code reads it as `CLAUDE.md`; Codex, Cursor, and Copilot read `AGENTS.md`). Detailed conventions live in `.claude/rules/`; Claude Code loads them automatically for matching paths, other agents should **read the matching rule before editing**:

| Rule                       | Read before touching                                    |
| -------------------------- | ------------------------------------------------------- |
| `.claude/rules/cpp.md`     | any C++/CUDA source or header                           |
| `.claude/rules/testing.md` | `tests/`                                                |
| `.claude/rules/build.md`   | CMake, xmake, `deps/`, presets, CI, devcontainer        |
| `.claude/rules/python.md`  | Python, `pyproject*.toml`, `uv.lock`, nanobind bindings |
| `.claude/rules/kosy-cuda.md` | `.cu`/`.cuh` files and any CUDA-related build logic   |

## Layout

```
src/kosy/            C++/CUDA sources + Python package (__init__.py, polynomial.py, nanobind _core)
  utils/            logging (spdlog), aligned allocators/memory resources, type traits, concepts
  polynomial.hpp    polynomial evaluation + Newton–Raphson (bound to Python as kosy.Polynomial)
  vecadd.cu/.cuh    CUDA vector add            (only with KOSY_USE_CUDA)
  matmul.cu/.cuh    CUDA matrix multiplication (only with KOSY_USE_CUDA)
tests/kosy/          doctest + pytest
cmake/ xmake/       toolchains, helpers (kosy_cxx_*), rules
deps/               one CPM + xrepo fragment per third-party package
```

Namespaces: `kosy` for the library, `kosy::bindings` for nanobind glue, `detail` for internals, `pmr` for polymorphic-allocator variants.

## Commands

```bash
uv venv --system-site-packages && uv sync --no-install-project   # first: .venv with nanobind
cmake --preset linux-gcc-x64            # add -DKOSY_USE_CUDA=OFF without a CUDA toolkit
cmake --build --preset linux-gcc-x64
ctest --preset linux-gcc-x64 [-R <regex>]
xmake f -m release && xmake build && xmake test                   # alternative build
uv run pytest
clang-format -i <files>; clang-tidy -p out/build/<preset> <file>
uv run ruff format && uv run ruff check && uv run pyright
```

| CMake option / xmake option                 | Default | Effect                                          |
| ------------------------------------------- | ------- | ----------------------------------------------- |
| `KOSY_BUILD_TESTING` / `kosy_build_testing` | `ON`    | Build and register tests                        |
| `KOSY_USE_CUDA` / `kosy_use_cuda`           | `ON`    | CUDA targets and tests; forced `OFF` on macOS   |
| `KOSY_ENABLE_INSTALL` / `kosy_enable_install` | `ON`  | Install/export rules                            |
| `BUILD_SHARED_LIBS` / `--kind`              | `OFF`   | Shared libraries                                |

The devcontainer (`.devcontainer/`, GCC 15 / Clang 21 / CUDA 13.3, `--gpus=all`) is the reference environment.

## Definition of done

1. Tests added or updated, and `ctest` + `uv run pytest` pass for the affected targets (with CUDA on when CUDA code changed).
2. CMake **and** xmake updated together (targets, `DEPS`, options).
3. Touched files formatted (`clang-format`, `ruff format`) and lint-clean.
4. If commands, options, or layout changed: this file, the matching `.claude/rules/*.md`, and `README.md` / `README.zh-CN.md` updated.

## Project policies

- New C++/CUDA files start with:

  ```cpp
  /**
   * @file path/under/src/kosy/thing.hpp
   * @author Author Name (author@example.com)
   * @brief Short description.
   * @version 0.1
   * @date YYYY-MM-DD
   *
   * @copyright Copyright (c) YYYY Kosy Development Team
   *            All rights reserved.
   *
   */
  ```

  Python files start with `# Copyright (c) YYYY Kosy Development Team. All rights reserved.`
- `TODO(github_username): ...` with a real username (`//` in C++, `#` in Python).
- Dependencies only via CPM/vcpkg (C++) or uv (Python).
- No demos, sample apps, or unrequested documentation files.
- No secrets in code, config, logs, or test output; read them from the environment.

---

# andrej-karpathy-skills

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
