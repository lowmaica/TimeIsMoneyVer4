//
//  finishTableViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/12.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "finishTableViewController.h"
#import "AppDelegate.h"

@interface finishTableViewController ()

@end

@implementation finishTableViewController{
    AppDelegate *app; //変数管理
    NSArray *array;
}

- (void)viewDidLoad {
    NSString *dvid = @"time01";
    NSString *urlstr = @"http://time.miraiserver.com/exitalldata.php?id=";
    urlstr = [urlstr stringByAppendingString:dvid];
    array = [self serverdata:urlstr];
    NSLog(@"%@",array);
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
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
    dataCount = app.finishProject.count;
    return [array count]; //配列の中身の数を数えてローの数を指定する
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
    cell.textLabel.text = [array[indexPath.row] objectForKey:@"project"];
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
        NSDictionary *dic = [array objectAtIndex:row];
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
        data = [dic objectForKey:@"projectid"];
        int num = [data intValue];
        app.projectid = num;
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
        [self performSegueWithIdentifier:@"finishToResult" sender:self]; //Segueを実行
    }
}

//サーバーからデータを取ってきてる？値を返すってのはどこに？
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

//横フリックでプロジェクトを削除できるようにしたい
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 削除するコードを挿入します
    }
}

//戻るボタンのためにSegueを設定
- (IBAction)returnFinish:(UIStoryboardSegue *)segue {
}

@end
