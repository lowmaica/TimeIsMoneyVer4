//
//  topViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "topViewController.h"
#import "FMDatabase.h"

@interface topViewController ()
@end


@implementation topViewController{
    AppDelegate *app; //変数管理

    NSArray *paths;
    NSString *dir;
    FMDatabase *db;
    NSString *sql;
}

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tabBarController.delegate = self;
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    // アプリに登録されている全ての通知を削除
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [super viewDidLoad];

    //DBファイルのパス
    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    self.array = [NSMutableArray array];
    
    //DBファイルがあるかどうか確認
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]])
    {
        //なければ新規作成
        NSLog(@"データベースがないので作成");
        db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
        sql = @"CREATE TABLE timeproject (id INTEGER PRIMARY KEY AUTOINCREMENT,project TEXT,houshu float,time int,client TEXT,genre TEXT);";
        
        NSString *sql2 = @"CREATE TABLE exitproject (id INTEGER PRIMARY KEY AUTOINCREMENT,project TEXT,jikyu int,houshu float,time int,client TEXT,genre TEXT);";
        
        [db open]; //DB開く
        [db executeUpdate:sql]; //SQL実行
        [db executeUpdate:sql2]; //SQL実行
        [db close]; //DB閉じる
    }else{
        NSLog(@"すでにデータベースがあるので作成しなかった");
        NSString *db_path  = [dir stringByAppendingPathComponent:@"timeismoney.db"];
        NSLog(@"データベースの場所は…%@", db_path );
        db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
        sql = @"select * from timeproject;";
        [db open]; //DB開く
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            NSString *idstr = [NSString stringWithFormat:@"%d",[results intForColumn:@"id"]];
            NSString *projectstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"project"]];
            NSString *houshustr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"houshu"]];
            NSString *timestr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"time"]];
            NSString *clientstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"client"]];
            NSString *genrestr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"genre"]];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 idstr, @"id",houshustr, @"houshu",clientstr, @"client",projectstr,@"project",timestr,@"time",genrestr,@"genre",nil];
            [self.array addObject:dic];
        }
        [db close]; //DB閉じる
    }

    
    //プロジェクトの変数を初期化する
    app.housyu = 0; //報酬
    app.projectName = nil; //プロジェクト名
    app.genreName = nil; //ジャンル名
    app.clientName = nil; //クライアント名
    app.prjTime = 0; //経過時間
    
    [app jikyuSet]; //時給をセット
    
    //時給が空の場合時給タブを開く
    if(app.jikyu == 0){
        UIViewController *vc = self.tabBarController.childViewControllers[3];
        [UIView transitionFromView:self.view
                            toView:vc.view
                          duration:1.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:
         ^(BOOL finished) {
             self.tabBarController.selectedViewController = vc;
         }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //セルの数を指定
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount;
    dataCount = app.nowProject.count;
    return [self.array count]; //配列の中身の数を数えてローの数を指定する
}


//ここのメソッド何やってるかぜんぜんわからない
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.array[indexPath.row] objectForKey:@"project"];
    return cell;
}


//セルが選択された時
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //時給が未記入の場合警告が出る
    if (app.jikyu == 0) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"エラー"
                              message:@"\n時給タブから時給を登録してください。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    }else{
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (indexPath.section != 0) return; //これがよくわからない
        NSInteger row = indexPath.row; //何番目が押されたかを判別してるっぽい
        
        
        //取り出した文字列で辞書を呼び出す
        NSDictionary *dic = [self.array objectAtIndex:row];
        
        app.projectName = [dic objectForKey:@"project"];
        
        //報酬を代入
        NSString *data = [dic objectForKey:@"houshu"];
        app.housyu = [data integerValue];
        
        //経過時間を代入
        data = [dic objectForKey:@"time"];
        app.prjTime = [data integerValue];
        
        //クライアント名を代入
        data = [dic objectForKey:@"client"];
        app.clientName = [NSString stringWithFormat:@"%@", data];
        
        //ジャンルを代入
        data = [dic objectForKey:@"genre"];
        app.genreName = data;
        
        //プロジェクトのIDを代入
        data = [dic objectForKey:@"id"];
        app.projectid = data;
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        [self performSegueWithIdentifier:@"topToCD" sender:self]; //opToCD Segueを実行
    }
}

//横フリックでプロジェクトを削除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *prodic = [self.array objectAtIndex:indexPath.row];
        NSString *proid = [prodic objectForKey:@"id"];
        [self.array removeObjectAtIndex:indexPath.row];
        sql = [NSString stringWithFormat:@"delete from timeproject where id = %@;",proid];
        
        
        [db open]; //DB開く
        [db executeUpdate:sql]; //SQL実行
        [db close]; //DB閉じる

        [tableView reloadData];
    }
}

//戻るボタンのためにSegueを設定
- (IBAction)returnTop:(UIStoryboardSegue *)segue {
    NSLog(@"トップに戻る");
    self.array = [NSMutableArray array];
    db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
    sql = @"select * from timeproject;";
    [db open]; //DB開く
    FMResultSet *results = [db executeQuery:sql];
    while([results next]) {
        NSString *idstr = [NSString stringWithFormat:@"%d",[results intForColumn:@"id"]];
        NSString *projectstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"project"]];
        NSString *houshustr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"houshu"]];
        NSString *timestr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"time"]];
        NSString *clientstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"client"]];
        NSString *genrestr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"genre"]];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             idstr, @"id",houshustr, @"houshu",clientstr, @"client",projectstr,@"project",timestr,@"time",genrestr,@"genre",nil];
        [self.array addObject:dic];
    }
    [db close]; //DB閉じる
    [self.tableView reloadData];
}

@end