//
//  topViewController.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h" //変数管理

@interface topViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
