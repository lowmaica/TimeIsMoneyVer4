//
//  AppDelegate.m
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/09/19.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize sbName;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    //以下ストーリーボード分岐のためのコード
//    // StoryBoardの型宣言
//    UIStoryboard *storyboard;
//    // StoryBoardの名称設定用
//    NSString * storyBoardName;
//    // 機種の取得
////    NSString *modelname = [[UIDevice currentDevice] model];
//    
//    // iPadかどうか判断する
////    if ( ![modelname hasPrefix:@"iPad"] ) {
//        // Windowスクリーンのサイズを取得
//        CGRect r = [[UIScreen mainScreen] bounds];
//        // 縦の長さが480の場合、古いiPhoneだと判定
//        if(r.size.height == 480)
//        {
//            self.deviceName = @"iPhone4S";
//            storyBoardName = @"iPhoneOld";
//        }
//        else
//        {
//            storyBoardName = @"Main";
//        }
////    }
////    else
////    {
////        storyBoardName = @"iPoneOld";
////    }
//    
//    sbName = storyBoardName;
//    
//    // StoryBoardのインスタンス化
//    storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
//    
//    // 画面の生成
//    UIViewController *mainViewController = [storyboard instantiateInitialViewController];
//    
//    // ルートウィンドウにひっつける
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = mainViewController;
//    [self.window makeKeyAndVisible];
//    //ここまでストーリーボード分岐のためのコード
    
      return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

//-(void)sinkouSet{
//    //userdefaulから進行中を呼び出してnowProjectに代入する
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSArray *array = [defaults arrayForKey:@"進行中"];
//    self.nowProject = [array mutableCopy];
//}

//-(void)finishSet{
//    //userdefaulから終了済を呼び出してfinishProjectに代入する
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSArray *array = [defaults arrayForKey:@"終了済"];
//    self.finishProject = [array mutableCopy];
//}

-(void)jikyuSet{
    //userdefaulから時給を呼び出してjikyuに代入する
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.jikyu = [defaults floatForKey:@"時給"];    
}

@end
