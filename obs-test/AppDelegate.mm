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
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
//    NSWindow *t = self.window;
//    NSLog(@"t=%@", t);
//    dfdf
    self.test = [[OBSTest alloc] init];
    [self.test launch:aNotification window:self.window];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
