/**
 * @file test_vecadd.cpp
 * @author Houchen Li (houchen_li@hotmail.com)
 * @brief doctest unit tests for kosy::vecadd.
 * @version 0.1
 * @date 2026-07-19
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

#include "kosy/utils/aligned_memory_resource.hpp"
#include "kosy/vecadd.cuh"

namespace {

template <typename RNG, typename T>
auto randomFill(RNG&& rng, T* data, std::size_t n) -> void {
    if constexpr (std::is_integral_v<T>) {
        std::uniform_int_distribution<T> uniform_dist(0, 64);
        for (std::size_t i = 0; i < n; ++i) {
            data[i] = uniform_dist(std::forward<RNG>(rng));
        }
    } else {
        std::uniform_real_distribution<T> uniform_dist(0.0, 64.0);
        for (std::size_t i = 0; i < n; ++i) {
            data[i] = uniform_dist(std::forward<RNG>(rng));
        }
    }
    return;
}

template <typename T>
auto vecAddCpu(const T* a, const T* b, T* c, std::size_t n) -> void {
    for (std::size_t i{0}; i < n; ++i) {
        c[i] = a[i] + b[i];
    }
    return;
}

} // namespace

TEST_CASE_TEMPLATE(
    "kosy::vecAdd adds elementwise on the GPU", T, std::uint8_t, std::int8_t, std::uint16_t,
    std::int16_t, std::uint32_t, std::int32_t, std::uint64_t, std::int64_t, float, double
) {
    constexpr std::size_t n{256};

    std::pmr::vector<T> a(n, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> b(n, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> c(n, T{0}, kosy::pmr::getAlignedMemoryResource());
    std::pmr::vector<T> c_ref(n, T{0}, kosy::pmr::getAlignedMemoryResource());

    std::random_device r;
    std::mt19937 rng(r());
    randomFill(rng, a.data(), n);
    randomFill(rng, b.data(), n);

    kosy::vecadd(a.data(), b.data(), c.data(), c.size());
    vecAddCpu(a.data(), b.data(), c_ref.data(), c_ref.size());

    CHECK_EQ(c.size(), n);
    for (std::size_t i{0}; i < n; ++i) {
        CHECK_EQ(c[i], c_ref[i]);
    }
}
