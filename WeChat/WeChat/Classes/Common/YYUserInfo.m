//
//  YYUserInfo.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYUserInfo.h"
#define UserKey @"user"
#define LoginStatusKey @"loginStatus"
#define PasswordKey @"pwd"


@implementation YYUserInfo

singleton_implementation(YYUserInfo)

- (void)saveUserInfoToSanbox
{
     [[NSUserDefaults standardUserDefaults] setObject:self.user forKey:UserKey];
    [[NSUserDefaults standardUserDefaults] setBool:self.loginStatus forKey:LoginStatusKey];
   [[NSUserDefaults standardUserDefaults] setObject:self.pwd forKey:PasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadUserInfoToSanbox
{
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:UserKey];
    self.loginStatus = [[NSUserDefaults standardUserDefaults] boolForKey:LoginStatusKey];
    self.pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordKey];
}

- (NSString *)jid
{
    return [NSString stringWithFormat:@"%@@%@", self.user, domain];
}
@end
