//
//  AppDelegate.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#import "AppDelegate.h"
#include "test.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (nonatomic, strong) OBSTest *test;
@property (weak) IBOutlet NSView *contentView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self.window setTitle:@"obs-dev"];
    
    self.test = [[OBSTest alloc] init];
    [self.test launch:aNotification  contentView:self.contentView];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}

-(void)windowWillClose:(NSNotification *)notification {
    [self.test terminal];
}

@end
