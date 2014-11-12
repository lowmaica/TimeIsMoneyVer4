//
//  bunsekiViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/15.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "bunsekiViewController.h"

@interface bunsekiViewController (){
    NSArray *array;
}

@end

@implementation bunsekiViewController{
    AppDelegate *app; //変数管理
}

- (void)viewDidLoad {
    app = [[UIApplication sharedApplication] delegate]; //変数管理のデリゲート

//    NSString *dvid = @"time01";
    //端末idを取得するための変数であるがシミュレータを起動するたびにかわるのでコメント
    //dvid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSLog(@"%@",app.userid);
    NSString *urlstr = @"http://timeismoney.miraiserver.com/avgjikyu.php?id=";
    urlstr = [urlstr stringByAppendingString:app.userid];
    array = [self serverdata:urlstr];
    NSLog(@"%@",array);
    NSLog(@"配列の数は%ld",[array count]);
    if(([array count]>0)){
        NSLog(@"配列は0でない");
        NSString *avgjikyu = [array objectAtIndex:0];
        int avg = [avgjikyu intValue];
        avgjikyu = [NSString stringWithFormat:@"%d円",avg];
        self.jikyulabel.text = avgjikyu;
        NSLog(@"%@",app.userid);
        urlstr = @"http://timeismoney.miraiserver.com/timeavg.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        array = [self serverdata:urlstr];
        avgjikyu = [array objectAtIndex:0];
        avg = [avgjikyu intValue];
        int hour = avg / 3600;
        int min = (avg - 3600 * hour) / 60;
        int sec = (avg - 3600 * hour - min * 60);
        self.timelabel.text = [NSString stringWithFormat:@"%d時間%d分%d秒",hour,min,sec];
        NSLog(@"%@",app.userid);
        self.prolabel.text = @"";
        urlstr = @"http://timeismoney.miraiserver.com/projecttop.php?id=";
        urlstr = [urlstr stringByAppendingString:app.userid];
        self.textview.editable = NO;
        self.textview.text = @"プロジェクトランキング";
        array = [self serverdata:urlstr];
        for (int i = 0; i < [array count]; i++) {
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%d位\n",i+1]];
            NSDictionary *dic = [array objectAtIndex:i];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"%@\n",[dic objectForKey:@"project"]]];
            NSString *jikyustr = [dic objectForKey:@"jikyuavg"];
            avg = [jikyustr intValue];
            self.textview.text = [self.textview.text stringByAppendingString:[NSString stringWithFormat:@"時給:%d円\n",avg]];
            
            
        }
        
    }
    else{
        //なにもないときにメッセージ
        
    }
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


@end
