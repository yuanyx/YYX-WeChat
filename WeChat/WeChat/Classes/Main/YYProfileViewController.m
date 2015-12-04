//
//  YYProfileViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/4.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYProfileViewController.h"
#import "XMPPvCardTemp.h"

@interface YYProfileViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;//头像
@property (weak, nonatomic) IBOutlet UILabel *weChatNumberLabel;//微信号
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//昵称

@end

@implementation YYProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //显示当前用户信息 使用CoreData获取数据
    XMPPvCardTemp *myVCard =  [YYXMPPTool sharedYYXMPPTool].vCard.myvCardTemp;
    //设置头像
    if (myVCard.photo) {
        self.iconImageView.image = [UIImage imageWithData:myVCard.photo];
    }
    
    //设置昵称
    self.nickNameLabel.text = myVCard.nickname;
    
    //设置账号
    self.weChatNumberLabel.text = [YYUserInfo sharedYYUserInfo].user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*#pragma mark - Table view data source

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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取cell的tag
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    if (tag == 2) { //不做任何操作
        return;
    }
    
    if (tag == 0) { //选择图片
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        [sheet showInView:self.view];
    }else { //跳到下一个界面
        YYLog(@"跳到下一个界面");
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) { //取消
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    if (buttonIndex == 0) { //拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else { //相册
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
   // NSLog(@"%@", info);
    self.iconImageView.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
