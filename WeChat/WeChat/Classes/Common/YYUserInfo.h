//
//  YYUserInfo.h
//  WeChat
//
//  Created by 袁艳祥 on 15/12/3.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
static NSString *domain = @"yuan.local";

@interface YYUserInfo : NSObject

singleton_interface(YYUserInfo)

/**登录用户名*/
@property (nonatomic, copy) NSString *user;
/**登录密码*/
@property (nonatomic, copy) NSString *pwd;
/**记录用户登录状态 YES 登录过 NO 没登录过*/
@property (nonatomic, assign) BOOL loginStatus;

/**注册用户名*/
@property (nonatomic, copy) NSString *registerUser;
/**注册密码*/
@property (nonatomic, copy) NSString *registerPwd;

@property (nonatomic, copy) NSString *jid;

/**保存数据到沙盒中*/
- (void)saveUserInfoToSanbox;

/**从沙盒中获取用户信息*/
- (void)loadUserInfoToSanbox;
@end
