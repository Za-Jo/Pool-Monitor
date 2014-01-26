//
//  UIWindow+Extension.m
//  LMovieB
//
//  Created by Jonathan Duss on 16.02.13.
//
//

#import "UIWindow+Extension.h"

@implementation UIWindow (Extension)
- (UIViewController*) topMostController
{
    UIViewController *topController = [self rootViewController];
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}
@end
