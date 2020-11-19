//
//  test.h
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#ifndef test_h
#define test_h

#include <stdio.h>
#include <time.h>

#include <functional>
#include <memory>

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>

#include <util/base.h>
#include <obs.h>

template<typename T, typename D_T, D_T D>
struct OBSUniqueHandle : std::unique_ptr<T, std::function<D_T>> {
    using base = std::unique_ptr<T, std::function<D_T>>;
    explicit OBSUniqueHandle(T *obj = nullptr) : base(obj, D) {}
    operator T* () { return base::get(); }
};

#define DECLARE_DELETER(x) decltype(x), x

using SourceContext =
    OBSUniqueHandle<obs_source, DECLARE_DELETER(obs_source_release)>;

using SceneContext =
    OBSUniqueHandle<obs_scene, DECLARE_DELETER(obs_scene_release)>;

using DisplayContext =
    OBSUniqueHandle<obs_display, DECLARE_DELETER(obs_display_destroy)>;

using OutputContext = OBSUniqueHandle<obs_output,DECLARE_DELETER(obs_output_release)>;

using EncoderContext = OBSUniqueHandle<obs_encoder_t,DECLARE_DELETER(obs_encoder_release)>;

#undef DECLARE_DELETER
@interface OBSTest : NSObject <NSApplicationDelegate, NSWindowDelegate> {
//    NSWindow *win;
//    NSView *view;
    DisplayContext display;
    SceneContext scene;
    OutputContext fileOutput;
    EncoderContext h264Recording;
    EncoderContext aacRecording;
}
- (void)launch:(NSNotification *)notification window:(NSWindow*)win;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app;
- (void)windowWillClose:(NSNotification *)notification;
@end

#endif /* test_h */
