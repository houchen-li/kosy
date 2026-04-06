/**
 * @file matmul.cu
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief CUDA implementation of kosy::matmul.
 * @version 0.1
 * @date 2026-08-05
 *
 * @copyright Copyright (c) 2026 Kosy Development Team.
 *            All rights reserved.
 *
 */

#include "kosy/matmul.cuh"

#include <cstdint>
#include <stdexcept>

#include <cuda_runtime.h>
#include <thrust/device_ptr.h>
#include <thrust/device_vector.h>

namespace kosy {

namespace {

constexpr int kTileDim{16};

template <typename T>
__global__ auto matmulKernel(
    const T* A, const T* B, T* C, std::size_t nrows, std::size_t inner_size, std::size_t ncols
) -> void {
    __shared__ T tile_a[kTileDim][kTileDim];
    __shared__ T tile_b[kTileDim][kTileDim];

    const int row{static_cast<int>(blockIdx.y * kTileDim + threadIdx.y)};
    const int col{static_cast<int>(blockIdx.x * kTileDim + threadIdx.x)};
    const int nrows_int{static_cast<int>(nrows)};
    const int inner_size_int{static_cast<int>(inner_size)};
    const int ncols_int{static_cast<int>(ncols)};

    T acc{0};

    const int num_tiles{(inner_size_int + kTileDim - 1) / kTileDim};
    for (int t = 0; t < num_tiles; ++t) {
        const int a_col{t * kTileDim + static_cast<int>(threadIdx.x)};
        const int b_row{t * kTileDim + static_cast<int>(threadIdx.y)};

        tile_a[threadIdx.y][threadIdx.x] =
            (row < nrows_int && a_col < inner_size_int)
                ? A[static_cast<std::size_t>(row) * inner_size + static_cast<std::size_t>(a_col)]
                : T{0};
        tile_b[threadIdx.y][threadIdx.x] =
            (b_row < inner_size_int && col < ncols_int)
                ? B[static_cast<std::size_t>(b_row) * ncols + static_cast<std::size_t>(col)]
                : T{0};

        __syncthreads();

        for (int k = 0; k < kTileDim; ++k) {
            acc += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }

        __syncthreads();
    }

    if (row < nrows_int && col < ncols_int) {
        C[static_cast<std::size_t>(row) * ncols + static_cast<std::size_t>(col)] = acc;
    }
}

} // namespace

template <typename T>
auto matmul(
    const T* A, const T* B, T* C, std::size_t nrows, std::size_t inner_size, std::size_t ncols
) -> void {
    int device_count{0};
    if (cudaGetDeviceCount(&device_count) != cudaSuccess || device_count == 0) {
        throw std::runtime_error("No CUDA device presents on host machine!");
    }

    thrust::device_vector<T> d_a(nrows * inner_size), d_b(inner_size * ncols), d_c(nrows * ncols);

    thrust::copy_n(A, nrows * inner_size, d_a.begin());
    thrust::copy_n(B, inner_size * ncols, d_b.begin());

    const dim3 block(kTileDim, kTileDim);
    const dim3 grid(
        static_cast<unsigned int>((ncols + kTileDim - 1) / kTileDim),
        static_cast<unsigned int>((nrows + kTileDim - 1) / kTileDim)
    );
    matmulKernel<<<grid, block>>>(
        thrust::raw_pointer_cast(d_a.data()), thrust::raw_pointer_cast(d_b.data()),
        thrust::raw_pointer_cast(d_c.data()), nrows, inner_size, ncols
    );

    thrust::copy_n(d_c.cbegin(), nrows * ncols, C);

    return;
}

template auto matmul(
    const std::uint8_t* A, const std::uint8_t* B, std::uint8_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::int8_t* A, const std::int8_t* B, std::int8_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::uint16_t* A, const std::uint16_t* B, std::uint16_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::int16_t* A, const std::int16_t* B, std::int16_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::uint32_t* A, const std::uint32_t* B, std::uint32_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::int32_t* A, const std::int32_t* B, std::int32_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::uint64_t* A, const std::uint64_t* B, std::uint64_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const std::int64_t* A, const std::int64_t* B, std::int64_t* C, std::size_t nrows,
    std::size_t inner_size, std::size_t ncols
) -> void;

template auto matmul(
    const float* A, const float* B, float* C, std::size_t nrows, std::size_t inner_size,
    std::size_t ncols
) -> void;

template auto matmul(
    const double* A, const double* B, double* C, std::size_t nrows, std::size_t inner_size,
    std::size_t ncols
) -> void;

} // namespace kosy
