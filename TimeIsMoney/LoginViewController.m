//
//  LoginViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/11/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()<UITextFieldDelegate>
@end

@implementation LoginViewController{
    AppDelegate *app;
}

- (void)viewDidLoad {
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート
    
    self.idtextfield.delegate = self;
    self.passtextfield.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Userdefaultsから取り出してIDとパスワードを変数に入れる
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    app.id = [defaults stringForKey:@"ID文字列"];
    app.password = [defaults stringForKey:@"パスワード"];
    }

- (void)viewDidAppear:(BOOL)animated
{
    //もしIDとパスワードの中身が空でなければテキストフィールドに表示すると同時にログインする
    if (app.id != nil && app.password != nil) {
        [self.idtextfield setText:app.id];
        [self.idtextfield setText:app.password];
        NSLog(@"IDは%@、パスワードは%@",app.id,app.password);
        
        //サーバーにログインする
        //サーバーのデータ送信処理
        NSString *urlstr = @"http://timeismoney.miraiserver.com/login.php?";
        urlstr =[urlstr stringByAppendingString:[NSString stringWithFormat:@"id=%@&", app.id]];
        urlstr = [urlstr stringByAppendingString:[NSString stringWithFormat:@"pass=%@",app.password]];
        NSDictionary *resdic = [self serverdata:urlstr];
        NSLog(@"%@",resdic);
        if ([[resdic objectForKey:@"result"] isEqualToString:@"1"]) {
            NSLog(@"ログイン成功");
            app = [[UIApplication sharedApplication] delegate];
            app.userid = app.id;
            [self performSegueWithIdentifier:@"loginsegue" sender:self];
        }else{
            //アラートが出る
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"ログインできません"
                                  message:@"\nログインに失敗しました。\nIDとパスワードを入力してログインするかアプリを再起動してください。"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
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

- (IBAction)logincheck:(id)sender {
    //サーバーのデータ送信処理
    NSString *urlstr = @"http://timeismoney.miraiserver.com/login.php?";
    urlstr =[urlstr stringByAppendingString:[NSString stringWithFormat:@"id=%@&", self.idtextfield.text]];
    urlstr = [urlstr stringByAppendingString:[NSString stringWithFormat:@"pass=%@",self.passtextfield.text]];
    NSDictionary *resdic = [self serverdata:urlstr];
    NSLog(@"%@",resdic);
    if ([[resdic objectForKey:@"result"] isEqualToString:@"1"]) {
        NSLog(@"ログイン成功");
        app = [[UIApplication sharedApplication] delegate];
        app.userid = self.idtextfield.text;
        [self performSegueWithIdentifier:@"loginsegue" sender:self];
    }else if ([[resdic objectForKey:@"result"] isEqualToString:@"0"]){
        NSLog(@"ログイン失敗");
        //アラートが出る
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"ログインできません"
                              message:@"\nIDまたはパスワードが違います。\n再入力してください。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];

    }else{
        //アラートが出る
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"ログインできません"
                              message:@"\nサーバーの接続に失敗しました。"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
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

//IDを変数として保存
- (IBAction)idField:(UITextField *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = sender.text;
    app.id = text;
    [defaults setObject:app.id forKey:@"ID文字列"];
}

//パスワードを変数として保存
- (IBAction)passField:(UITextField *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *text = sender.text;
    app.password = text;
    [defaults setObject:app.password forKey:@"パスワード"];
}

//戻るボタンのためにSegueを設定
- (IBAction)returnLogin:(UIStoryboardSegue *)segue {
}

@end
