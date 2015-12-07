//
//  YYInputView.m
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import "YYInputView.h"

@implementation YYInputView

+ (instancetype)inputView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"YYInputView" owner:nil options:nil] lastObject];
}

@end
