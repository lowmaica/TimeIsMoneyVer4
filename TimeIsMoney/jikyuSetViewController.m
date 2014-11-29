//
//  jikyuSetViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/09.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "jikyuSetViewController.h"
#import "AppDelegate.h"
#import "Sound.h"

@interface jikyuSetViewController ()

@end

@implementation jikyuSetViewController
{
    Sound *mySound; //音源のインスタンス
    AppDelegate *app; //変数管理
    
    //このクラスでしか使わない変数
    NSInteger gekkyu;
    NSInteger workTime;
    NSInteger weekHoliday;
    //計算に使う変数
    NSInteger workDays;
    NSInteger totalWorkTime;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    mySound = [[Sound alloc]init]; //音源のインスタンス初期化
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    //時給を変数に入れる
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    app.jikyu = [defaults floatForKey:@"時給"];
    
    //背景クリックでソフトウェアキーボードを消す
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    //もしjikyuの中身が空でなければテキストフィールドにjikyuの中身を表示
    if (app.jikyu != 0) {
        NSNumber *num = [NSNumber numberWithFloat:app.jikyu]; //NSNumber型に変換
        [self.jikyuhyouji setText: [NSString stringWithFormat:@"%@",num]];
    }
    
    //それぞれの変数に0を代入（計算ボタンを押すと落ちてしまうため）
    gekkyu = 0;
    workTime = 0;
    weekHoliday = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeSoftKeyboard {
    [self.view endEditing: YES];
}

//計算するボタンを押す
- (IBAction)keisanButton {
    //フィールドから入力内容を取り出す
    gekkyu = self.gekkyuField.text.integerValue;
    workTime = self.worktimeField.text.integerValue;
    weekHoliday = self.weekholidayField.text.integerValue;
    

    if ((workTime > 24) ||(workTime == 0)||(weekHoliday > 6)||(gekkyu == 0)) {
        //アラートを出す。労働時間が24時間を超えた場合、労働時間が0時間の場合、週休6日以上の場合、月給が0の場合
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"計算できません"
                              message:@"\n必要項目が記入されていないか計算出来ない数字が入力されています。数字を入力しなおしてください。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];

    }else{
        //週休から月の勤務日数を割り出す
        workDays = ((7-weekHoliday)*4)+2;
        if (weekHoliday>3) {
            workDays--;
        }
        
        //勤務日数に労働時間をかけて一ヶ月の労働時間を割り出す
        totalWorkTime = workDays*workTime;
        //月給を総労働時間で割って時給を算出する
        app.jikyu = gekkyu/totalWorkTime;
        
        //目標時給をラベルに表示する
        NSNumber *num = [NSNumber numberWithFloat:app.jikyu]; //NSNumber型に変換
        [self.jikyuhyouji setText: [NSString stringWithFormat:@"%@",num]];
        
        //この時点で時給を保存してしまう
        //jikyufieldを読み込み
        app.jikyu = self.jikyuhyouji.text.integerValue;
        //時給をNSUserDefaultで保存
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *num1 = [NSNumber numberWithFloat:app.jikyu];
        [defaults setObject:num1 forKey:@"時給"];
        
        [self closeSoftKeyboard];//ソフトウェアキーボードを閉じる
        [mySound soundCoin]; //コインの音
    }

}

- (IBAction)okBtn:(UIButton *)sender {
    //jikyufieldを読み込み
    app.jikyu = self.jikyuhyouji.text.integerValue;

    //時給をNSUserDefaultで保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithFloat:app.jikyu];
    [defaults setObject:num forKey:@"時給"];
    
    [mySound soundCoin]; //コインの音
}

@end
