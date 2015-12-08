//
//  YYContactsViewController.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYContactsViewController.h"
#import "YYChatViewController.h"

@interface YYContactsViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultsControl;
}
@property (nonatomic, strong) NSArray *friends;
@end

@implementation YYContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //从数据库里加载好友信息
    [self loadFriends1];
}

- (void)loadFriends1
{
    //从CoreData中获取数据
    //1.获取上下文（关联数据库XMPPRoster.sqlite）
    NSManagedObjectContext *context = [YYXMPPTool sharedYYXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    //2.FetchRequest
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //3.设置过滤和排序
    NSString *jid = [YYUserInfo sharedYYUserInfo].jid;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
    request.predicate = predicate;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    //执行请求获取数据
    _resultsControl = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsControl.delegate = self;
    NSError *error = nil;
    [_resultsControl performFetch:&error];
    if (error) {
        YYLog(@"%@", error);
    }
}

- (void)loadFriends
{
    //从CoreData中获取数据
    //1.获取上下文（关联数据库XMPPRoster.sqlite）
    NSManagedObjectContext *context = [YYXMPPTool sharedYYXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    //2.FetchRequest
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //3.设置过滤和排序
    NSString *jid = [YYUserInfo sharedYYUserInfo].jid;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
    request.predicate = predicate;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    //执行请求获取数据
    self.friends = [context executeFetchRequest:request error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _resultsControl.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
//    }
    
    //XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = _resultsControl.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = friend.jidStr;
    
    switch ([friend.sectionNum intValue]) {//好友在线状态
        case 0: //在线
            cell.detailTextLabel.text = @"在线";
            break;
        case 1: //离开
            cell.detailTextLabel.text = @"离开";
            break;
        case 2: //离线
            cell.detailTextLabel.text = @"离线";
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark -实现这个方法，cell往左滑动就会出现删除按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *friend = _resultsControl.fetchedObjects[indexPath.row];
        XMPPJID *fJid = friend.jid;
        [[YYXMPPTool sharedYYXMPPTool].roster removeUser:fJid];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //选中表格某行联系人后进入聊开界面
    XMPPUserCoreDataStorageObject *friend = _resultsControl.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend.jid];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[YYChatViewController class]]) {
        YYChatViewController *chatVc = destVc;
        chatVc.fJid = sender;
    }
}
#pragma mark -NSFetchedResultsController代理方法，当数据库内容发生改变时会调用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //数据库数据发生改变，刷新表格
    [self.tableView reloadData];
}

@end
