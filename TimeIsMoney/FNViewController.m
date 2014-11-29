//
//  FNViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "FNViewController.h"
#import "FMDatabase.h"

@interface FNViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end

@implementation FNViewController
{
    Sound *mySound; //音源クラスのインスタンス
    AppDelegate *app; //変数管理
    
//このクラスでしか使われない変数
    NSInteger resultJikyu;
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    NSInteger cost;
    float ichienByousu;
    
    NSArray *paths;
    NSString *dir;
    FMDatabase *db;
    NSString *sql;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mySound = [[Sound alloc]init]; //音源クラスのインスタンス初期化
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    //pjNameResultLabelにプロジェクト名を記入
    self.pjNameLabel.text = [NSString stringWithFormat:@"%@",app.projectName];
    
    //クライアント名、ジャンル名、報酬額をラベルに表示
    self.clientLabel.text = [NSString stringWithFormat:@"クライアント：%@",app.clientName];
    self.genreLabel.text = [NSString stringWithFormat:@"ジャンル：%@",app.genreName];
    NSNumber *num = [NSNumber numberWithFloat:app.housyu];
    self.housyuLabel.text = [NSString stringWithFormat:@"報酬額：%@円",num];
    
    //目標時給と報酬から目標時間を割り出す
    float flt = app.housyu/app.jikyu*60*60;
    NSInteger intNum = flt; //目標時間から小数点を切り捨てるためにint型の変数に代入
    
    //経過時間と目標時間を比較し、目標時間を過ぎていた場合背景を赤くする
    if (app.prjTime > intNum) {
        //iPhone4sの場合はif文の中、違う場合はelseを通る
        if (app.deviceNum == 1) {
            self.backImage.image = [UIImage imageNamed:@"oldFnback02"]; //背景画像を変更する

        }else{
            self.backImage.image = [UIImage imageNamed:@"fnback02"]; //背景画像を変更する
        }
        [self.otuBtn setImage:[UIImage imageNamed:@"btnOtsuRed"] forState:UIControlStateNormal];//ボタンも変更する
        [self.mailBtn setImage:[UIImage imageNamed:@"btnMailRed"] forState:UIControlStateNormal];//ボタンも変更する
    }
    
    //resultTimeLabelにプロジェクト終了までにかかった時間の合計を記入
    hours = app.prjTime/3600;
    minutes = (app.prjTime%3600)/60;
    seconds = (app.prjTime%3600)%60;
    self.resultTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                                 (long)hours,(long)minutes,(long)seconds];


    //resultCostLabelに報酬額から総コストを引いた金額を記入
    ichienByousu = 3600/app.jikyu;//時給から１円あたりの秒数を計算
    flt = app.prjTime/ichienByousu;
    cost = flt;
    cost = app.housyu - cost;
    self.resultCostLabel.text = [NSString stringWithFormat:@"%ld",(long)cost];
    
    //resultJikyuLabelに報酬額をかかった時間で割った「時給」を記入
    resultJikyu = (app.housyu/app.prjTime)*3600;
    if (app.housyu < resultJikyu) {
        resultJikyu = app.housyu;
    }
    self.resultJikyuLabel.text = [NSString stringWithFormat:@"%ld",(long)resultJikyu];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)otuBtn:(UIButton *)sender {
    [mySound soundCoin]; //コインの音

    paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    dir   = [paths objectAtIndex:0];
    
    db= [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"timeismoney.db"]];
    sql = [NSString stringWithFormat:@"insert into exitproject(project,jikyu,houshu,time,client,genre) values('%@',%@,%@,%@,'%@','%@');",app.projectName,[NSString stringWithFormat:@"%ld",(long)resultJikyu],[NSString stringWithFormat:@"%f",app.housyu],[NSString stringWithFormat:@"%ld",(long)app.prjTime],app.clientName,app.genreName];
    
    int s = 0;
    [db open];
    if ( (s = [db executeUpdate:sql]) == 0 ) {
        NSLog(@"失敗した");
    };
    NSLog(@"sの値は%d",s);
    sql = [NSString stringWithFormat:@"delete from timeproject where id = %@;",app.projectid];
    if ( (s = [db executeUpdate:sql]) == 0 ) {
        NSLog(@"失敗した");
    };
    NSLog(@"sの値は%d",s);
    [db close];
}

//メール送信関連ここから-----------------------------------
//メール送信ボタン
- (IBAction)btnSendMail:(UIButton *)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    //件名を設定
    NSString *kenmei = [NSString stringWithFormat:@"%@",app.projectName];
    //本文を設定
    NSNumber *numHousyu = [NSNumber numberWithFloat:app.housyu];
    NSInteger totalHours = app.prjTime/3600;
    NSInteger totalMinutes = (app.prjTime%3600)/60;
    NSInteger totalSeconds = (app.prjTime%3600)%60;
    NSString *totalTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)totalHours,(long)totalMinutes,(long)totalSeconds];
    NSString *mailText = [NSString stringWithFormat:@"報酬額：%@円\nクライアント：%@\nジャンル：%@\n\n合計時間　%@\n時給結果　%ld円", numHousyu,app.clientName,app.genreName,totalTime,(long)resultJikyu];
    
    [controller setSubject:kenmei];
    [controller setMessageBody:mailText isHTML:NO];
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
@end
