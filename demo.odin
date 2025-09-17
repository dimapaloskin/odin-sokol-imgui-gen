package demo

import "base:runtime"
import "core:log"

import cimgui "libs/cimgui"
import sapp "libs/sokol/app"
import sg "libs/sokol/gfx"
import sglue "libs/sokol/glue"
import shelpers "libs/sokol/helpers"
import simgui "libs/sokol/imgui"

odin_ctx: runtime.Context
pip: sg.Pipeline
color: [4]f32

main :: proc() {
	context.logger = log.create_console_logger()
	odin_ctx = context

	sapp.run(
		{
			high_dpi = true,
			width = 800,
			height = 600,
			fullscreen = false,
			window_title = "Hello there",
			init_cb = sapp_init_cb,
			cleanup_cb = sapp_cleanup_cb,
			event_cb = sapp_event_cb,
			frame_cb = sapp_frame_cb,
			allocator = sapp.Allocator(shelpers.allocator(&odin_ctx)),
			logger = sapp.Logger(shelpers.logger(&odin_ctx)),
		},
	)

	log.debug(cimgui.ImDrawCmd_GetTexID)
}


sapp_init_cb :: proc "c" () {
	context = odin_ctx

	color = {0.534, 0.861, 0.892, 1.0}

	sg.setup(
		{
			environment = sglue.environment(),
			allocator = sg.Allocator(shelpers.allocator(&odin_ctx)),
			logger = sg.Logger(shelpers.logger(&odin_ctx)),
		},
	)

	simgui.setup(
		{
			allocator = simgui.Allocator(shelpers.allocator(&odin_ctx)),
			logger = simgui.Logger(shelpers.logger(&odin_ctx)),
		},
	)
}


sapp_cleanup_cb :: proc "c" () {
	context = odin_ctx

	sg.shutdown()
}

sapp_frame_cb :: proc "c" () {
	context = odin_ctx

	simgui.new_frame(
		{
			width = sapp.width(),
			height = sapp.height(),
			delta_time = sapp.frame_duration(),
			dpi_scale = sapp.dpi_scale(),
		},
	)

	cimgui.set_next_window_pos({10, 10}, .Once)
	cimgui.set_next_window_size({400, 100}, .Once)

	cimgui.begin("Hello there", nil, .None)
	cimgui.color_edit4("Background", &color, .None)
	if bool(cimgui.button("Quit")) {
		sapp.quit()
	}

	cimgui.end()

	sg.begin_pass(
		{
			swapchain = shelpers.glue_swapchain(),
			action = {
				colors = {
					0 = {
						load_action = .CLEAR,
						clear_value = {color.r, color.g, color.b, color.a},
						store_action = .STORE,
					},
				},
			},
		},
	)

	simgui.render()
	sg.end_pass()
	sg.commit()
}

sapp_event_cb :: proc "c" (ev: ^sapp.Event) {
	context = odin_ctx

	simgui.handle_event(ev^)

	if ev.type == .QUIT_REQUESTED || (ev.type == .KEY_DOWN && ev.key_code == .ESCAPE) {
		sapp.quit()
	}
}
