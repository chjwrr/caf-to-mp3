//
//  ViewController.m
//  我的录音测试
//
//  Created by apple on 15/5/23.
//  Copyright (c) 2015年 CHJ. All rights reserved.
//

#import "ViewController.h"

#import "lame.h"

@interface ViewController (){
    NSString *cafpath;
}



@end

@implementation ViewController
@synthesize avPlayer,imageView;
- (void)viewDidLoad {
    [super viewDidLoad];
    playURL=[[NSURL alloc]init];

    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(20, 100, 100, 30);
    [button setTitle:@"录制音频" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(btnUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(btnOutSide:) forControlEvents:UIControlEventTouchDragExit];
    [self.view addSubview:button];

    
    
    UIButton *btn_play=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_play.frame=CGRectMake(self.view.frame.size.width-120, 100, 100, 30);
    [btn_play setTitle:@"播放音频" forState:UIControlStateNormal];
    [btn_play addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_play];
    
    
    imageView=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-75)/2, 200, 75, 111)];
    [self.view addSubview:imageView];
    
    
    [self initRecorder];
}

- (void)initRecorder {
    
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"MyAudioMemo.caf", nil];
    
    
    
    
    cafpath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    cafpath=[cafpath stringByAppendingString:@"/MyAudioMemo.caf"];
    NSLog(@"cafpath   %@",cafpath);
    
    
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];

    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [session requestRecordPermission:^(BOOL available) {
            
            if (available) {
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”选项中允许xx访问你的麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    return ;
                });
            }
        }];
        
    }
    //录音设置
    
    NSMutableDictionary *recordSetting=[[NSMutableDictionary alloc]init];
    //设置录音格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //设置录音通道  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //现行采样位数 8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    
    
    playURL=outputFileURL;
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

//按下开始录音
- (void)btnDown:(UIButton *)btn {
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        [recorder record];
    }
    
    timer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}
//抬起录音完成
- (void)btnUpInside:(UIButton *)btn {
    double Ctime=recorder.currentTime;
    if (Ctime > .5) {
        NSLog(@"发送");
    }else{
        //删除记录的文件
        [recorder deleteRecording];
        //删除储存的文件
        
        
        
        
    }
    
    [recorder stop];
    [timer invalidate];
    self.imageView.hidden=YES;
}
//移出取消录音
- (void)btnOutSide:(UIButton *)btn {
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    
    NSLog(@"取消发送");

}
//按下播放录音
- (void)playAction:(UIButton *)btn {
    if (self.avPlayer.playing) {
        [self.avPlayer stop];
        return;
    }
    
    NSLog(@"playURL  %@",playURL);
    
    AVAudioPlayer *player=[[AVAudioPlayer alloc]initWithContentsOfURL:playURL error:nil];
    self.avPlayer = player;
    [self.avPlayer play];
    
    [self audio_PCMtoMP3];
}


- (void)detectionVoice
{
    self.imageView.hidden=NO;
    [recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}



/**
 caf转MP3
 */
- (void)audio_PCMtoMP3 {
    
     NSString *_mp3FilePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _mp3FilePath=[_mp3FilePath stringByAppendingString:@"/MyAudioMemoMP3.mp3"];
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([cafpath cStringUsingEncoding:4], "rb");  //source 被转换的音频文件位置
        
        if(pcm == NULL)
            
        {
            
            NSLog(@"file not found");
            
            return;
        }
        
        
        
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        
        FILE *mp3 = fopen([_mp3FilePath cStringUsingEncoding:4], "wb");  //output 输出生成的Mp3文件位置
        
        
        
        const int PCM_SIZE = 8192;
        
        const int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE*2];
        
        unsigned char mp3_buffer[MP3_SIZE];
        
        
        
        lame_t lame = lame_init();
        
        lame_set_num_channels(lame,1);//设置1为单通道，默认为2双通道
        
        lame_set_in_samplerate(lame, 8000.0);//11025.0
        
        //lame_set_VBR(lame, vbr_default);
        
        lame_set_brate(lame,8);
        
        lame_set_mode(lame,3);
        
        lame_set_quality(lame,2); /* 2=high 5 = medium 7=low 音质*/
        
        lame_init_params(lame);
        
        
        
        do {
            
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
            else
                
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            
            
            fwrite(mp3_buffer, write, 1, mp3);
            
            
            
        } while (read != 0);
        
        
        
        lame_close(lame);
        
        fclose(mp3);
        
        fclose(pcm);
        
        
    }
    
    
    
    
    @catch (NSException *exception) {
        
        NSLog(@"%@",[exception description]);
        
        
    }
    
    @finally {
        
        NSLog(@"执行完成");
        
    }
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
