add_rules("mode.release", "mode.debug", "mode.releasedbg")
set_policy("build.ccache", not is_plat("windows"))
set_policy("check.auto_ignore_flags", false)

if (is_os("windows")) then
    add_defines("UNICODE", "_UNICODE", "NOMINMAX", "_WINDOWS")
    add_defines("_GAMING_DESKTOP")
    add_defines("_CRT_SECURE_NO_WARNINGS")
    add_defines("_ENABLE_EXTENDED_ALIGNED_STORAGE")
    add_defines("_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR") -- for preventing std::mutex crash when lock
    if (is_mode("release")) then
        set_runtimes("MD")
    elseif (is_mode("asan")) then
        add_defines("_DISABLE_VECTOR_ANNOTATION")
        -- else
        --     set_runtimes("MDd")
    end
end

if os.exists("xmake/options.lua") then
    includes("xmake/options.lua")
end

if my_options then
    for k, v in pairs(my_options) do
        set_config(k, v)
    end
end
set_config("enable_tests", false)
set_config("enable_gui", true)
set_config("enable_osl", false)
includes("compute")

target("py_test")
add_rules("lc_basic_settings", {
    project_kind = "shared"
})
add_files("main.cpp")
add_deps("lc-core", "lc-runtime", "lc-dsl", "lc-gui", "lc-backends-dummy")
add_includedirs("compute/src/ext/pybind11/include")
on_load(function(target)
    local function split_str(str, chr, func)
        for part in string.gmatch(str, "([^" .. chr .. "]+)") do
            func(part)
        end
    end
    local py_include = get_config("my_py_include")
    split_str(py_include, ';', function(v)
        target:add("includedirs", v)
    end)
    local py_linkdir = get_config("my_py_linkdir")
    local py_libs = get_config("my_py_libs")
    if type(py_linkdir) == "string" then
        split_str(py_linkdir, ';', function(v)
            target:add("linkdirs", v)
        end)
    end
    if type(py_libs) == "string" then
        split_str(py_libs, ';', function(v)
            target:add("links", v)
        end)
    end
    local function rela(p)
        return path.absolute(p, os.scriptdir())
    end
    target:set("pcxxheader", rela("blender_pch.h"))
end)
set_extension(".pyd")
add_cxflags("/bigobj", {
    tools = "cl"
})
target_end()
