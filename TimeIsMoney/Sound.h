//
//  Sound.h
//  TimeIsMoney
//
//  Created by ビザンコムマック　13 on 2014/10/08.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Sound : NSObject

@property AVAudioPlayer *sound;

-(void)soundCoin; //コインの音
-(void)soundRegi; //レジの音
-(void)soundAlert; //アラート音

@end