//
//  AppDelegate.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#import "AppDelegate.h"
#include "REOBSMainVC.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self.window setTitle:@"obs-dev"];
    
    REOBSMainVC *vc = [REOBSMainVC new];
    self.window.delegate = vc;
    [self.window setContentViewController:vc];
    [self.window makeMainWindow];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}

@end
