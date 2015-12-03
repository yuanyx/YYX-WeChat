//
//  AppDelegate.h
//  WeChat
//
//  Created by 袁艳祥 on 15/12/2.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    resultTypeLoginSuccess, //登录成功
    resultTypeLoginFailure, //登录失败
    resultTypeNetErr, //网络不给力
    resultTypeRegisterSuccess, //注册成功
    resultTypeRegisterFailure //注册失败
}resultType;

typedef void (^resultBlock) (resultType type); //登录结果block

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/**注册标识 YES表示注册 NO表示登录*/
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

/** 用户登录*/
- (void)userLogin:(resultBlock)rblock;

/** 用户注消*/
- (void)userLogout;

/** 用户注册*/
- (void)userRegister:(resultBlock)rblock;
@end

