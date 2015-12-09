//
//  YYChatViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYChatViewController.h"
#import "YYInputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface YYChatViewController ()<UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSFetchedResultsController *_resultsControl;
}

@property (nonatomic, strong) NSLayoutConstraint *inputViewConstraint;//inputView底部约束
@property (nonatomic, strong) NSLayoutConstraint *inputViewHConstraint;//inputView高度约束
@property (nonatomic, weak) UITableView *tableView;
//@property (nonatomic, weak) YYInputView *inputView;
@property (nonatomic, strong) HttpTool *httpTool;
@end

@implementation YYChatViewController

- (HttpTool *)httpTool
{
    if (!_httpTool) {
        _httpTool = [[HttpTool alloc] init];
    }
    return _httpTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //代码实现自动布局
    [self setupView];
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //加载聊天数据
    [self loadMessage];
}

//- (void)KeyboardWillChangeFrame:(NSNotification *)noti
//{
//    NSDictionary *userInfo = noti.userInfo;
//    
//    // 动画的持续时间
//    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    // 键盘的frame
//    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    
//    // 执行动画
//    [UIView animateWithDuration:duration animations:^{
//        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
//        if (keyboardF.origin.y > self.view.height) { // 键盘的Y值已经远远超过了控制器view的高度
//            self.inputView.y = self.view.height - self.inputView.height;
//        } else {
//            self.inputView.y = keyboardF.origin.y - self.inputView.height;
//            //键盘弹出，表格滚动到底部
//            [self scrollToTableViewBottom];
//        }
//    }];
//}
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
    
    //键盘弹出，表格滚动到底部
    [self scrollToTableViewBottom];
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
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //创建InputView
    YYInputView *inputView = [YYInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.msgTextView.delegate = self;
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputView];
    //self.inputView = inputView;
    
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
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    self.inputViewConstraint = [vConstraints lastObject];
    self.inputViewHConstraint = vConstraints[2];
    [self.view addConstraints:vConstraints];
    
}

#pragma mark -选择图片
- (void)addBtnClick
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark -UIImagePickerController代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:picker completion:nil];
    //获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //将图片发上传到文件服务器
    //文件上传路径http://localhost:8080/imfileserver/Upload/Image/文件名
    //1.获取文件名 用户名+时间
    NSString *user = [YYUserInfo sharedYYUserInfo].user;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [user stringByAppendingString:timeStr];
    
    //2.拼接文件上传路径
    NSString *uploadURL = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    
    //3.使用http put上传文件（put比post方式更简单，速度更快）
    [self.httpTool uploadData:UIImageJPEGRepresentation(image, 0.75) url:[NSURL URLWithString:uploadURL] progressBlock:nil completion:^(NSError *error) {
        if (!error) {
            NSLog(@"上传成功");
            [self sendMessageWithText:uploadURL bodyType:@"image"];
        }
    }];
    
    //图片发送成功，将图片的URL传给openfire服务器

}

#pragma mark -加载XMPPMessageArichiving数据库数据显示在表格中
- (void)loadMessage
{
    //上下文
    NSManagedObjectContext *context = [YYXMPPTool sharedYYXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    //请求对象
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    //过滤，排序
    //1.当前登录用户JID的消息
    //2.好友JID的消息
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", [YYUserInfo sharedYYUserInfo].jid, self.fJid.bare];
    request.predicate = predicate;
    //时间升序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    //查询
    _resultsControl = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsControl.delegate = self;
    NSError *error = nil;
    [_resultsControl performFetch:&error];
    if (error) {
        YYLog(@"%@", error);
    }
}

#pragma mark -tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultsControl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"MessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    //获取聊天消息对象
    XMPPMessageArchiving_Message_CoreDataObject *message = _resultsControl.fetchedObjects[indexPath.row];
    //显示消息
    //判断是图片还是文本
    NSString *bodyType = [message.message attributeStringValueForName:@"bodyType"];
    if ([bodyType isEqualToString:@"image"]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:message.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead"]];
        cell.textLabel.text = nil;
        return cell;
    }
//    else if ([bodyType isEqualToString:@"text"]) {
//       if ([message.outgoing boolValue]) { //自己发的消息
//          cell.textLabel.text = [NSString stringWithFormat:@"Me: %@", message.body];
//        }else { //对方发的消息
//          cell.textLabel.text = [NSString stringWithFormat:@"Other: %@", message.body];
//        }
//        cell.imageView.image = nil;
//    }
    
    if ([message.outgoing boolValue]) { //自己发的消息
        cell.textLabel.text = [NSString stringWithFormat:@"Me: %@", message.body];
        cell.imageView.image = nil;
    }else { //对方发的消息
        cell.textLabel.text = [NSString stringWithFormat:@"Other: %@", message.body];
        cell.imageView.image = nil;
    }
    
    return cell;
}

#pragma mark -NSFetchedResultsController代理方法，当数据库内容发生改变时会调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //数据库数据发生改变，刷新表格
    [self.tableView reloadData];
    [self scrollToTableViewBottom];
}

#pragma mark -UITextView代理方法
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat contentH = textView.contentSize.height;
    if (contentH > 33 && contentH < 70) { //高度在三行内
        self.inputViewHConstraint.constant = contentH + 18;
    }
    
    NSString *text = textView.text;
    //换行就相当于点了Send
    if ([text rangeOfString:@"\n"].length != 0) {
        //去除换行符
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //发送数据
        [self sendMessageWithText:text bodyType:@"text"];
        //清空输入框的消息
        textView.text = nil;
        
        //发送完消息后改变约束
        self.inputViewHConstraint.constant = 50;
    }
}

#pragma mark -发送聊天消息
- (void)sendMessageWithText:(NSString *)text bodyType:(NSString *)bodyType
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.fJid];//type:chat代表个人聊天（私聊）
    //bodyType为text:纯文本 image:图片
    if ([bodyType isEqualToString:@"image"]) {
        [message addAttributeWithName:@"bodyType" stringValue:bodyType];
    }
    //[message addAttributeWithName:@"bodyType" stringValue:bodyType];
    //设置消息内容
    [message addBody:text];
    [[YYXMPPTool sharedYYXMPPTool].xmppStream sendElement:message];
}

#pragma mark -滚动到表格底部
- (void)scrollToTableViewBottom
{
    NSInteger lastRow = _resultsControl.fetchedObjects.count - 1;
    if (lastRow < 0) {
        return;
    }
    NSIndexPath *lastCell = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
@end
