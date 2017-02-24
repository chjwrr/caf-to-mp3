//
//  ViewController.h
//  我的录音测试
//
//  Created by apple on 15/5/23.
//  Copyright (c) 2015年 CHJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController : UIViewController{
    AVAudioRecorder *recorder;
    NSTimer *timer;
    NSURL *playURL;
    
    
}

@property (nonatomic,strong)AVAudioPlayer *avPlayer;
@property (nonatomic,strong)UIImageView *imageView;
@end

