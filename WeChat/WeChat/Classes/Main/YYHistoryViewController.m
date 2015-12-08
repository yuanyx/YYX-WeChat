//
//  YYHistoryViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/8.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYHistoryViewController.h"

@interface YYHistoryViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation YYHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //监听登录状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChange:) name:YYLoginStatusChangeNotification object:nil];
}

- (void)loginStatusChange:(NSNotification *)notifi
{
    //获取登录状态
    dispatch_async(dispatch_get_main_queue(), ^{
        int status = [notifi.userInfo[@"loginStatus"] intValue];
        switch (status) {
            case resultTypeConnecting: //正在连接
                [self.indicator startAnimating];
                break;
            case resultTypeLoginSuccess: //登录成功
                [self.indicator stopAnimating];
                break;
            case resultTypeLoginFailure: //登录失败
                [self.indicator stopAnimating];
                break;
            case resultTypeNetErr: //连接失败
                [self.indicator stopAnimating];
                break;
            default:
                break;
        }
    });
}

- (void)didReceiveMemoryWarning {
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
