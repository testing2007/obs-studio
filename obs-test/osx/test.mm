#include <stdio.h>
#include <time.h>

#include <functional>
#include <memory>

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>

#include <util/base.h>
#include <obs.h>

static const int base_width = 1920; //800;
static const int base_height = 1080;  //600;

static const int cx = 1280; //800;
static const int cy = 720;  //600;

/* --------------------------------------------------- */

template<typename T, typename D_T, D_T D>
struct OBSUniqueHandle : std::unique_ptr<T, std::function<D_T>> {
	using base = std::unique_ptr<T, std::function<D_T>>;
	explicit OBSUniqueHandle(T *obj = nullptr) : base(obj, D) {}
	operator T *() { return base::get(); }
};

#define DECLARE_DELETER(x) decltype(x), x

using SourceContext =
	OBSUniqueHandle<obs_source, DECLARE_DELETER(obs_source_release)>;

using SceneContext =
	OBSUniqueHandle<obs_scene, DECLARE_DELETER(obs_scene_release)>;

using DisplayContext =
	OBSUniqueHandle<obs_display, DECLARE_DELETER(obs_display_destroy)>;

#undef DECLARE_DELETER

/* --------------------------------------------------- */

static void CreateOBS()
{
	if (!obs_startup("en", nullptr, nullptr))
		throw "Couldn't create OBS";

	struct obs_video_info ovi;
    ovi.adapter = 0;
    ovi.fps_num = 60;
    ovi.fps_den = 1;
    ovi.graphics_module = DL_OPENGL;
    ovi.base_width = base_width;
    ovi.base_height = base_height;
    ovi.output_width = cx;
    ovi.output_height = cy;
    ovi.output_format = VIDEO_FORMAT_NV12;
    ovi.gpu_conversion = true;
    ovi.colorspace = VIDEO_CS_709;
    ovi.range = VIDEO_RANGE_PARTIAL;
    ovi.scale_type = OBS_SCALE_BICUBIC;
    
	if (obs_reset_video(&ovi) != 0)
		throw "Couldn't initialize video";
}

static DisplayContext CreateDisplay(NSView *view)
{
	gs_init_data info = {};
	info.cx = cx*2;//在mac里面以点为单位， 所以在这个地方乘以 2
	info.cy = cy*2;
	info.format = GS_BGRA;
	info.zsformat = GS_ZS_NONE;
	info.window.view = view;

	return DisplayContext{obs_display_create(&info, 0)};
}

static SceneContext SetupScene()
{
	/* ------------------------------------------------------ */
	/* load modules */
	obs_load_all_modules();

	/* ------------------------------------------------------ */
	/* create source */
	SourceContext source{
		obs_source_create("display_capture", "a test source", nullptr, nullptr)};
	if (!source)
		throw "Couldn't create random test source";

	/* ------------------------------------------------------ */
	/* create scene and add source to scene */
	SceneContext scene{obs_scene_create("test scene")};
	if (!scene)
		throw "Couldn't create scene";

	obs_scene_add(scene, source);

	/* ------------------------------------------------------ */
	/* set the scene as the primary draw source and go */
	obs_set_output_source(0, obs_scene_get_source(scene));

	return scene;
}

@interface OBSTest : NSObject <NSApplicationDelegate, NSWindowDelegate> {
	NSWindow *win;
	NSView *view;
	DisplayContext display;
	SceneContext scene;
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app;
- (void)windowWillClose:(NSNotification *)notification;
@end

@implementation OBSTest
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	UNUSED_PARAMETER(notification);

	try {
		NSRect content_rect = NSMakeRect(0, 0, cx, cy);
		win = [[NSWindow alloc]
			initWithContentRect:content_rect
				  styleMask:NSTitledWindowMask |
					    NSClosableWindowMask
				    backing:NSBackingStoreBuffered
				      defer:NO];
		if (!win)
			throw "Could not create window";

		view = [[NSView alloc] initWithFrame:content_rect];
		if (!view)
			throw "Could not create view";

		CreateOBS();

		win.title = @"foo";
		win.delegate = self;
		win.contentView = view;

		[win orderFrontRegardless];
		[win center];
		[win makeMainWindow];

		display = CreateDisplay(view);

		scene = SetupScene();

		obs_display_add_draw_callback(
			display.get(),
			[](void *, uint32_t, uint32_t) {
            obs_render_main_texture_src_color_only();
			},
			nullptr);

	} catch (char const *error) {
		NSLog(@"%s\n", error);

		[NSApp terminate:nil];
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app
{
	UNUSED_PARAMETER(app);

	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	UNUSED_PARAMETER(notification);

	obs_set_output_source(0, nullptr);
	scene.reset();
	display.reset();

	obs_shutdown();
	NSLog(@"Number of memory leaks: %lu", bnum_allocs());
}
@end

/* --------------------------------------------------- */

int main()
{
	@autoreleasepool {
		NSApplication *app = [NSApplication sharedApplication];
		OBSTest *test = [[OBSTest alloc] init];
		app.delegate = test;

		[app run];
	}

	return 0;
}
