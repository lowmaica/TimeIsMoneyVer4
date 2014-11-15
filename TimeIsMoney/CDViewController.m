//
//  CDViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "CDViewController.h"

@interface CDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end

@implementation CDViewController
{
    Sound *mySound; //音源クラスのインスタンス
    AppDelegate *app; //変数管理
    NSTimer *myTimer; //タイマーのインスタンス
    
    BOOL isOver; //設定時間を過ぎたかどうかの判定

    //このクラスでしか使われない変数
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    NSInteger cost;
    float ichienByousu;
    NSInteger targetTime; //報酬と時給から割り出された目標時間
    NSInteger sabun; //時間差分を計算するための変数
    NSDate *start; //開始ボタンを押した時刻
    NSDate *now; //現在の時刻
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mySound = [[Sound alloc]init]; //音源クラスのインスタンス初期化
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
//    //チート用。経過時間を操作。
//    NSInteger i = 4; //時間
//    app.prjTime = i*3600;
//    i = 59; //分
//    app.prjTime = app.prjTime + (i*60);
//    i = 55; //秒
//    app.prjTime = app.prjTime + i;
    
    //目標時給と報酬から目標時間を割り出す
    float flt = app.housyu/app.jikyu*60*60;
    targetTime = flt; //目標時間から小数点を切り捨てるためにint型の変数に代入
    
    //時給から１円あたりの秒数を計算
    ichienByousu = 3600/app.jikyu;
    
    //初期状態のラベル表示
    //プロジェクト時間ラベルの表示と背景の設定
    if (app.prjTime > targetTime) { //もし経過時間が目標時間よりも大きければ
        //背景を赤にする
        [self backchange];
        //超過時間を表示する
        NSInteger num = app.prjTime - targetTime; //目標を超過した時間
        hours = num/3600;
        minutes = (num%3600)/60;
        seconds = (num%3600)%60;
        self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
    }else{  //もし経過時間が目標時間よりも小さければ
        //残り目標時間を表示する
        NSInteger num = targetTime - app.prjTime; //目標までの残り時間
        hours = num/3600;
        minutes = (num%3600)/60;
        seconds = (num%3600)%60;
        self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
    }
    
    //プロジェクト名をラベルに表示
    self.pjNameLabel.text = [NSString stringWithFormat:@"%@",app.projectName];
    
    //クライアント名、ジャンル名、報酬額をラベルに表示
    self.clientLabel.text = [NSString stringWithFormat:@"クライアント：%@",app.clientName];
    self.genreLabel.text = [NSString stringWithFormat:@"ジャンル：%@",app.genreName];
    NSNumber *num = [NSNumber numberWithFloat:app.housyu];
    self.housyuLabel.text = [NSString stringWithFormat:@"報酬額：%@円",num];
    
    //経過時間をラベルに表示
    NSInteger totalHours = app.prjTime/3600;
    NSInteger totalMinutes = (app.prjTime%3600)/60;
    NSInteger totalSeconds = (app.prjTime%3600)%60;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"経過時間：%02ld:%02ld:%02ld",(long)totalHours,(long)totalMinutes,(long)totalSeconds];
    
    //時間コストの初期値を表示
    flt = app.prjTime/ichienByousu;
    cost = flt;
    self.TimeCostLabel.text = [NSString stringWithFormat:@"%ld",(long)cost];
}


//タイマーで1秒ごとに呼ばれるメソッド
-(void)countDown{
    //タイマー開始から現在までの経過時間を変数に格納する
    now = [NSDate date]; //現在時刻を取得
    sabun = [now timeIntervalSinceDate:start]; //差分を取得
    NSInteger tmp = sabun; //「tmp」が開始してから現在までの時間
    
    //経過時間の総計を割り出す
    tmp = tmp + app.prjTime; //「tmp」が経過時間の総計
    
    //コストを計算してラベルに表示
    cost = tmp/ichienByousu;
    self.TimeCostLabel.text = [NSString stringWithFormat:@"%ld",(long)cost];
    
    //経過時間の総計を表示
    hours = tmp/3600;
    minutes = (tmp%3600)/60;
    seconds = (tmp%3600)%60;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"経過時間：%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
    
    //分岐
    if (targetTime > tmp) {    //目標時間が経過時間の総計より大きい場合
        tmp = targetTime - tmp; //「tmp」が目標までの残り時間
        //残り時間を時：分：秒の形で表示する
        hours = tmp/3600;
        minutes = (tmp%3600)/60;
        seconds = (tmp%3600)%60;
        self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
        
    }else if (targetTime == tmp){   //目標時間と経過時間が同じ場合
        self.pjTimeLabel.text = [NSString stringWithFormat:@"00:00:00"];
        //背景を赤にする
        [self backchange];
        //アラート音を鳴らす
        [mySound soundAlert];
        
    }else{  //目標時間が経過時間の総計より小さい場合
        if (!isOver) {
            [self backchange];
        }
        tmp = tmp - targetTime; //「tmp」が目標を超過した時間
        //超過した時間を時：分：秒の形で表示する
        hours = tmp/3600;
        minutes = (tmp%3600)/60;
        seconds = (tmp%3600)%60;
        self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];    }
}


//背景を赤にするメソッド
-(void)backchange{
    //背景を赤にする。iPhone4sの場合はif文の中、違う場合はelseを通る
    if (app.deviceNum == 1){
        self.backImage.image = [UIImage imageNamed:@"oldCdback02"]; //背景画像を変更する。ボタンも変更。
        [self.startStopButton setImage:[UIImage imageNamed:@"btnStartRedOld"] forState:UIControlStateNormal];
        [self.finishBtn setImage:[UIImage imageNamed:@"btnFinishRedOld"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"btnBackWhite"] forState:UIControlStateNormal];
    }else{
        self.backImage.image = [UIImage imageNamed:@"cdback02"]; //背景画像を変更する。ボタンも変更。
        [self.startStopButton setImage:[UIImage imageNamed:@"btnStartRed"] forState:UIControlStateNormal];
        [self.finishBtn setImage:[UIImage imageNamed:@"btnFinishRed"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"btnBackWhite"] forState:UIControlStateNormal];
    }
    isOver = YES;
}


//経過時間を保存するメソッド
-(void)saveTime{
    //差分を経過時間にプラスして差分は0に戻す
    app.prjTime = app.prjTime + sabun;
    sabun = 0;
    
    //サーバーのデータ送信処理
    NSURL *url = [NSURL URLWithString:@"http://timeismoney.miraiserver.com/update.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"--1680ert52491z";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setHTTPMethod:@"POST"];
    //idのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"id\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    NSString *dvid = @"time01";
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", app.userid] dataUsingEncoding:NSUTF8StringEncoding]];
    //projectのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"project\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", app.projectName] dataUsingEncoding:NSUTF8StringEncoding]];
    //timeのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"time\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%ld\r\n",(long)app.prjTime] dataUsingEncoding:NSUTF8StringEncoding]];
    //clientのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"client\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n",app.clientName] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    //houshuのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"houshu\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%f\r\n",app.housyu] dataUsingEncoding:NSUTF8StringEncoding]];
    //janleのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"janle\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n",app.genreName] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    //idのパラメータの設定
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"projectid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *projectidstr = [NSString stringWithFormat:@"%d",app.projectid];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", projectidstr] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSURLResponse *response;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *datastring = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",datastring);
}


- (IBAction)backBtn:(UIButton *)sender {
    //myTimerが動いている場合止める
    if ([myTimer isValid]) {
        [myTimer invalidate];
    }
    [self saveTime]; //経過時間を保存
}

-(void)notification{
    // インスタンス生成
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // ?分後に通知をする（設定は秒単位）
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(targetTime)];
    // タイムゾーンの設定
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 通知時に表示させるメッセージ内容
    notification.alertBody = @"目標時間を過ぎました";
    // 通知に鳴る音の設定
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知の登録
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

//開始／停止ボタンをおした時の動作
- (IBAction)startStopButton:(id)sender {
    if ([myTimer isValid]) { //myTimerが動いている場合止める
        [myTimer invalidate];
        // アプリに登録されている全ての通知を削除
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }else{ //myTimerが動いてない場合動かす
        start = [NSDate date]; //タイマーが動き出した時刻を記録。「start」がタイマーを開始した時間
        //タイマーを動かす
        myTimer = [NSTimer
                   scheduledTimerWithTimeInterval:1
                   target: self
                   selector:@selector(countDown)
                   userInfo:nil
                   repeats:YES];
        //ローカル通知
        [self notification];
    }
    [self saveTime]; //経過時間を保存
    [mySound soundCoin]; //コインの音
}

//終了ボタン
- (IBAction)finishBtn:(UIButton *)sender {
    //もし経過時間が0秒だったらアラートを表示しSegueを実行しないようにする
    [self saveTime]; //経過時間を保存
    [mySound soundRegi]; //レジの音
    
}
@end
