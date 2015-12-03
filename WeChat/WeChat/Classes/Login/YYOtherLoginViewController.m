//
//  YYOtherLoginViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYOtherLoginViewController.h"


@interface YYOtherLoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


@end

@implementation YYOtherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 判断当前的设备类型，改变登录View左右的约束
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    
    //设置TextField的背景
    self.userField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    //设置按钮的背景
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnClick {
    //登录
    //1.把用户名与密码存放在YYUserInfo单例中
    
    YYUserInfo *userInfo = [YYUserInfo sharedYYUserInfo];
    userInfo.user = self.userField.text;
    userInfo.pwd = self.pwdField.text;
    
    [super login];
}

/*- (IBAction)loginBtnClick {
    //登录
    //1.把用户名存放在沙盒中
    NSString *user = self.userField.text;
    NSString *pwd = self.pwdField.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:@"user"];
    [defaults setObject:pwd forKey:@"pwd"];
    [defaults synchronize];
    
    //2.调用AppDelegate中的login方法连接服务器并登录
    //隐藏键盘
    [self.view endEditing:YES];
    
    //登录前提示用户
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
    __weak typeof(self) selfVc = self; //解决内存泄露问题
    [app userLogin:^(resultType type) {
        [selfVc handleResultType:type];
    }];
}*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end
