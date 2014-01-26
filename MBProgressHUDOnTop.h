//
//  MBProgressHUDOnTop.h
//  LMovieB
//
//  Created by Jonathan Duss on 17.02.13.
//
//

#import "MBProgressHUD.h"
#import "UIWindow+Extension.h"




@interface MBProgressHUDOnTop : MBProgressHUD

-(id)initOnTop;
-(void)showProgressAnimationOnTop;
-(void)hideProgressAnimationOnTop;


@end
