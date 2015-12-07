//
//  YYChatViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYChatViewController.h"
#import "YYInputView.h"

@interface YYChatViewController ()

@property (nonatomic, strong) NSLayoutConstraint *inputViewConstraint;//inputView底部约束
@end

@implementation YYChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //代码实现自动布局
    [self setupView];
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)KeyboardWillShow:(NSNotification *)noti
{
    NSLog(@"%@",noti.userInfo);
    //获取键盘的高度
    CGRect kbEndFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrame.size.height;
    
//    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
//        kbHeight = kbEndFrame.size.width;//适配iOS7
//    }
    self.inputViewConstraint.constant = kbHeight;
}

- (void)KeyboardWillHide:(NSNotification *)noti
{
    //隐藏键盘的时候，距离底部的约束永远为0
    self.inputViewConstraint.constant = 0;
}
//-(void)kbFrmWillChange:(NSNotification *)noti{
//    NSLog(@"%@",noti.userInfo);
//    
//    // 获取窗口的高度
//    
//    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
//    
//    
//    
//    // 键盘结束的Frm
//    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    // 获取键盘结束的y值
//    CGFloat kbEndY = kbEndFrm.origin.y;
//    
//    
//    self.inputViewConstraint.constant = windowH - kbEndY;
//}


#pragma mark -代码实现自动布局 用VFL
- (void)setupView
{
    //创建tableView
    UITableView *tableView = [[UITableView alloc] init];
    tableView.backgroundColor = [UIColor redColor];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    
    //创建InputView
    YYInputView *inputView = [YYInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inputView];
    
    //自动布局
    //水平方向上的约束
    NSDictionary *views = @{@"tableView":tableView,@"inputView":inputView};
    //1.tableView的约束
   NSArray *tableViewHC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewHC];
    
    //2.inputView的约束
    NSArray *inputViewHC = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHC];
    
    //垂直方向上的约束
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    self.inputViewConstraint = [vConstraints lastObject];
    [self.view addConstraints:vConstraints];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
