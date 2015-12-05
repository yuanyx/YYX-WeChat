//
//  YYEditVCardViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/5.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYEditVCardViewController.h"
//#import "XMPPvCardTemp.h"

@interface YYEditVCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *editTextField;


@end

@implementation YYEditVCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题和TextField的默认
    self.title = self.cell.textLabel.text;
    self.editTextField.text = self.cell.detailTextLabel.text;
    
    //右边添加“保存”按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnClick)];
}

- (void)saveBtnClick
{
    self.cell.detailTextLabel.text = self.editTextField.text;
    [self.cell layoutSubviews];
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(editVCardViewControllerDidSave)]) {
        [self.delegate editVCardViewControllerDidSave];
    }
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


@end
