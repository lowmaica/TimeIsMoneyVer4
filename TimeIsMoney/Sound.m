//
//  Sound.m　〜音を制御するためのクラス〜
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import "Sound.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>



@implementation Sound

-(void)soundCoin{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"coin"ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.sound = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
    [self.sound play];
}

-(void)soundRegi{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"register"ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.sound = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
    [self.sound play];
}

-(void)soundAlert{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Time approach"ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.sound = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:NULL];
    [self.sound play];
}

@end