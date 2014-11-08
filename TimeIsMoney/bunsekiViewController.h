//
//  bunsekiViewController.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/15.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h" //変数管理

@interface bunsekiViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *timelabel;

@property (weak, nonatomic) IBOutlet UILabel *jikyulabel;
@property (weak, nonatomic) IBOutlet UILabel *prolabel;


@property (weak, nonatomic) IBOutlet UITextView *prjLabel;

@property (weak, nonatomic) IBOutlet UITextView *textview;

@end
