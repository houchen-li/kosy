/**
 * @file vecadd.cuh
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief CUDA elementwise integer vector addition; smoke test for CUDA support in kosy_cxx_library.
 * @version 0.1
 * @date 2026-07-19
 *
 * @copyright Copyright (c) 2026 Kosy Development Team
 *            All rights reserved.
 *
 */

#pragma once

#include <cstddef>

namespace kosy {

/// Computes @p c[i] = @p a[i] + @p b[i] for @p i in [0, @p n) on the GPU.
///
/// Returns false (leaving @p c unmodified) when no CUDA-capable device is
/// available or the launch or copy did not succeed, so callers can degrade
/// gracefully. Build and link wiring is validated regardless of the return value.
template <typename T>
auto vecadd(const T* a, const T* b, T* c, std::size_t n) -> void;

} // namespace kosy
