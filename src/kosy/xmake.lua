includes("utils/xmake.lua")

target("polynomial")
    set_kind("headeronly")
    add_headerfiles("polynomial.hpp")
    add_packages("openmp", {public = true})
    add_deps("utils_aligned_allocator", "utils_concepts")
target_end()

target("vecadd")
    set_kind("$(kind)")
    set_policy("build.cuda.devlink", true)
    add_rules("cuda")
    add_cugencodes("native")
    add_files("vecadd.cu")
    add_headerfiles("vecadd.cuh")
    add_cuflags("-std=c++23", {force = true})
    add_packages("cuda", {public = true})
target_end()

target("matmul")
    set_kind("$(kind)")
    set_policy("build.cuda.devlink", true)
    add_rules("cuda")
    add_cugencodes("native")
    add_files("matmul.cu")
    add_headerfiles("matmul.cuh")
    add_cuflags("-std=c++23", {force = true})
    add_packages("cuda", {public = true})
target_end()

target("_core")
    set_kind("shared")
    set_prefixname("")
    set_targetdir(os.scriptdir())
    set_version("0.1.0", {soname = false})
    add_files("_core.cpp", "polynomial_nb.cpp")
    add_deps("nanobind", "polynomial")
    add_packages("openmp")
    add_rules("python.module")
    on_load(function (target)
        local pythondir = get_config("pythondir") or "install"
        target:add(
            "installfiles",
            path.join(os.scriptdir(), "__init__.py"),
            path.join(os.scriptdir(), "polynomial.py"),
            path.join(os.scriptdir(), "_core.pyi"),
            path.join(os.scriptdir(), "py.typed"),
            {prefixdir = path.join(pythondir, "kosy")}
        )
    end)
    on_config(function (target)
        if not target:has_tool("cxx", "cl") then
            target:add("cxflags", "-fno-sanitize=address,undefined", {force = true})
            target:add("shflags", "-fno-sanitize=address,undefined", {force = true})
        end

        -- Python C API symbols (PyDict_SetItem, PyErr_Clear, ...) are resolved
        -- at load time by the embedding python interpreter, not at link time.
        -- Mach-O linking rejects undefined symbols by default, unlike ELF.
        if target:is_plat("macosx") then
            target:add("shflags", "-Wl,-undefined,dynamic_lookup", {force = true})
        end
    end)
    after_build(function (target)
        local python = target:data("python.venv_program")
        local targetdir = target:targetdir()
        os.vrunv(python, {
            "-m", "nanobind.stubgen",
            "-i", targetdir,
            "-m", "_core",
            "-O", targetdir,
            "-M", path.join(targetdir, "py.typed"),
        })
    end)
target_end()
