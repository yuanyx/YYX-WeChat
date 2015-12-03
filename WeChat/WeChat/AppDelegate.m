//
//  AppDelegate.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/2.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "YYNavigationController.h"
/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */

@interface AppDelegate ()<XMPPStreamDelegate>
{
    XMPPStream *_xmppStream;
    resultBlock _rblock;
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

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   //设置导航条背景
    [YYNavigationController setupNavTheme];
    
    //从沙盒中加载用户信息到单例YYUserInfo中
    [[YYUserInfo sharedYYUserInfo] loadUserInfoToSanbox];
    
    //判断用户登录状态 如果为YES 直接进入主界面
    if ([YYUserInfo sharedYYUserInfo].loginStatus) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = mainStoryboard.instantiateInitialViewController;
    }
    
    //自动登录服务器
    [self userLogin:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -私有方法
#pragma mark -初始化XMPPStream
- (void)setupXMPPStream
{
    _xmppStream = [[XMPPStream alloc] init];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark -连接到服务器
- (void)connectToHost
{
    YYLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    
    //设置JID
    //resource标识用户登录的客户端 iphone
    
    //从单例中获取用户名
    NSString *user = nil;
    if (self.isRegisterOperation) {
        user = [YYUserInfo sharedYYUserInfo].registerUser;
    } else {
        user = [YYUserInfo sharedYYUserInfo].user;
    }
    
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"yuan.local" resource:@"iPhone"];
    _xmppStream.myJID = myJID;
    
    //设置服务器域名
    _xmppStream.hostName = @"yuan.local";//还可以是IP地址
    
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
}

#pragma mark -授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    YYLog(@"授权失败 %@", error);
    //授权失败提示用户登录失败
    if (_rblock) {
        _rblock(resultTypeLoginFailure);
    }
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

#pragma mark -公共方法
/**用户注消*/
- (void)userLogout{
    // 1." 发送 "离线" 消息"
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    
    // 2. 与服务器断开连接
    [_xmppStream disconnect];
    
    //3. 回到登录界面
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    self.window.rootViewController = loginStoryboard.instantiateInitialViewController;
    
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

@end
