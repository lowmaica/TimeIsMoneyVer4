//
//  NPViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "NPViewController.h"
#import "FMDatabase.h"


@interface NPViewController ()
@end

@implementation NPViewController
{
    Sound *mySound; //音源のインスタンス
    AppDelegate *app; //変数管理
    
    NSArray *paths;
    NSString *dir;
    FMDatabase *db;
    NSString *sql;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    mySound = [[Sound alloc]init]; //音源のインスタンス初期化
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    //プロジェクト名、ジャンル名、クライアント名を初期化
    app.projectName = nil;
    app.genreName = nil;
    app.clientName = nil;
    
    //背景クリックでソフトウェアキーボードを消す
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

//ソフトウェアキーボードを消すためのメソッド
- (void)closeSoftKeyboard {
    [self.view endEditing: YES];
}

//入力内容を保存するためのメソッド
-(void)save{
    //進行中プロジェクトの配列の中身が空の場合初期化する
    NSInteger dataCount;
    dataCount = app.nowProject.count;
    if (dataCount == 0) {
        app.nowProject = [[NSMutableArray alloc] init];
    }
    if([app.clientName length] == 0){
        app.clientName = @"その他のクライアント";
    }
    if([app.genreName length]== 0){
        app.genreName = @"その他のジャンル";
    }

    //DBファイルのパス
    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    
    db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
    sql = [NSString stringWithFormat:@"insert into timeproject(project,houshu,time,client,genre) values('%@',%@,0,'%@','%@');",app.projectName,[NSString stringWithFormat:@"%f",app.housyu],app.clientName,app.genreName];
    
    int s = 0;
    [db open];
    if ( (s = [db executeUpdate:sql]) == 0 ) {
        NSLog(@"失敗した");
    };
    NSLog(@"sの値は%d",s);
    [db close];
}

//OKボタン
- (IBAction)okBtn:(UIButton *)sender {
    //プロジェクト名、クライアント名、ジャンル名、報酬額を変数に代入
    app.projectName = self.projectNameField.text;
    app.clientName = self.clientNameField.text;
    app.genreName = self.genleNameField.text;
    app.housyu = self.housyuField.text.integerValue;

    
    //プロジェクト名未記入の場合警告が出る
    if([app.projectName length] == 0){
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"登録できません"
                              message:@"\nプロジェクト名を入力してください。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];

        
    //報酬未記入の場合警告が出る
    }else if(app.housyu == 0){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"登録できません"
                              message:@"\n報酬額を入力してください。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }else{
        [self save]; //変数を保存
        [mySound soundCoin]; //音を鳴らす
        [self performSegueWithIdentifier:@"NPtoTop" sender:self]; //NPtoTop Segueを実行
    }
}
@end