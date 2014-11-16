//
//  topViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "topViewController.h"
//#import "CDViewController.h"


@interface topViewController ()
@end


@implementation topViewController{
    AppDelegate *app; //変数管理
    UIView *loadingView; //更新中のぐるぐる
    UIActivityIndicatorView *indicator; //更新中のぐるぐる
}

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tabBarController.delegate = self;
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    [super viewDidLoad];
//        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];


    
    NSString *urlstr = @"http://timeismoney.miraiserver.com/alldata.php?id=";
    urlstr = [urlstr stringByAppendingString:app.userid];
    self.array = [NSMutableArray array];
    self.array = (NSMutableArray*)[self serverdata:urlstr];
    NSLog(@"%@",app.userid);
    
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


/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
        app.genreName = [NSString stringWithFormat:@"%@", data];
        data = [dic objectForKey:@"projectid"];
        int num = [data intValue];
        app.projectid = num;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        [self performSegueWithIdentifier:@"topToCD" sender:self]; //opToCD Segueを実行
    }
}

-(NSArray*)serverdata:(NSString*)url{
    //URLを生成
    NSURL *dataurl = [NSURL URLWithString:url];
    //リクエスト生成
    NSURLRequest *request = [NSURLRequest requestWithURL:dataurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //レスポンスを生成
    NSHTTPURLResponse *response;
    //NSErrorの初期化
    NSError *err = nil;
    //requestによって返ってきたデータを生成
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //データを元に文字列を生成
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //余計な文字列を削除
    str = [str stringByReplacingOccurrencesOfString:@"<!--/* Miraiserver \"NO ADD\" http://www.miraiserver.com */-->" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"<script type=\"text/javascript\" src=\"http://17787372.ranking.fc2.com/analyze.js\" charset=\"utf-8\"></script>" withString:@""];
    //strをNSData型の変数に変換
    NSData *trimdata = [str dataUsingEncoding:NSUTF8StringEncoding];
    //dataを元にJSONオブジェクトを生成
    NSArray *resarray = [NSJSONSerialization JSONObjectWithData:trimdata options:NSJSONReadingMutableContainers error:&err];
    //値を返す
    return resarray;
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
        //サーバーのデータ送信処理
        NSURL *url = [NSURL URLWithString:@"http://timeismoney.miraiserver.com/delete.php"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        NSMutableData *body = [NSMutableData data];
        NSString *boundary = @"--1680ert52491z";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setHTTPMethod:@"POST"];
        //idのパラメータの設定
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"id\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", app.userid] dataUsingEncoding:NSUTF8StringEncoding]];
        //idのパラメータの設定
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"projectid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *projectidstr = [prodic objectForKey:@"projectid"];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", projectidstr] dataUsingEncoding:NSUTF8StringEncoding]];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
        NSURLResponse *response;
        NSError *err = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *datastring = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"削除は%@",datastring);

        [tableView reloadData];
    }
}

//戻るボタンのためにSegueを設定
- (IBAction)returnTop:(UIStoryboardSegue *)segue {
    NSLog(@"トップに戻る");
    NSString *urlstr = @"http://timeismoney.miraiserver.com/alldata.php?id=";
    urlstr = [urlstr stringByAppendingString:app.userid];
    self.array = [NSMutableArray array];
    self.array = (NSMutableArray*)[self serverdata:urlstr];
    [self.tableView reloadData];
}


//ログアウト関連ここから-----------------------------------
//ログアウトボタン
- (IBAction)btnLogout:(UIButton *)sender {
    //アラート表示
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"ログアウト"
                          message:@"\nログアウトしてID入力画面に戻ります\nよろしいですか？"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

// ログアウトのアラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            //１番目のボタン（キャンセル）が押されたときの処理を記述する
            break;
        case 1:
            //２番目のボタン（OK）が押されたときの処理を記述する
            //NSUserdefaultの中身を全消去する
            [self defaultClear];
            //Segueを実行して画面遷移
            [self performSegueWithIdentifier:@"topToLogin" sender:self];
            break;
    }
}

//時給だけ残してNSUserdefaltの中身を消去するメソッド
-(void)defaultClear{
    //NSUserdefaltの中身を消去
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    //時給をNSUserDefaultで保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *num = [NSNumber numberWithFloat:app.jikyu];
    [defaults setObject:num forKey:@"時給"];
}
//ログアウト関連ここまで-----------------------------------


//更新ボタン
- (IBAction)btnReload:(UIButton *)sender {
    //サーバーからデータを取ってきてテーブルを更新する。失敗した場合はアラートを表示する。
}

@end