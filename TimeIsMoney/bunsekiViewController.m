//
//  bunsekiViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/15.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "bunsekiViewController.h"
#import "FMDatabase.h"



@interface bunsekiViewController (){
    NSArray *array;
    UIView *loadingView; //更新中のぐるぐる
    UIActivityIndicatorView *indicator; //更新中のぐるぐる
}

@end

@implementation bunsekiViewController{
    AppDelegate *app; //変数管理
    NSString *mailText;
    NSString *mailJikyu;
    
    NSArray *paths;
    NSString *dir;
    FMDatabase *db;
    NSString *sql;
}


- (void)viewDidLoad {
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    /*

    NSLog(@"%@",app.userid);
    NSString *urlstr = @"http://timeismoney.miraiserver.com/avgjikyu.php?id=";
    urlstr = [urlstr stringByAppendingString:app.userid];
    array = [self serverdata:urlstr];
    NSLog(@"%@",array);
    NSLog(@"配列の数は%ld",(long)[array count]);
     */
    //DBファイルのパス
    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    //DBファイルがあるかどうか確認
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]])
    {
        NSLog(@"すでにデータベースがある");
        NSString *db_path  = [dir stringByAppendingPathComponent:@"timeismoney.db"];
        NSLog(@"データベースの場所は…%@", db_path );
        db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
        sql = @"select avg(jikyu) as jikyuavg from exitproject;";
        [db open]; //DB開く
        FMResultSet *results = [db executeQuery:sql];
        while([results next]){
            //平均時給を表示
            self.jikyulabel.text = [NSString stringWithFormat:@"%d",[results intForColumn:@"jikyuavg"]];
            mailJikyu =self.jikyulabel.text; //メールのために平均時給を保存
        }
        sql = @"select jikyu,project from exitproject order by jikyu desc limit 5;";
        results = [db executeQuery:sql];
        int i = 1;
        //プロジェクトランキング表示
        self.textview.editable = NO;
        self.textview.text = @"【 プロジェクト別 】\n";
        while([results next]){
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"project"]]];
            
            int avg = [results intForColumn:@"jikyu"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        i = 1;
        sql = @"select avg(jikyu) as jikyuavg ,client from exitproject group by client order by jikyuavg desc limit 5;";
        results = [db executeQuery:sql];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 クライアント別 】\n"];
        while([results next]){
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"client"]]];
            
            int avg = [results intForColumn:@"jikyuavg"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        i = 1;
        sql = @"select avg(jikyu) as jikyuavg ,genre from exitproject group by genre order by jikyuavg desc limit 5;";
        results = [db executeQuery:sql];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 ジャンル別 】\n"];
        while([results next]){
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"genre"]]];
            
            int avg = [results intForColumn:@"jikyuavg"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        
        //メール送信用にテキストを変数に入れる
        NSString *hoge = self.textview.text;
        mailText = [NSString stringWithFormat:@"過去の時給の平均：%@円\n\n高額時給ランキング\n%@",mailJikyu,hoge];
        
        [db close]; //DB閉じる
    }
    /*
    if(([array count]>0)){
        NSLog(@"配列は0でない");
        NSString *avgjikyu = [array objectAtIndex:0];
        int avg = [avgjikyu intValue];
        avgjikyu = [NSString stringWithFormat:@"%d",avg];
        self.jikyulabel.text = avgjikyu;
        NSString *mailJikyu =avgjikyu; //メールのために平均時給を保存
        NSLog(@"%@",app.userid);
        urlstr = @"http://timeismoney.miraiserver.com/timeavg.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        avgjikyu = [array objectAtIndex:0];
        avg = [avgjikyu intValue];
        NSLog(@"%@",app.userid);
        self.prolabel.text = @"";
        urlstr = @"http://timeismoney.miraiserver.com/projecttop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        self.textview.editable = NO;
        self.textview.text = @"【 プロジェクト別 】\n";
        array = [self serverdata:urlstr];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"project"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
        }
        urlstr = @"http://timeismoney.miraiserver.com/clienttop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 クライアント別 】\n"];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"client"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
        }
        urlstr = @"http://timeismoney.miraiserver.com/janletop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 ジャンル別 】\n"];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"janle"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            
            //メール送信用にテキストを変数に入れる
            NSString *hoge = self.textview.text;
            mailText = [NSString stringWithFormat:@"過去の時給の平均：%@円\n\n高額時給ランキング\n%@",mailJikyu,hoge];
        }
    }
     */
//    else{
//        //なにもないときにメッセージを出す
//        
//    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            [self performSegueWithIdentifier:@"bunsekiToLogin" sender:self];
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


//メール送信関連ここから-----------------------------------
//メール送信ボタン
- (IBAction)btnSendMail:(UIButton *)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    //件名を設定
    NSString *kenmei = [NSString stringWithFormat:@"Time is Money 分析結果"];
    
    [controller setSubject:kenmei];
    if(([array count]>0)){
        [controller setMessageBody:mailText isHTML:NO];
    }else{
        [controller setMessageBody:@"データがありません。" isHTML:NO];
    }
    [self presentViewController:controller animated:YES completion:nil];
}

//メール画面で操作後に呼ばれるメソッド
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            //送信した場合
            //送信しましたっていうアラート
            [self resultAlert];
            break;
        case MFMailComposeResultCancelled:
            //キャンセルした場合
            break;
        case MFMailComposeResultSaved:
            //保存した場合
            break;
        case MFMailComposeResultFailed:
            //失敗した場合
            //失敗しましたっていうアラート
            [self failedAlert];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//メール送信に成功した場合のアラート
-(void)resultAlert{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"確認"
                          message:@"\nメールを送信しました"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

//メール送信に失敗した場合のアラート
-(void)failedAlert{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"確認"
                          message:@"\n送信に失敗しました"
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}
//メール送信関連ここまで-----------------------------------

//更新ボタン
- (IBAction)btnReload:(UIButton *)sender {
    self.textview.text = @"";
    //DBファイルのパス
    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    //DBファイルがあるかどうか確認
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]])
    {
        NSLog(@"すでにデータベースがある");
        NSString *db_path  = [dir stringByAppendingPathComponent:@"timeismoney.db"];
        NSLog(@"データベースの場所は…%@", db_path );
        db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
        sql = @"select avg(jikyu) as jikyuavg from exitproject;";
        [db open]; //DB開く
        FMResultSet *results = [db executeQuery:sql];
        while([results next]){
            //平均時給を表示
            self.jikyulabel.text = [NSString stringWithFormat:@"%d",[results intForColumn:@"jikyuavg"]];
        }
        sql = @"select jikyu,project from exitproject order by jikyu desc limit 5;";
        results = [db executeQuery:sql];
        int i = 1;
        //プロジェクトランキング表示
        self.textview.editable = NO;
        self.textview.text = @"【 プロジェクト別 】\n";
        while([results next]){
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"project"]]];
            
            int avg = [results intForColumn:@"jikyu"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        i = 1;
        sql = @"select avg(jikyu) as jikyuavg ,client from exitproject group by client order by jikyuavg desc limit 5;";
        results = [db executeQuery:sql];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 クライアント別 】\n"];
        while([results next]){
            NSLog(@"クライアント追加");
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"client"]]];
            
            int avg = [results intForColumn:@"jikyuavg"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        [db close];
        i = 1;
        [db open];
        sql = @"select avg(jikyu) as jikyuavg ,genre from exitproject group by genre order by jikyuavg desc limit 5;";
        results = [db executeQuery:sql];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 ジャンル別 】\n"];
        while([results next]){
            NSLog(@"ジャンル追加");
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i]];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[results stringForColumn:@"genre"]]];
            
            int avg = [results intForColumn:@"jikyuavg"];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            i++;
        }
        
        [db close]; //DB閉じる
    }
//    loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
//    // 雰囲気出すために背景を黒く半透明する
//    loadingView.backgroundColor = [UIColor blackColor];
//    loadingView.alpha = 0.5f;
//    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    // でっかいグルグル
//    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    // 画面の中心に配置
//    [indicator setCenter:CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height / 2)];
//    // 画面に追加
//    [loadingView addSubview:indicator];
//    [self.view addSubview:loadingView];
//    // ぐるぐる開始
//    [indicator startAnimating];
    /*
    //サーバーからデータを取ってきて更新する。失敗した場合はアラートを表示する。
    NSString *urlstr = @"http://timeismoney.miraiserver.com/avgjikyu.php?id=";
    urlstr = [urlstr stringByAppendingString:app.userid];
    array = [self serverdata:urlstr];
    NSLog(@"%@",array);
    NSLog(@"配列の数は%ld",(long)[array count]);
    if(([array count]>0)){
        NSLog(@"配列は0でない");
        NSString *avgjikyu = [array objectAtIndex:0];
        int avg = [avgjikyu intValue];
        avgjikyu = [NSString stringWithFormat:@"%d",avg];
        self.jikyulabel.text = avgjikyu;
        NSString *mailJikyu =avgjikyu; //メールのために平均時給を保存
        NSLog(@"%@",app.userid);
        urlstr = @"http://timeismoney.miraiserver.com/timeavg.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        avgjikyu = [array objectAtIndex:0];
        avg = [avgjikyu intValue];
        NSLog(@"%@",app.userid);
        self.prolabel.text = @"";
        urlstr = @"http://timeismoney.miraiserver.com/projecttop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        self.textview.editable = NO;
        self.textview.text = @"【 プロジェクト別 】\n";
        array = [self serverdata:urlstr];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"project"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
        }
        urlstr = @"http://timeismoney.miraiserver.com/clienttop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 クライアント別 】\n"];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"client"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
        }
        urlstr = @"http://timeismoney.miraiserver.com/janletop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        self.textview.text = [self.textview.text stringByAppendingString:@"\n【 ジャンル別 】\n"];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位：",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"janle"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給%d円\n\n",avg]];
            
            //メール送信用にテキストを変数に入れる
            NSString *hoge = self.textview.text;
            mailText = [NSString stringWithFormat:@"過去の時給の平均：%@円\n\n高額時給ランキング\n%@",mailJikyu,hoge];
            
//            // ぐるぐる停止
//            [indicator stopAnimating];
//            // 画面から除去して黒い半透明を消す
//            [loadingView removeFromSuperview];
        }
    }
     */
}
@end
