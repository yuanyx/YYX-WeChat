//
//  YYInputView.h
//  WeChat
//
//  Created by 袁艳祥 on 15/12/7.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YYInputView : UIView
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

+ (instancetype)inputView;
@end
