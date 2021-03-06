//
//  YYProfileViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/4.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "YYEditVCardViewController.h"

@interface YYProfileViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, YYEditVCardViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;//头像
@property (weak, nonatomic) IBOutlet UILabel *weChatNumberLabel;//微信号
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;//昵称
@property (weak, nonatomic) IBOutlet UILabel *orgnameLabel;//公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel;//部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;//职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;//电话
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;//邮件


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
    
    // 公司
    self.orgnameLabel.text = myVCard.orgName;
    
    // 部门
    if (myVCard.orgUnits.count > 0) {
        self.orgunitLabel.text = myVCard.orgUnits[0];
        
    }
    
    //职位
    self.titleLabel.text = myVCard.title;
    
    //电话
#warning myVCard.telecomsAddresses 这个get方法，没有对电子名片的xml数据进行解析
    // 使用note字段充当电话
    //self.phoneLabel.text = myVCard.note;
    //NSLog(@"note%@", myVCard.note);
    if (myVCard.telecomsAddresses.count > 0) {
        self.phoneLabel.text = myVCard.telecomsAddresses[0];
    }
    
    //邮件
    // 用mailer充当邮件
   // self.emailLabel.text = myVCard.mailer;
    //解析电子邮件
    if (myVCard.emailAddresses.count > 0)
    {
        self.emailLabel.text = myVCard.emailAddresses[0];
    }
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
        [self imagePicker];
    }else { //跳到下一个界面
        YYLog(@"跳到下一个界面");
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取编辑个人信息的控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[YYEditVCardViewController class]]) {
        YYEditVCardViewController *editVc = destVc;
        editVc.cell = sender;
        editVc.delegate = self;
    }
}

//UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
//[sheet showInView:self.view];
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 2) { //取消
//        return;
//    }
//    
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    
//    if (buttonIndex == 0) { //拍照
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    } else { //相册
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    [self presentViewController:picker animated:YES completion:nil];
//}

#pragma mark -UIImagePickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
   // NSLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.iconImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //更新到服务器
    [self editVCardViewControllerDidSave];
}

- (void)imagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    
    [alertControl addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }]];
    
    [alertControl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertControl animated:YES completion:nil];
}

#pragma mark -YYEditVCardViewController代理方法
- (void)editVCardViewControllerDidSave
{
    //更新到服务器
    XMPPvCardTemp *vCard = [YYXMPPTool sharedYYXMPPTool].vCard.myvCardTemp;
    //昵称
    vCard.nickname = self.nickNameLabel.text;
    
    //头像
    vCard.photo = UIImagePNGRepresentation(self.iconImageView.image);
    
    // 公司
    vCard.orgName = self.orgnameLabel.text;
    
    // 部门
    if (self.orgunitLabel.text.length > 0) {
        vCard.orgUnits = @[self.orgunitLabel.text];
    }
    
    
    // 职位
    vCard.title = self.titleLabel.text;
    
    
    // 电话
    //vCard.note =  self.phoneLabel.text;
    if (self.phoneLabel.text.length > 0) {
        vCard.telecomsAddresses = @[self.phoneLabel.text];
    }
    
    // 邮件
    //vCard.mailer = self.emailLabel.text;
    if (self.emailLabel.text.length > 0) {
        vCard.emailAddresses = @[self.emailLabel.text];
    }

    //方法内部实现数据上传到服务器
    [[YYXMPPTool sharedYYXMPPTool].vCard updateMyvCardTemp:vCard];
}
@end
