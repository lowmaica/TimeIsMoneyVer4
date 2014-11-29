//
//  CDViewController.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sound.h" //音源クラス
#import "AppDelegate.h" //変数管理

@interface CDViewController : UIViewController

//プロジェクト名を表示するラベル
@property (weak, nonatomic) IBOutlet UILabel *pjNameLabel;

//時間を表示するラベル
@property (weak, nonatomic) IBOutlet UILabel *pjTimeLabel;
//時間コストを表示するラベル
@property (weak, nonatomic) IBOutlet UILabel *TimeCostLabel;

//小さなラベルたち
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;//クライアント名
@property (weak, nonatomic) IBOutlet UILabel *genreLabel;//ジャンル名
@property (weak, nonatomic) IBOutlet UILabel *housyuLabel;//報酬額
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;//合計時間


//ボタンの画像を途中で変更するためにはプロパティの宣言が必要
@property (weak, nonatomic) IBOutlet UIButton *startStopButton;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
