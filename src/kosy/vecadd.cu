/**
 * @file vecadd.cu
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief CUDA implementation of kosy::vecAdd.
 * @version 0.1
 * @date 2026-07-19
 *
 * @copyright Copyright (c) 2026 Kosy Development Team
 *            All rights reserved.
 *
 */

#include "kosy/vecadd.cuh"

#include <stdexcept>

#include <cuda_runtime.h>
#include <thrust/device_ptr.h>
#include <thrust/device_vector.h>

namespace kosy {

namespace {

constexpr int kBlockThreads{256};

template <typename T>
__global__ auto vecaddKernel(const T* a, const T* b, T* c, int n) -> void {
    const int index = static_cast<int>(blockIdx.x * blockDim.x + threadIdx.x);
    if (index < n) {
        c[index] = a[index] + b[index];
    }
}

} // namespace

template <typename T>
auto vecadd(const T* a, const T* b, T* c, std::size_t n) -> void {
    int device_count{0};
    if (cudaGetDeviceCount(&device_count) != cudaSuccess || device_count == 0) {
        throw std::runtime_error("No CUDA device presents on host machine!");
    }

    thrust::device_vector<T> d_a(n), d_b(n), d_c(n);

    thrust::copy_n(a, n, d_a.begin());
    thrust::copy_n(b, n, d_b.begin());

    const int n_int{static_cast<int>(n)};
    const int blocks{(n_int + kBlockThreads - 1) / kBlockThreads};
    vecaddKernel<<<blocks, kBlockThreads>>>(
        thrust::raw_pointer_cast(d_a.data()), thrust::raw_pointer_cast(d_b.data()),
        thrust::raw_pointer_cast(d_c.data()), n_int
    );

    thrust::copy_n(d_c.cbegin(), n, c);

    return;
}

template auto vecadd(const std::uint8_t* a, const std::uint8_t* b, std::uint8_t* c, std::size_t n)
    -> void;

template auto vecadd(const std::int8_t* a, const std::int8_t* b, std::int8_t* c, std::size_t n)
    -> void;

template auto vecadd(
    const std::uint16_t* a, const std::uint16_t* b, std::uint16_t* c, std::size_t n
) -> void;

template auto vecadd(const std::int16_t* a, const std::int16_t* b, std::int16_t* c, std::size_t n)
    -> void;

template auto vecadd(
    const std::uint32_t* a, const std::uint32_t* b, std::uint32_t* c, std::size_t n
) -> void;

template auto vecadd(const std::int32_t* a, const std::int32_t* b, std::int32_t* c, std::size_t n)
    -> void;

template auto vecadd(
    const std::uint64_t* a, const std::uint64_t* b, std::uint64_t* c, std::size_t n
) -> void;

template auto vecadd(const std::int64_t* a, const std::int64_t* b, std::int64_t* c, std::size_t n)
    -> void;

template auto vecadd(const float* a, const float* b, float* c, std::size_t n) -> void;

template auto vecadd(const double* a, const double* b, double* c, std::size_t n) -> void;

} // namespace kosy
