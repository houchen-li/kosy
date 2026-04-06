/**
 * @file test_matmul.cpp
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief doctest unit tests for kosy::matmul.
 * @version 0.1
 * @date 2026-08-05
 *
 * @copyright Copyright (c) 2026 Kosy Development Team
 *            All rights reserved.
 *
 */

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest/doctest.h"

#include <cstddef>
#include <cstdint>
#include <random>
#include <vector>

#include "kosy/matmul.cuh"
#include "kosy/utils/aligned_memory_resource.hpp"

namespace {

template <typename RNG, typename T>
auto randomFill(RNG&& rng, T* data, std::size_t n) -> void {
    if constexpr (std::is_integral_v<T>) {
        std::uniform_int_distribution<T> uniform_dist(0, 2);
        for (std::size_t i = 0; i < n; ++i) {
            data[i] = uniform_dist(std::forward<RNG>(rng));
        }
    } else {
        std::uniform_real_distribution<T> uniform_dist(0.0, 2.0);
        for (std::size_t i = 0; i < n; ++i) {
            data[i] = uniform_dist(std::forward<RNG>(rng));
        }
    }
    return;
}

template <typename T>
auto matmulCpu(
    const T* A, const T* B, T* C, std::size_t nrows, std::size_t inner_size, std::size_t ncols
) -> void {
    for (std::size_t i{0}; i < nrows; ++i) {
        for (std::size_t j{0}; j < ncols; ++j) {
            T acc{0};
            for (std::size_t k{0}; k < inner_size; ++k) {
                acc += A[i * inner_size + k] * B[k * ncols + j];
            }
            C[i * ncols + j] = acc;
        }
    }
    return;
}

} // namespace

TEST_CASE_TEMPLATE(
    "kosy::matmul multiplies row-major matrices on the GPU", T, std::uint8_t, std::int8_t,
    std::uint16_t, std::int16_t, std::uint32_t, std::int32_t, std::uint64_t, std::int64_t, float,
    double
) {
    // Deliberately non-square and not multiples of the kernel's tile size, to
    // exercise both the boundary handling in the tiled kernel and that the
    // three dimension parameters are not confused with one another.
    constexpr std::size_t nrows{17};
    constexpr std::size_t inner_size{23};
    constexpr std::size_t ncols{13};

    std::pmr::vector<T> a(nrows * inner_size, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> b(inner_size * ncols, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> c(nrows * ncols, T{0}, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> c_ref(nrows * ncols, T{0}, kosy::pmr::getAlignedMemoryResource());

    std::random_device r;
    std::mt19937 rng(r());
    randomFill(rng, a.data(), a.size());
    randomFill(rng, b.data(), b.size());

    kosy::matmul(a.data(), b.data(), c.data(), nrows, inner_size, ncols);
    matmulCpu(a.data(), b.data(), c_ref.data(), nrows, inner_size, ncols);

    CHECK_EQ(c.size(), nrows * ncols);
    for (std::size_t i{0}; i < c.size(); ++i) {
        if constexpr (std::is_floating_point_v<T>) {
            // GPU tiled accumulation and the CPU triple loop sum products in
            // different orders, so results can differ by rounding error.
            CHECK(c[i] == doctest::Approx(c_ref[i]));
        } else {
            CHECK_EQ(c[i], c_ref[i]);
        }
    }
}
