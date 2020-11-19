//
//  test.h
//  obs-test
//
//  Created by ZhiQiang wei on 2020/11/16.
//

#ifndef test_h
#define test_h

#undef DECLARE_DELETER
#import <AppKit/AppKit.h>

@interface REOBSManager : NSObject
+ (instancetype)share;
- (void)setContentView:(id)view;
- (void)terminal;
@end

#endif /* test_h */
