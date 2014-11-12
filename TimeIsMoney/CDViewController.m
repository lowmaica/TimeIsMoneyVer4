//
//  CDViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//
//http://time.miraiserver.com/clienttop.php?id=time01これでクライアントのトップ5の時給が知れる
//http://time.miraiserver.com/avgjikyu.php?id=time01 これで平均の時給がしれる
//http://time.miraiserver.com/timeavg.php?id=time01 これで平均の時間が知れる
//http://time.miraiserver.com/projecttop.php?id=time01 これでプロジェクトのトップ5が知れる
//http://time.miraiserver.com/janletop.php?id=time01 これでジャンルのトップ5が知れる

#import "CDViewController.h"

@interface CDViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end

@implementation CDViewController
{
    Sound *mySound; //音源クラスのインスタンス
    AppDelegate *app; //変数管理
    NSTimer *myTimer; //タイマーのインスタンス
    NSTimer *costTimer; //コスト表示用のタイマー
    
    //このクラスでしか使われない変数
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    BOOL isOver; //設定時間を過ぎたかどうかの判定、YESならマイナスカウントを始める
    NSInteger cost;
    float ichienByousu;
    int keika;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mySound = [[Sound alloc]init]; //音源クラスのインスタンス初期化
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    //チート用!!経過時間を操作。
//    NSInteger i = 4; //時間
//    app.prjTime = i*3600;
//    i = 35; //分
//    app.prjTime = app.prjTime + (i*60);
//    i = 26; //秒
//    app.prjTime = app.prjTime + i;
    
    
    //プロジェクト名をラベルに表示
    self.pjNameLabel.text = [NSString stringWithFormat:@"%@",app.projectName];
    
    //クライアント名、ジャンル名、報酬額をラベルに表示
    self.clientLabel.text = [NSString stringWithFormat:@"クライアント：%@",app.clientName];
    self.genreLabel.text = [NSString stringWithFormat:@"ジャンル：%@",app.genreName];
    NSNumber *num = [NSNumber numberWithFloat:app.housyu];
    self.housyuLabel.text = [NSString stringWithFormat:@"報酬額：%@円",num];
    
    //経過時間をラベルに表示
    [self writeTotalTimeLabel];

    
    //目標時給と報酬から目標時間を割り出す
    float flt = app.housyu/app.jikyu*60*60;
    NSInteger intNum = flt; //目標時間から小数点を切り捨てるためにint型の変数に代入
    NSLog(@"%ld",app.prjTime);
    
    //目標時間から経過時間を引いて残り時間を割り出す
    intNum = intNum - app.prjTime;
    
    if (intNum >= 0) {
        //もし残り時間が0以上の場合、時、分、秒に数字を代入。ラベルにそれを表示
        hours = intNum/3600;
        minutes = (intNum%3600)/60;
        seconds = (intNum%3600)%60;
        [self writePjTimeLabel];
    }else{
        //isOverをYESにして、時、分、秒に数字を代入。ラベルにそれを表示
        isOver = YES;
        intNum = -1*intNum;
        hours = intNum/3600;
        minutes = (intNum%3600)/60;
        seconds = (intNum%3600)%60;
        [self writePjTimeLabel];
        self.backImage.image = [UIImage imageNamed:@"cdback02"]; //背景画像を変更する。ボタンも変更。
        [self.startStopButton setImage:[UIImage imageNamed:@"btnStartRed"] forState:UIControlStateNormal];
        [self.finishBtn setImage:[UIImage imageNamed:@"btnFinishRed"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"btnBackWhite"] forState:UIControlStateNormal];
    }
    
    
    //時給から１円あたりの秒数を計算
    ichienByousu = 3600/app.jikyu;
    //    NSLog(@"１円稼ぐのにかかる秒数は%f秒",ichienByousu);
    
    //時間コストの初期値を表示
    flt = app.prjTime/ichienByousu;
    cost = flt;
    self.TimeCostLabel.text = [NSString stringWithFormat:@"%ld",(long)cost];
    
    //経過時間が0の場合終了ボタンを隠す
//    if (app.prjTime == 0) {
//        self.finishBtn.hidden = YES;
//    }
}

//~~~~~~~~~~~~~~~~~~~~~ここからタイマーカウント~~~~~~~~~~~~~~~~~~~~~
//タイマーでcountDownメソッドを１秒ごとに繰り返し呼ぶ
-(void)countTimer{
    myTimer = [NSTimer
               scheduledTimerWithTimeInterval:1
               target: self
               selector:@selector(countDown)
               userInfo:nil
               repeats:YES];
}

//タイマーで呼ばれるcountDownメソッド
-(void)countDown{
    app.prjTime++; //経過時間を足していく
    NSLog(@"%ld",(long)app.prjTime);
    //まだ00:00:00になってなかったら…
    if (!isOver) {
        if(seconds>0){
            seconds--;
            self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
        }else if(minutes != 0 && seconds == 0){
            //分が0ではない状態で秒が0になったら、分から1引いて秒を59にする（0秒と60秒は同じなので59秒からカウントダウン）
            minutes--;
            seconds=59;
            [self writePjTimeLabel];
        }
        //分と秒が0だが、時が0ではない場合、時から1引いて分と秒を59にする。
        else if(hours != 0 && minutes == 0 && seconds == 0){
            hours--;
            minutes = 59;
            seconds = 59;
            [self writePjTimeLabel];
        }
        //時、分、秒すべて0になったらisOverをYESにする
        else if(hours == 0 && minutes == 0 && seconds == 0){
            isOver = YES;
            [self akajiCount];
            //ついでにアラート音を鳴らす
            [mySound soundAlert];  //アラート音
            //ついでにボタンを変える
            [self.startStopButton setImage:[UIImage imageNamed:@"btnStartRed"] forState:UIControlStateNormal];
            [self.finishBtn setImage:[UIImage imageNamed:@"btnFinishRed"] forState:UIControlStateNormal];
            [self.backBtn setImage:[UIImage imageNamed:@"btnBackWhite"] forState:UIControlStateNormal];
        }
    }
    else{
        //カウントダウンが終わった場合マイナスカウントメソッドを実行
        [self akajiCount];
    }
    [self writeTotalTimeLabel];//経過時間を計算して表示する
}

//countDownメソッドで使うprojectTimeLabelに残り時間を表示するためのメソッド
-(void)writePjTimeLabel{
    self.pjTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
}

//経過時間を計算して表示するメソッド（countDownとViewDidLoadに使った）
-(void)writeTotalTimeLabel{
    NSInteger totalHours = app.prjTime/3600;
    NSInteger totalMinutes = (app.prjTime%3600)/60;
    NSInteger totalSeconds = (app.prjTime%3600)%60;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"経過時間：%02ld:%02ld:%02ld",(long)totalHours,(long)totalMinutes,(long)totalSeconds];
}

//赤字に陥った後のカウントアップメソッド
-(void)akajiCount{
    //背景を赤にするメソッド
    //    self.view.backgroundColor = [UIColor redColor];
    //    self.pjStatusLabel.text = [NSString stringWithFormat:@"目標時間をオーバーしています"];
    self.backImage.image = [UIImage imageNamed:@"cdback02"]; //背景画像を変更する
    //カウントアップをしていくメソッド
    //分と秒が59だったら時に1を足して分と秒を0に戻す.
    if (minutes == 59 && seconds == 59) {
        hours++;
        minutes = 0;
        seconds =0;
        [self writePjTimeLabel];
        app.prjTime++; //経過時間を足していく
        //秒が59だったら分に1を足して秒を0に戻す.
    }else if (seconds == 59) {
        minutes++;
        seconds = 0;
        [self writePjTimeLabel];
        seconds++;
        //秒に1ずつ足していく
    }else{
        seconds++;
        [self writePjTimeLabel];
    }
}
//~~~~~~~~~~~~~~~~~~~~~タイマーカウントここまで~~~~~~~~~~~~~~~~~~~~~

//~~~~~~~~~~~~~~~~~~~~~ここからコストカウント~~~~~~~~~~~~~~~~~~~~~
//コストを表示するタイマー
-(void)costTimer{
    costTimer = [NSTimer
                 scheduledTimerWithTimeInterval:ichienByousu
                 target: self
                 selector:@selector(witeCostLabel)
                 userInfo:nil
                 repeats:YES];
}

//コストラベルの更新をするメソッド
-(void)witeCostLabel{
    cost++;
    self.TimeCostLabel.text = [NSString stringWithFormat:@"%ld",(long)cost];
}
//~~~~~~~~~~~~~~~~~~~~~コストカウントここまで~~~~~~~~~~~~~~~~~~~~~

//経過時間を保存するメソッド
-(void)saveTime{
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [defaults dictionaryForKey:app.projectName];
    NSNumber *num = [NSNumber numberWithFloat:app.prjTime];
    [dic setValue: num  forKey: @"経過時間"];
    [defaults setObject:dic forKey: app.projectName];
     */
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
        [costTimer invalidate];
    }
    [self saveTime]; //経過時間を保存
}

//開始／停止ボタンをおした時の動作
- (IBAction)startStopButton:(id)sender {
    //myTimerが動いている場合止めて、終了ボタンを表示
    if ([myTimer isValid]) {
        [myTimer invalidate];
        [costTimer invalidate];
        self.finishBtn.hidden = NO;
    }else{
        //myTimerが動いてない場合動かす（timerメソッド）。
        [self countTimer];
        [self costTimer];
    }
    [self saveTime]; //経過時間を保存
    [mySound soundCoin]; //コインの音
}

//終了ボタン
- (IBAction)finishBtn:(UIButton *)sender {
    [self saveTime]; //経過時間を保存
    [mySound soundRegi]; //レジの音
}
@end
