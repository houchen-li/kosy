rule("kosy.cxx.test")
    on_load(function (target)
        target:set("kind", "binary")
        target:set("default", false)
        target:set("group", "tests")
        target:add("packages", "cxxopts", "doctest", "matplotplusplus")
        -- CUDA's runtime maps device memory over ASan's shadow gap; without
        -- this the sanitized test binaries fail during CUDA initialization.
        -- Appended to (not replacing) any ASAN_OPTIONS already in the env.
        if not target:is_plat("windows") then
            target:add("runenvs", "ASAN_OPTIONS", "protect_shadow_gap=0")
        end
    end)
    after_load(function (target)
        target:add("tests", target:name())
    end)
rule_end()
