toolchain("windows-msvc-x64")
    set_kind("standalone")
    set_homepage("https://visualstudio.microsoft.com/")
    set_description("Windows MSVC x86_64")

    on_check(function (toolchain)
        return is_host("windows") and is_arch("x64")
    end)

    on_load(function (toolchain)
        import("lib.detect.find_tool")

        toolchain:set("toolset", "cc", "cl.exe")
        toolchain:set("toolset", "cxx", "cl.exe")
        toolchain:set("toolset", "ld", "link.exe")
        toolchain:set("toolset", "sh", "link.exe")
        -- This toolset declaration alone wasn't enough for boyle's Windows
        -- xmake CI: xmake still needed `--ar=lib.exe` passed explicitly to
        -- `xmake f` to archive correctly. Untested here since kosy's Windows
        -- CI doesn't run the xmake path yet, but pass the same flag if a
        -- local `xmake f --toolchain=windows-msvc-x64 ...` run hits archiver
        -- errors.
        toolchain:set("toolset", "ar", "lib.exe")
        toolchain:set("toolset", "cu", "nvcc.exe")
        toolchain:set("toolset", "culd", "nvcc.exe")
        toolchain:set("toolset", "cu-ccbin", "cl.exe")

        local ccache = find_tool("ccache")
        if ccache then
            toolchain:set("toolset", "ccache", ccache.program)
        end

        local base_cxflags = {
            "/arch:AVX2", "/EHsc", "/utf-8", "/GS",
            "/guard:cf", "/wd4244", "/wd4267", "/wd4834",
            "/permissive-",
        }

        toolchain:add("cxflags", table.unpack(base_cxflags))
        toolchain:add("defines", "_USE_MATH_DEFINES")
        toolchain:add("cuflags", "-Xcompiler=/utf-8")

        local shared = is_config("kind", "shared")

        if is_mode("debug") then
            toolchain:add("cxflags", "/Od", "/Zi")
            toolchain:add("cuflags", "-O0", "-g")
            toolchain:set("runtimes", shared and "MDd" or "MTd")
        elseif is_mode("release") then
            toolchain:add("cxflags", "/O2", "/DNDEBUG", "/GL")
            toolchain:add("cuflags", "-O2", "-DNDEBUG")
            toolchain:add("ldflags", "/LTCG")
            toolchain:add("shflags", "/LTCG")
            toolchain:set("runtimes", shared and "MD" or "MT")
        elseif is_mode("releasedbg") then
            toolchain:add("cxflags", "/O2", "/DNDEBUG", "/Zi", "/GL")
            toolchain:add("cuflags", "-O2", "-g", "-DNDEBUG")
            toolchain:add("ldflags", "/LTCG")
            toolchain:add("shflags", "/LTCG")
            toolchain:set("runtimes", shared and "MD" or "MT")
        elseif is_mode("minsizerel") then
            toolchain:add("cxflags", "/O1", "/DNDEBUG", "/GL")
            toolchain:add("cuflags", "-O1", "-DNDEBUG")
            toolchain:add("ldflags", "/LTCG")
            toolchain:add("shflags", "/LTCG")
            toolchain:set("runtimes", shared and "MD" or "MT")
        end
    end)
toolchain_end()
