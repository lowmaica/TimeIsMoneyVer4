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


//時給を入力した時の動作 入力がすぐに反映されるのはなおした方がいいかも
- (IBAction)jikyuLabel:(UITextField *)sender {
    NSString *text = sender.text;
    app.jikyu = text.integerValue;
//    NSLog(@"イチ 時給を%fに変更",app.jikyu);
    
//    //時給をNSUserDefaultで保存
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSNumber *num = [NSNumber numberWithFloat:app.jikyu];
//    [defaults setObject:num forKey:@"時給"];
//    NSLog(@"ニ 時給を%fに変更",app.jikyu);
}


//月給を入力した時の動作
- (IBAction)monthlySalaryText:(UITextField *)sender {
    NSString *text = sender.text;
    gekkyu = text.integerValue;
}

//労働時間を入力した時の動作
- (IBAction)workTime:(UITextField *)sender {
    NSString *text = sender.text;
    workTime = text.integerValue;
}

//週休を入力した時の動作
- (IBAction)weekHoliday:(UITextField *)sender {
    NSString *text = sender.text;
    weekHoliday = text.integerValue;
}


//計算するボタンを押す
- (IBAction)keisanButton {
    //!!!ToDo!!! 多すぎる数字を入力した時にエラーが出るようにする。（ポップアップが理想）
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
    
    [self closeSoftKeyboard];//ソフトウェアキーボードを閉じる
    [mySound soundCoin]; //コインの音

}

- (IBAction)okBtn:(UIButton *)sender {
    //時給をNSUserDefaultで保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithFloat:app.jikyu];
    [defaults setObject:num forKey:@"時給"];
    
    [mySound soundCoin]; //コインの音
}

@end
