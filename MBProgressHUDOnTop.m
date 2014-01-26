//
//  MBProgressHUDOnTop.m
//  LMovieB
//
//  Created by Jonathan Duss on 17.02.13.
//
//

#import "MBProgressHUDOnTop.h"

@interface MBProgressHUDOnTop ()
@property UIView *blackBackGroud;
@property UIViewController *topVC;
@property UIWindow *window;

@end



@implementation MBProgressHUDOnTop

-(id)initOnTop{

    //init self
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self = [super initWithWindow:window];
    
    //Init class property
    _topVC = [[UIApplication sharedApplication].keyWindow topMostController];
    _window = window;

    //param progressView
    [self setMode:MBProgressHUDModeDeterminate];
    [self setHidden:YES];
    [self setMinShowTime:1];

    
    
    //param of blackBackground
    CGRect winFrame = _topVC.view.bounds;

    _blackBackGroud = [[UIView alloc] initWithFrame:winFrame];
    _blackBackGroud.alpha = 0.0;
    [_blackBackGroud setHidden:YES];
    [_blackBackGroud setBackgroundColor:[UIColor blackColor]];

    
    return self;
}

-(void)showProgressAnimationOnTop{
    
    
    //show Black Background
    _blackBackGroud.alpha = 0.0;
    [_blackBackGroud setHidden:NO];
    [_topVC.view addSubview:_blackBackGroud];
    [_topVC.view bringSubviewToFront:_blackBackGroud];
    
    [UIView animateWithDuration:0.5 animations:^{
        [_blackBackGroud setAlpha:0.5];
    }];
    
    
    //show progressView
    [_topVC.view addSubview:self];
    [_topVC.view bringSubviewToFront:self];
    [self setHidden:NO];
    [self setProgress:0];
    [self show:YES];
    
    
}

-(void)hideProgressAnimationOnTop{
    
    //hide progressView
    [self hide:YES];
    
    
    //hide black background
    [UIView animateWithDuration:0.5 animations:^{
        [_blackBackGroud setAlpha:0];
    } completion:^(BOOL finished){
        [_blackBackGroud removeFromSuperview];
    }];
        
}

@end

