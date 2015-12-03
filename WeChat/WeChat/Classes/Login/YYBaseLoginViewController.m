//
//  YYBaseLoginViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYBaseLoginViewController.h"
#import "AppDelegate.h"

@interface YYBaseLoginViewController ()

@end

@implementation YYBaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login
{
    //登录
    
    //2.调用AppDelegate中的login方法连接服务器并登录
    //隐藏键盘
    [self.view endEditing:YES];
    
    //登录前提示用户
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.registerOperation = NO;
    
    __weak typeof(self) selfVc = self; //解决内存泄露问题
    [app userLogin:^(resultType type) {
        [selfVc handleResultType:type];
    }];
}


- (void)handleResultType:(resultType)type
{
    //在主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case resultTypeLoginSuccess:
                NSLog(@"登录成功");
                //[MBProgressHUD showMessage:@"登录成功"];
                [self enterMainViewController];
                break;
                
            case resultTypeLoginFailure:
                NSLog(@"登录失败");
                [MBProgressHUD showError:@"用户名或密码不正确" toView:self.view];
                break;
                
            case resultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
                break;
            default:
                break;
        }
    });
}

- (void)enterMainViewController
{
    //更改登录状态为YES
    [YYUserInfo sharedYYUserInfo].loginStatus = YES;
    
    //把用户登录成功的信息保存到沙盒中
    [[YYUserInfo sharedYYUserInfo] saveUserInfoToSanbox];
    
    //隐藏模态窗口
    [self dismissViewControllerAnimated:NO completion:nil];
    
    //登录成功跳到主界面
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController = mainStoryboard.instantiateInitialViewController;
}


@end
