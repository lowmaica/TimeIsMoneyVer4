//
//  NewidViewController.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/11/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewidViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *idtextfield;
@property (weak, nonatomic) IBOutlet UITextField *passtextfield;
- (IBAction)newid:(id)sender;

@end
