//
//  YYXMPPTool.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/4.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYXMPPTool.h"

#define LogDomain  @"yuan.local"
NSString *const YYLoginStatusChangeNotification = @"YYLoginStatusNotification";

/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */

@interface YYXMPPTool ()<XMPPStreamDelegate>
{
    //XMPPStream *_xmppStream;
    resultBlock _rblock;
    
   // XMPPvCardTempModule *_vCard; //电子名片
    XMPPvCardCoreDataStorage *_vCardStorage; //电子名片存储
    XMPPvCardAvatarModule *_avatar; //头像模块
    XMPPReconnect *_reconnect; //自动连接模块
    //XMPPRoster *_roster; //花名册模块
    //XMPPRosterCoreDataStorage *_rosterStorage; //花名册数据存储
    XMPPMessageArchiving *_messageArchiving; //聊天模块
    //XMPPMessageArchivingCoreDataStorage *_msgArchivingStorage;//聊天消息存储
}
//1. 初始化XMPPStream
- (void)setupXMPPStream;

//2. 连接到服务器[传一个JID]
- (void)connectToHost;

//3. 连接到服务成功后，再发送密码授权
- (void)sendPwdToHost;

//4. 授权成功后，发送"在线" 消息
- (void)sendOnlineToHost;
@end

@implementation YYXMPPTool

singleton_implementation(YYXMPPTool)

#pragma mark -私有方法
#pragma mark -初始化XMPPStream
- (void)setupXMPPStream
{
    _xmppStream = [[XMPPStream alloc] init];
    
    //每一个模块添加后都需要激活
    //添加自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
    //添加电子名片模块获取个人信息
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活电子名片模块
    [_vCard activate:_xmppStream];
    
    
    //添加头像模块
   _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    //激活头像模块
    [_avatar activate:_xmppStream];
    
    //添加花名册模块（获取好友列表）
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    //添加消息（聊天）模块
    _msgArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingStorage];
    [_messageArchiving activate:_xmppStream];
    
    _xmppStream.enableBackgroundingOnSocket = YES; //iOS7以前本地通知必须设置
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

//释放XMPP
- (void)teardownXMPP
{
    //移除代理
    [_xmppStream removeDelegate:self];
    //停止模块
    [_vCard deactivate];
    [_avatar deactivate];
    [_reconnect deactivate];
    [_roster deactivate];
    [_messageArchiving deactivate];
    //断开连接
    [_xmppStream disconnect];
    //清空资源
    _xmppStream = nil;
    _vCard = nil;
    _vCardStorage = nil;
    _avatar = nil;
    _reconnect = nil;
    _roster = nil;
    _rosterStorage = nil;
    _messageArchiving = nil;
    _msgArchivingStorage = nil;
}

#pragma mark -连接到服务器
- (void)connectToHost
{
    YYLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    //发送登录状态通知
    [self postNotification:resultTypeConnecting];
    
    //设置JID
    //resource标识用户登录的客户端 iphone
    
    //从单例中获取用户名
    NSString *user = nil;
    if (self.isRegisterOperation) {
        user = [YYUserInfo sharedYYUserInfo].registerUser;
    } else {
        user = [YYUserInfo sharedYYUserInfo].user;
    }
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:LogDomain resource:@"iPhone"];
    _xmppStream.myJID = myJID;
    
    //设置服务器域名
    _xmppStream.hostName = LogDomain;//@"yuan.local";//还可以是IP地址
    
    //设置端口
    _xmppStream.hostPort = 5222;
    
    NSError *err = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        YYLog(@"%@",err);
    }
}

#pragma mark -连接到服务成功后，再发送密码授权
- (void)sendPwdToHost
{
    YYLog(@"再发送密码授权");
    NSError *err = nil;
    //从单例中获取密码
    NSString *pwd = [YYUserInfo sharedYYUserInfo].pwd;
    [_xmppStream authenticateWithPassword:pwd error:&err];
    if (err) {
        YYLog(@"%@",err);
    }
}

#pragma mark -授权成功后，发送"在线" 消息
- (void)sendOnlineToHost
{
    YYLog(@"发送 在线 消息");
    XMPPPresence *presence = [XMPPPresence presence];
    YYLog(@"%@",presence);
    [_xmppStream sendElement:presence];
}

#pragma mark -通知YYHistoryViewController登录状态
- (void)postNotification:(resultType)type
{
    NSDictionary *userInfo = @{@"loginStatus":@(type)};
    [[NSNotificationCenter defaultCenter] postNotificationName:YYLoginStatusChangeNotification object:nil userInfo:userInfo];
}

#pragma mark -XMPPStream的代理方法
#pragma mark -与主机连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    YYLog(@"与主机连接成功");
    
    if (self.isRegisterOperation) { //注册操作，发送注册密码
        NSString *registerPwd = [YYUserInfo sharedYYUserInfo].registerPwd;
        NSError *err = nil;
        [_xmppStream registerWithPassword:registerPwd error:&err];
        if (err) {
            YYLog(@"注册连接失败 %@",err);
        }
    } else {
        //连接成功发送密码给服务器进行授权
        [self sendPwdToHost];
    }
}

#pragma mark -与主机连接断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    //有错误表示连接失败，没有错误表示人为断开连接
    if (error && _rblock) {
        _rblock(resultTypeNetErr);
    }
    
    if (error) { //通知网络不好
        [self postNotification:resultTypeNetErr];
    }
    YYLog(@"与主机连接断开连接 %@", error);
}

#pragma mark -授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    YYLog(@"授权成功");
    [self sendOnlineToHost];
    
    //登录成功回调
    if (_rblock) {
        _rblock(resultTypeLoginSuccess);
    }
    
    [self postNotification:resultTypeLoginSuccess];
}

#pragma mark -授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    YYLog(@"授权失败 %@", error);
    //授权失败提示用户登录失败
    if (_rblock) {
        _rblock(resultTypeLoginFailure);
    }
    
    [self postNotification:resultTypeLoginFailure];
}

#pragma mark -注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    YYLog(@"注册成功");
    if (_rblock) {
        _rblock(resultTypeRegisterSuccess);
    }
}

#pragma mark -注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    YYLog(@"注册失败 %@", error);
    if (_rblock) {
        _rblock(resultTypeRegisterFailure);
    }
}

#pragma mark -接收到好友消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //YYLog(@"%@", message);
    //如果不在前台，发送本地通知
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        //开启本地通知
        UILocalNotification *localNoti = [[UILocalNotification alloc] init];
        //设置内容
        localNoti.alertBody = [NSString stringWithFormat:@"%@\n%@", message.fromStr, message.body];
        //设置执行时间
        localNoti.fireDate = [NSDate date];
        //设置音效
        localNoti.soundName = @"default";
        //执行本地通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
    }
}

#pragma mark -公共方法
/**用户注消*/
- (void)userLogout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
    
    //3. 回到登录界面
    [UIStoryboard showInitialVCWithName:@"Login"];
//    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    self.window.rootViewController = loginStoryboard.instantiateInitialViewController;
    
    //4. 更改用户登录状态为NO并存入沙盒 用户注消后重新登录
    [YYUserInfo sharedYYUserInfo].loginStatus = NO;
    [[YYUserInfo sharedYYUserInfo] saveUserInfoToSanbox];
}

/**用户登录*/
- (void)userLogin:(resultBlock)rblock
{
    //把block存起来
    _rblock = rblock;
    
    //如果以前连接过服务器，要断开
    [_xmppStream disconnect];
    
    //连接主机成功发送登录密码
    [self connectToHost];
}

/**用户注册*/
- (void)userRegister:(resultBlock)rblock
{
    //把block存起来
    _rblock = rblock;
    
    //如果以前连接过服务器，要断开
    [_xmppStream disconnect];
    
    //连接主机成功发送注册密码
    [self connectToHost];
}

- (void)dealloc
{
    [self teardownXMPP]; //释放XMPP
}

@end
