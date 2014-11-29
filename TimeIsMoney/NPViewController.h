//
//  NPViewController.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sound.h" //音源クラス
#import "AppDelegate.h" //変数管理

@interface NPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *projectNameField;
@property (weak, nonatomic) IBOutlet UITextField *clientNameField;
@property (weak, nonatomic) IBOutlet UITextField *genleNameField;
@property (weak, nonatomic) IBOutlet UITextField *housyuField;

@end
