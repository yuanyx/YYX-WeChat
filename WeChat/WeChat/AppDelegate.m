//
//  AppDelegate.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/2.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "AppDelegate.h"
#import "YYNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSLog(@"%@",path);
    //打开XMPP的日志
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
   //设置导航条背景
    [YYNavigationController setupNavTheme];
    
    //从沙盒中加载用户信息到单例YYUserInfo中
    [[YYUserInfo sharedYYUserInfo] loadUserInfoToSanbox];
    
    //判断用户登录状态 如果为YES 直接进入主界面
    if ([YYUserInfo sharedYYUserInfo].loginStatus) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = mainStoryboard.instantiateInitialViewController;
    }
    
    //1s后自动登录服务器
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[YYXMPPTool sharedYYXMPPTool] userLogin:nil];
    });
    
    //注册应用接收通知
    if ([[UIDevice currentDevice].systemVersion doubleValue] > 8.0) {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:setting];
    }
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


@end
