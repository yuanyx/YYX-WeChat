//
//  YYLoginViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYLoginViewController.h"
#import "YYRegisterViewController.h"
#import "YYNavigationController.h"

@interface YYLoginViewController ()<YYRegisterViewControlleDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation YYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置密码输入栏与登录按钮的样式
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    //设置密码输入栏左边图片
    [self.pwdField addLeftViewWithImage:@"Card_Lock"];
    
    //设置登录按钮的背景
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    
    //设置用户名为上次登录的用户名
    //从沙盒中获取用户名
    NSString *userName = [YYUserInfo sharedYYUserInfo].user;
    self.userLabel.text = userName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginBtnClick:(id)sender {
    //1.把用户名与密码存放在YYUserInfo单例中
    YYUserInfo *userInfo = [YYUserInfo sharedYYUserInfo];
    userInfo.user = self.userLabel.text;
    userInfo.pwd = self.pwdField.text;
    
    [super login];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    
    if ([destVc isKindOfClass:[YYNavigationController class]]) {
        YYNavigationController *nav = destVc;
        
        if ([nav.topViewController isKindOfClass:[YYRegisterViewController class]]) {
            YYRegisterViewController *registerVc = (YYRegisterViewController *)nav.topViewController;
            //设置代理
            registerVc.delegate = self;
        }
    }
}

#pragma mark -YYRegisterViewController代理
- (void)registerViewControllerDidFinishRegister
{
    //完成注册 userLabel显示注册的用户名
    self.userLabel.text = [YYUserInfo sharedYYUserInfo].registerUser;
    
    [MBProgressHUD showSuccess:@"请重新输入密码进行登录" toView:self.view];
}

@end
