//
//  YYMeViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYMeViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"

@interface YYMeViewController ()
/**注消点击事件*/
- (IBAction)logoutBtnClick:(id)sender;
/**头像View*/
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
/**昵称Label*/
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
/**账号Label*/
@property (weak, nonatomic) IBOutlet UILabel *weChatNumberLabel;

@end

@implementation YYMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.tableView.rowHeight = 60;
    
    //显示当前用户信息 使用CoreData获取数据
    XMPPvCardTemp *myVCard =  [YYXMPPTool sharedYYXMPPTool].vCard.myvCardTemp;
    //设置头像
    //NSLog(@"yuan:%@",myVCard.photo);
    if (myVCard.photo) {
        self.iconImageView.image = [UIImage imageWithData:myVCard.photo];
    }
        
    //设置昵称
    self.nickNameLabel.text = myVCard.nickname;
    
    //设置账号
    self.weChatNumberLabel.text = [NSString stringWithFormat:@"微信号：%@", [YYUserInfo sharedYYUserInfo].user];
}



/*#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    //显示当前用户信息 使用CoreData获取数据
    XMPPvCardTemp *myVCard =  [YYXMPPTool sharedYYXMPPTool].vCard.myvCardTemp;
    cell.imageView.image = [UIImage imageWithData:myVCard.photo];
    cell.textLabel.text = myVCard.nickname;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"微信号：%@", [YYUserInfo sharedYYUserInfo].user];

    return cell;
}*/


- (IBAction)logoutBtnClick:(id)sender {
    //直接调用Appdelegate的注消方法
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    [app userLogout];
    [[YYXMPPTool sharedYYXMPPTool] userLogout];
}
@end
