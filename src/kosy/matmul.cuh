/**
 * @file matmul.cuh
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief CUDA tiled shared-memory matrix multiplication.
 * @version 0.1
 * @date 2026-08-05
 *
 * @copyright Copyright (c) 2026 Kosy Development Team.
 *            All rights reserved.
 *
 */

#pragma once

#include <cstddef>

namespace kosy {

/// Computes @p C = @p A * @p B on the GPU, where @p A is a row-major
/// @p nrows x @p inner_size matrix, @p B is a row-major @p inner_size x
/// @p ncols matrix, and @p C is a row-major @p nrows x @p ncols matrix.
///
/// Throws std::runtime_error when no CUDA-capable device is available.
template <typename T>
auto matmul(
    const T* A, const T* B, T* C, std::size_t nrows, std::size_t inner_size, std::size_t ncols
) -> void;

} // namespace kosy
