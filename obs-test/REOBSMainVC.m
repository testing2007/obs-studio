//
//  REOBSMainVC.m
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/19.
//

#import "REOBSMainVC.h"
#import "REOBSManager.h"

@interface REOBSMainVC ()
@property (weak) IBOutlet NSView *contentView;

@end

@implementation REOBSMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[REOBSManager share] setContentView:self.contentView];

}

@end
