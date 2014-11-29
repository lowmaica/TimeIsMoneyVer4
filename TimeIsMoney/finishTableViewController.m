//
//  finishTableViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/12.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "finishTableViewController.h"
#import "AppDelegate.h"
#import "FMDatabase.h"

@interface finishTableViewController ()

@end

@implementation finishTableViewController{
    AppDelegate *app; //変数管理
    NSMutableArray *array;

    NSArray *paths;
    NSString *dir;
    FMDatabase *db;
    NSString *sql;
}
@synthesize array;

- (void)viewDidLoad {
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート

    //DBファイルのパス
    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    self.array = [NSMutableArray array];
    //DBファイルがあるかどうか確認
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]])
    {
        NSLog(@"すでにデータベースがある");
        NSString *db_path  = [dir stringByAppendingPathComponent:@"timeismoney.db"];
        NSLog(@"データベースの場所は…%@", db_path );
        db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
        sql = @"select * from exitproject;";
        [db open]; //DB開く
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            NSString *idstr = [NSString stringWithFormat:@"%d",[results intForColumn:@"id"]];
            NSString *projectstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"project"]];
            NSString *houshustr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"houshu"]];
            NSString *timestr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"time"]];
            NSString *clientstr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"client"]];
            NSString *genrestr = [NSString stringWithFormat:@"%@",[results  stringForColumn:@"genre"]];
            NSString *jikyustr = [NSString stringWithFormat:@"%d",[results  intForColumn:@"jikyu"]];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 idstr, @"id",houshustr, @"houshu",clientstr, @"client",projectstr,@"project",timestr,@"time",genrestr,@"genre",jikyustr,@"jikyu",nil];
            [self.array addObject:dic];
        }
        [db close]; //DB閉じる
    }

    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //プロジェクトの変数を初期化する
    app.housyu = 0; //報酬
    app.projectName = nil; //プロジェクト名
    app.genreName = nil; //ジャンル名
    app.clientName = nil; //クライアント名
    app.prjTime = 0; //経過時間
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
    dataCount = app.finishProject.count;
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
        
        if ( indexPath.section != 0) return; //これがよくわからない
        NSInteger row = indexPath.row; //何番目が押されたかを判別してるっぽい
        //取り出した文字列で辞書を呼び出す
        NSDictionary *dic = [self.array objectAtIndex:row];
        app.projectName = [dic objectForKey:@"project"];
        
        //報酬を代入
        NSString *data = [dic objectForKey:@"jikyu"];
        app.resjikyu = [data floatValue];
        
        //経過時間を代入
        data = [dic objectForKey:@"time"];
        app.prjTime = [data integerValue];
        
        //クライアント名を代入
        data = [dic objectForKey:@"client"];
        app.clientName = [NSString stringWithFormat:@"%@", data];
        
        //ジャンルを代入
        data = [dic objectForKey:@"genre"];
        app.genreName = [NSString stringWithFormat:@"%@", data];
        //プロジェクトIDを代入
        data = [dic objectForKey:@"id"];
        app.projectid = data;
        NSString *houshustr = [dic objectForKey:@"houshu"];
        app.housyu = [houshustr floatValue];
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        [self performSegueWithIdentifier:@"finishToResult" sender:self]; //Segueを実行
    }
}


//横フリックでプロジェクトを削除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 削除するコードを挿入します
        NSLog(@"%ld行目削除",(long)indexPath.row);
        NSDictionary *prodic = [self.array objectAtIndex:indexPath.row];
        [self.array removeObjectAtIndex:indexPath.row];
        
        NSString *proid = [prodic objectForKey:@"id"];
        sql = [NSString stringWithFormat:@"delete from exitproject where id = %@;",proid];
        
        [db open]; //DB開く
        [db executeUpdate:sql]; //SQL実行
        [db close]; //DB閉じる

        [tableView reloadData];
    }
}


//戻るボタンのためにSegueを設定
- (IBAction)returnFinish:(UIStoryboardSegue *)segue {
}

@end
