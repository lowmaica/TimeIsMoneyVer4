//
//  bunsekiViewController.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/15.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "bunsekiViewController.h"

@interface bunsekiViewController ()

@end

@implementation bunsekiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // UIScrollViewのインスタンス化
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.frame = self.view.bounds;
    
    // スクロールしたときバウンドさせないようにする
    scrollView.bounces = NO;
    
    
    // UIImageViewのインスタンス化
    // サンプルとして画面に収まりきらないサイズ
    CGRect rect = CGRectMake(0, 0, 320, 1600);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    
    // 画像を設定
    imageView.image = [UIImage imageNamed:@"dummy.png"];
    
    // UIScrollViewのインスタンスに画像を貼付ける
    [scrollView addSubview:imageView];
    
    
    // UIScrollViewのコンテンツサイズを画像のサイズに合わせる
    scrollView.contentSize = imageView.bounds.size;
    
    // UIScrollViewのインスタンスをビューに追加
    [self.view addSubview:scrollView];
    
    // 表示されたときスクロールバーを点滅
    [scrollView flashScrollIndicators];
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

@end
