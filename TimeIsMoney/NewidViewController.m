//
//  NewidViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/11/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "NewidViewController.h"
#import "AppDelegate.h"

@interface NewidViewController ()<UITextFieldDelegate>{
    AppDelegate *app;
}

@end

@implementation NewidViewController

- (void)viewDidLoad {
    self.idtextfield.delegate = self;
    self.passtextfield.delegate = self;
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

- (IBAction)newid:(id)sender {
    //サーバーのデータ送信処理
    NSString *urlstr = @"http://time.miraiserver.com/newid.php?";
    urlstr =[urlstr stringByAppendingString:[NSString stringWithFormat:@"id=%@&", self.idtextfield.text]];
    urlstr = [urlstr stringByAppendingString:[NSString stringWithFormat:@"pass=%@",self.passtextfield.text]];
    NSDictionary *resdic = [self serverdata:urlstr];
    NSLog(@"%@",resdic);
    if ([[resdic objectForKey:@"result"] isEqualToString:@"1"]) {
        NSLog(@"新規登録成功");
        app = [[UIApplication sharedApplication] delegate];
        app.userid = self.idtextfield.text;
        [self performSegueWithIdentifier:@"newidsegue" sender:self];
    }else{
        NSLog(@"同じIDがある");
    }
}

//キーボードのリターンキーを押したときに呼ばれるメソッド
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //編集しているテキストフィールドがIDを入力するテキストフィールドであるか
    if (textField == self.idtextfield) {
        [self.idtextfield resignFirstResponder];
    }
    //編集しているテキストフィールドがパスワードを入力するテキストフィールドであるか
    else if (textField == self.passtextfield){
        [self.passtextfield resignFirstResponder];
    }
    return YES;
}

//画面をタップしたときに呼ばれるメソッド
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //キーボードを閉じる
    [self.idtextfield resignFirstResponder];
    [self.passtextfield resignFirstResponder];
}

//サーバーからデータを取ってきてる？値を返すってのはどこに？
-(NSDictionary*)serverdata:(NSString*)url{
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
    NSDictionary *resdic = [NSJSONSerialization JSONObjectWithData:trimdata options:NSJSONReadingMutableContainers error:&err];
    //値を返す
    return resdic;
}

@end
