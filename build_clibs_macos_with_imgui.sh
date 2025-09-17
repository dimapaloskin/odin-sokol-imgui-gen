source build_clibs_macos.sh

build_lib_arm64_release sokol_imgui          imgui/sokol_imgui_macos_arm64_metal_release SOKOL_METAL
build_lib_arm64_debug   sokol_imgui          imgui/sokol_imgui_macos_arm64_metal_debug SOKOL_METAL
build_lib_x64_release   sokol_imgui          imgui/sokol_imgui_macos_x64_metal_release SOKOL_METAL
build_lib_x64_debug     sokol_imgui          imgui/sokol_imgui_macos_x64_metal_debug SOKOL_METAL
