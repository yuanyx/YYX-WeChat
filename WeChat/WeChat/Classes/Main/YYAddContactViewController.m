//
//  YYAddContactViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYAddContactViewController.h"

@interface YYAddContactViewController ()<UITextFieldDelegate>

@end

@implementation YYAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView becomeFirstResponder];
    self.title = @"添加好友";
}

/*- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //添加好友
    //1.获取好友账号
    NSString *user = textField.text;
    //判断账号是否为手机号码
    if (![textField isTelphoneNum]) {
        [MBProgressHUD showError:@"请输入正确的手机号码" toView:self.view];
        return YES;
    }
    //判断是否添加自己
    if ([user isEqualToString:[YYUserInfo sharedYYUserInfo].user]){
        [MBProgressHUD showError:@"不能添加自己为好友" toView:self.view];
        return YES;
    }
    
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@", user, domain];
    XMPPJID *fJid = [XMPPJID jidWithString:jidStr];
    
    //判断好友是否已经存在
    if ([[YYXMPPTool sharedYYXMPPTool].rosterStorage userExistsWithJID:fJid xmppStream:[YYXMPPTool sharedYYXMPPTool].xmppStream]) {
        [MBProgressHUD showError:@"当前好友已经存在" toView:self.view];
        return YES;
    }
    
    //2.发送添加好友请求
    
    [[YYXMPPTool sharedYYXMPPTool].roster subscribePresenceToUser:fJid];
    return YES;
}
@end
