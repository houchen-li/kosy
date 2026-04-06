add_requires("cmake", {system = true})
add_requires("ninja", {system = true})
add_requires("openmp", {system = true})
add_requires("cuda", {system = true})

if is_plat("linux") then
    add_syslinks("pthread")
end

includes("python/xmake.lua")
includes("nanobind/xmake.lua")

includes("cxxopts/xmake.lua")
includes("doctest/xmake.lua")
includes("matplotplusplus/xmake.lua")
includes("msft_proxy4/xmake.lua")

includes("spdlog/xmake.lua")
includes("zpp_bits/xmake.lua")

includes("boost/xmake.lua")
includes("taskflow/xmake.lua")
includes("stdexec/xmake.lua")
