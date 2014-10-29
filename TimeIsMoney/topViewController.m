//
//  topViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "topViewController.h"
#import "CDViewController.h"


@interface topViewController ()
@end


@implementation topViewController{
    AppDelegate *app; //変数管理
    NSArray *array;
    NSString *dvid;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tabBarController.delegate = self;
    dvid = @"time01";
    //端末idを取得するための変数であるがシミュレータを起動するたびにかわるのでコメント
    //dvid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSLog(@"%@",dvid);
    NSString *urlstr = @"http://time.miraiserver.com/alldata.php?id=";
    urlstr = [urlstr stringByAppendingString:dvid];
    array = [self serverdata:urlstr];
    
    NSLog(@"%@",array);
    
//    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[3];
    
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート

    [app sinkouSet]; //配列の準備
    [app finishSet]; //配列の準備
    
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
    
    //終了結果表示から帰ってきた場合終了タブを開く
    if(app.syuryo == 1){
        UIViewController *vc = self.tabBarController.childViewControllers[1];
        [UIView transitionFromView:self.view
                            toView:vc.view
                          duration:1.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:
         ^(BOOL finished) {
             self.tabBarController.selectedViewController = vc;
             app.syuryo = 0;
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (indexPath.section != 0) return; //これがよくわからない
        NSInteger row = indexPath.row; //何番目が押されたかを判別してるっぽい
        
        
        //取り出した文字列で辞書を呼び出す
        NSDictionary *dic = [array objectAtIndex:row];
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

//今のところ機能してないのでデータ消去に利用
- (IBAction)hensyu:(UIButton *)sender {
    //NSUserdefaultの中身を全消去するメソッド
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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
@end