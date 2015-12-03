//
//  YYRegisterViewController.h
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYRegisterViewControlleDelegate <NSObject>

/**完成注册*/
- (void)registerViewControllerDidFinishRegister;
 @end

@interface YYRegisterViewController : UIViewController

@property (nonatomic, weak) id<YYRegisterViewControlleDelegate> delegate;
@end
