//
//  YYEditVCardViewController.h
//  WeChat
//
//  Created by 袁艳祥 on 15/12/5.
//  Copyright © 2015年 袁艳祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YYEditVCardViewControllerDelegate <NSObject>

- (void)editVCardViewControllerDidSave;

@end

@interface YYEditVCardViewController : UITableViewController

@property (nonatomic, strong) UITableViewCell *cell;
@property (nonatomic, weak) id<YYEditVCardViewControllerDelegate> delegate;
@end
