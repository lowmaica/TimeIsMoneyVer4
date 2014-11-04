//
//  AppDelegate.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//共通の変数
@property float jikyu;
@property float resjikyu;

//進行中プロジェクトを管理する配列
@property NSMutableArray *nowProject;
@property NSMutableArray *finishProject;

//プロジェクト作成時の変数
@property float housyu; //報酬
@property NSString *projectName; //プロジェクト名
@property NSString *genreName; //ジャンル名
@property NSString *clientName; //クライアント名
@property int projectid;

//プロジェクトの経過時間を数える変数
@property NSInteger prjTime;

////終了タブから戻ってきたかどうかの判定
//@property NSInteger syuryo;


//-(void)sinkouSet;
//-(void)finishSet;
-(void)jikyuSet;

@end
