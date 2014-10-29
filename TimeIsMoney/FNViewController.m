//
//  FNViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "FNViewController.h"

#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "CommonCrypto/CommonDigest.h"
#import "EvernoteSDK.h"

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
    
    //Evernote用
    NSString *noteText;
    NSString *noteTitle;
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
        self.backImage.image = [UIImage imageNamed:@"fnback02"]; //背景画像を変更する
        [self.otuBtn setImage:[UIImage imageNamed:@"btnOtsuRed"] forState:UIControlStateNormal];//ボタンも変更する
    }
    
    //resultTimeLabelにプロジェクト終了までにかかった時間の合計を記入
    hours = app.prjTime/3600;
    minutes = (app.prjTime%3600)/60;
    seconds = (app.prjTime%3600)%60;
    self.resultTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",hours,minutes,seconds];


    //resultCostLabelに報酬額から総コストを引いた金額を記入
    ichienByousu = 3600/app.jikyu;//時給から１円あたりの秒数を計算
    flt = app.prjTime/ichienByousu;
    cost = flt;
    cost = app.housyu - cost;
    self.resultCostLabel.text = [NSString stringWithFormat:@"%ld",cost];
    
    //resultJikyuLabelに報酬額をかかった時間で割った「時給」を記入
    resultJikyu = (app.housyu/app.prjTime)*3600;
    if (app.housyu < resultJikyu) {
        NSNumber *num = [NSNumber numberWithFloat:app.housyu]; //float型を編集
        self.resultJikyuLabel.text = [NSString stringWithFormat:@"%@",num];
    }else{
        self.resultJikyuLabel.text = [NSString stringWithFormat:@"%ld",resultJikyu];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)otuBtn:(UIButton *)sender {
    //nowProjectから削除してUserDefaltsで保存
    [app.nowProject removeObject:app.projectName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:app.nowProject forKey:@"進行中"];

    //finishProjectに挿入してUserDefaltsで保存
    //終了済プロジェクトの配列の中身が空の場合初期化する
    NSInteger dataCount;
    dataCount = app.finishProject.count;
    if (dataCount == 0) {
        app.finishProject = [[NSMutableArray alloc] init];
    }
    //終了済プロジェクトの配列の最後に保存
    [app.finishProject addObject:app.projectName];
    //userdefaultsで配列を保存
    [defaults setObject:app.finishProject forKey:@"終了済"];
    
    [mySound soundCoin]; //コインの音
    
    //Evernoteにノートを送信
    [self addEvernote];
}


//Evernote用
-(void)addEvernote{
    EvernoteSession* session = [EvernoteSession sharedSession];
    if (session.isAuthenticated == NO) {
        // 未ログインであれば、ログイン処理を行なう
        [session authenticateWithViewController:self completionHandler:^(NSError *error) {
            if (error || !session.isAuthenticated) {
                // ログインエラー処理を記述します（メッセージ表示など）
            } else {
                // ログイン完了
                NSLog(@"Evernoteにログイン完了 noteStoreUrl:%@ webApiUrlPrefix:%@", session.noteStoreUrl, session.webApiUrlPrefix);
                [self addEvernote]; //なんじゃこりゃ？？
            }
        }];
        return;
    }
    // プレーンテキストを得る？？
    //    NSString *note = @"これがノートの中身になるっぽい\n\n何行でもOK？";
    
    [self createNote];
    // プレーンテキストをENML形式に変換する
    NSMutableString* enml = [NSMutableString string];
    [enml setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [enml appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">"];
    [enml appendString:@"<en-note>"];
    NSRange range = NSMakeRange(0, noteText.length); //note→noteText
    NSRange lineRange;
    NSString* lineString;
    while (range.length > 0) {
        
        // 改行コードかあるいは文字列の終端までを読み込み、ENML形式に変換する
        lineRange = [noteText lineRangeForRange:NSMakeRange(range.location, 0)]; //note→noteText
        lineString = [noteText substringWithRange:lineRange]; //note→noteText
        NSLog(@"line: %@", lineString);
        range.location = NSMaxRange(lineRange);
        range.length -= lineRange.length;
        
        
        if ([lineString isEqualToString:@"\n"]) {
            // 改行のみの場合、<br />に変換する
            lineString = @"<br />";
        }
        else{
            // 改行以外の文字が含まれる場合、改行コードを削除する
            lineString = [lineString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        // 文字列の両端に<div> </div>を連結する
        [enml appendFormat:@"<div>%@</div>", lineString];
    }
    [enml appendString:@"</en-note>\n"];
    
    // tag情報の作成（152行目で黄色エラーが出るのでNSArray→NSMutableArrayに変更）（更にクライアント名、ジャンル名がタグになるように改造）
    NSMutableArray* tagList = [NSMutableArray arrayWithObjects: app.clientName, app.genreName ,nil];
    
    // noteオブジェクトの生成
    //autoreleaseというのがエラーの原因
    //    EDAMNoteAttributes *newNoteAttributes = [[[EDAMNoteAttributes alloc] init] autorelease];
    EDAMNoteAttributes *newNoteAttributes = [[EDAMNoteAttributes alloc] init];
    //    EDAMNote *newNote = [[[EDAMNote alloc] init] autorelease];
    EDAMNote *newNote = [[EDAMNote alloc] init];
    //    [newNote setTitle:_template.title];
    [newNote setTitle: noteTitle]; //ノートタイトル（変数に変更）
    [newNote setContent:enml];
    [newNote setTagNames:tagList];
    [newNote setAttributes:newNoteAttributes];
    [newNote setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    
    // noteを追加する
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore createNote:newNote
                  success:^(EDAMNote *note) {
                      // アップロード成功時処理（メッセージ表示など）
                  }
                  failure:^(NSError *error) {
                      // アップロード失敗時処理（メッセージ表示など）
                      NSLog(@"createNote error %@", error);
                  }];
    // アップロードファイルのサイズによっては、ここで「アップロード中」表示を行なった方がよいかもしれません。
}

//Evernote用
-(void)createNote{
    //floatをnumに変更
    NSNumber *numHousyu = [NSNumber numberWithFloat:app.housyu];
    
    //経過時間を時：分：秒に変換
    NSInteger totalHours = app.prjTime/3600;
    NSInteger totalMinutes = (app.prjTime%3600)/60;
    NSInteger totalSeconds = (app.prjTime%3600)%60;
    NSString *totalTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",totalHours,totalMinutes,totalSeconds];
    
    //ノートタイトルとテキストを代入
    noteTitle= app.projectName;
    noteText = [NSString stringWithFormat:@"報酬額：%@円\nクライアント：%@\nジャンル：%@\n\n\n合計時間　%@\n時給結果　%ld円", numHousyu,app.clientName,app.genreName,totalTime,resultJikyu];
}

@end
