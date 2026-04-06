package("matplotplusplus")
    set_homepage("https://alandefreitas.github.io/matplotplusplus/")
    set_description("A C++ Graphics Library for Data Visualization")
    set_license("MIT")

    add_urls("https://github.com/alandefreitas/matplotplusplus/archive/refs/tags/v$(version).tar.gz")
    add_versions("1.2.2", "c7434b4fea0d0cc3508fd7104fafbb2fa7c824b1d2ccc51c52eaee26fc55a9a0")

    add_deps("cmake")
    add_deps("ninja")

    add_configs("shared", {description = "Build Matplot++ as a shared library.", default = false, type = "boolean"})

    set_policy("package.cmake_generator.ninja", true)

    add_links("matplot")
    on_load(function (package)
        if not package:config("shared") then
            package:add("links", "nodesoup")
        end
    end)

    add_patches("1.2.2", os.scriptdir() .. "/disable_warning_as_error.patch", "2d76d0279c9a83c89dcf716ce131583fda3802c8c7aeab87187f41fd4489b862")
    add_patches("1.2.2", os.scriptdir() .. "/deprecate_is_trivial.patch", "9042aebed0b6f1fe37d87f3c8c3895b3d9d180ec2ad09dba307190e46739e47a")
    add_patches("1.2.2", os.scriptdir() .. "/lapack_fallback_to_blas.patch", "5574221acbf7b17268d8987df3cc7b347604433333f666a0d303d2ea354cc7ec")

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DCMAKE_CXX_STANDARD=23",
            "-DCMAKE_COMPILE_WARNING_AS_ERROR=OFF",
            "-DMATPLOTPP_BUILD_TESTS=OFF",
            "-DMATPLOTPP_BUILD_EXAMPLES=OFF",
            "-DMATPLOTPP_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
        })
        local nodesoup_lib = path.join(package:installdir("lib"), "Matplot++", is_plat("windows") and "nodesoup.lib" or "libnodesoup.a")
        if os.isfile(nodesoup_lib) then
            os.cp(nodesoup_lib, package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("matplot/matplot.h", {configs = {languages = "c++17"}}))
    end)
package_end()

add_requires("matplotplusplus 1.2.2")
