//
//  YYRegisterViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYRegisterViewController.h"
#import "AppDelegate.h"

@interface YYRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;

- (IBAction)registerBtnClick;

@end

@implementation YYRegisterViewController

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
    [self.registerBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**用户注册点击事件*/
- (IBAction)registerBtnClick {
    
    [self.view endEditing:YES];
    //判断用户输入的是否为手机号码
    if ([self.userField isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view];
        return;
    }
    
    //1.把用户名与密码存放在YYUserInfo单例中
    YYUserInfo *userInfo = [YYUserInfo sharedYYUserInfo];
    userInfo.registerUser = self.userField.text;
    userInfo.registerPwd = self.pwdField.text;
    
    [self.view endEditing:YES];
    //2.调用Appdelegate的用户注册方法
    //注册前提示用户
    [MBProgressHUD showMessage:@"正在注册中..." toView:self.view];

     __weak typeof(self) selfVc = self; //解决内存泄露问题
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.registerOperation = YES;
    [app userRegister:^(resultType type) {
        [selfVc handleResultType:type];
    }];
}

/**注册结果处理*/
- (void)handleResultType:(resultType)type
{
    //在主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case resultTypeRegisterSuccess:
                [MBProgressHUD showSuccess:@"注册成功" toView:self.view];
                //回到上一个控制器
                [self dismissViewControllerAnimated:NO completion:nil];
                if ([self.delegate respondsToSelector:@selector(registerViewControllerDidFinishRegister)]) {
                    [self.delegate registerViewControllerDidFinishRegister];
                }
                break;
                
            case resultTypeRegisterFailure:
                NSLog(@"注册失败");
                [MBProgressHUD showError:@"注册失败, 用户名重复" toView:self.view];
                break;
                
            case resultTypeNetErr:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
                break;
            default:
                break;
        }
    });
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textChange {
    //设置注册按钮的可用状态
    self.registerBtn.enabled = (self.userField.text.length != 0 && self.pwdField.text.length != 0);
}

@end
