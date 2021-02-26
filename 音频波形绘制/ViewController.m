//
//  ViewController.m
//  音频波形绘制
//
//  Created by 石川 on 2019/12/24.
//  Copyright © 2019 石川. All rights reserved.
//
#import <stdlib.h>
#import "ViewController.h"
#import "SeeAudio.h"
#import "SCPlayer.h"
#define screenW ([UIScreen mainScreen].bounds.size.width)
#import "AudioToWav.h"
#import "PcmAddWavHeader.h"

@interface ViewController ()<SCPlayerDelegate>
{
    AVURLAsset *asset;
    UIScrollView *vv;
    NSInteger ww;
    NSMutableData *allSongSamples;
    AVAudioPlayer *audioPlayer;
    int count;
    UIView *redScale;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    redScale =[[UIView alloc] initWithFrame:CGRectMake(screenW/2, 0, 1, screenW)];
    redScale.backgroundColor = UIColor.redColor;
    [self.view addSubview:redScale];
    
    
    [self turnFormat];
    [self seeAudio];
    [self cutAudio];
    [self appendAudio];
    [self audioPlayer];
    
}

-(void)turnFormat
{
    NSURL *formatUrl =  [[NSBundle mainBundle] URLForResource:@"小青蛙唱歌" withExtension:@"mp3"];
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"小青蛙唱歌.wav"];
    NSLog(@"document=%@",document);
    
    [AudioToWav FormatPath:formatUrl.absoluteString seavePath:path];
    
}

-(void)seeAudio
{
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"小青蛙唱歌.wav"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    
    
    AVURLAsset  *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    SeeAudio *seec = [[SeeAudio alloc] initWithFrame:self.view.bounds];
    
    [seec renderPNGAudioPictogramLogForAsset:asset done:^(UIImage *image,NSInteger imageWidth) {
        UIScrollView *scrv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [scrv setContentSize:CGSizeMake(imageWidth, 200)];
        [self.view addSubview:scrv];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, imageWidth, 200)];
        imgv.image = image;
        [scrv addSubview:imgv];
        [self.view addSubview:scrv];
        [self.view bringSubviewToFront:self->redScale];
        self->vv = scrv;
        
        
        SCPlayer *scp = [[SCPlayer alloc] initWithFrame:CGRectMake(0, 400, screenW, 1)];
        [scp replaceCurrentUrl:url.absoluteString];
        scp.delegate = self;
        [self.view addSubview:scp];
        
        self->ww = imageWidth;
        
    }];
    
    
}

-(void)cutAudio
{
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"小青蛙唱歌.wav"];
    
    
    NSData *allSongSamples1 = [[NSData alloc] initWithContentsOfFile:path];
    
    //在转为wav时会增加4000字节的空值，需要去掉，索性去掉4096吧:)
    long wav1DataSize = [allSongSamples1 length] - 44 - 4096;
    
    allSongSamples = [[NSMutableData alloc] initWithCapacity:wav1DataSize];
    [allSongSamples appendData:[allSongSamples1 subdataWithRange:NSMakeRange(44+4096, wav1DataSize)]];
    
    
    NSRange rr;
    rr.location = 0;
    rr.length = ((44100*16*2)/8.0)*10;
    allSongSamples = (NSMutableData*)[allSongSamples subdataWithRange:rr];
    
    
    
    NSString *path1 = [document stringByAppendingPathComponent:@"cut_1.wav"];
    [PcmAddWavHeader PcmAddWavHeader:allSongSamples toFile:path1];
}

-(void)appendAudio
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    //第一段音频
    NSString *cut_1_path = [document stringByAppendingPathComponent:@"cut_1.wav"];
    NSMutableData *cut_1_data = [[NSMutableData alloc] initWithContentsOfFile:cut_1_path];
    long cut_1_DataSize = [cut_1_data length] - 44-4096;
    NSMutableData *acut_1_Samples = [[NSMutableData alloc] initWithCapacity:cut_1_DataSize];
    [acut_1_Samples appendData:[cut_1_data subdataWithRange:NSMakeRange(44+4096, cut_1_DataSize)]];
    
    //第二段音频
    NSString *cut_2_path = [document stringByAppendingPathComponent:@"cut_2.wav"];
    NSMutableData *cut_2_data = [[NSMutableData alloc] initWithContentsOfFile:cut_2_path];
    long cut_2_DataSize = [cut_1_data length] - 44-4096;
    NSMutableData *acut_2_Samples = [[NSMutableData alloc] initWithCapacity:cut_2_DataSize];
    [acut_2_Samples appendData:[cut_2_data subdataWithRange:NSMakeRange(44+4096, cut_2_DataSize)]];
    
    //拼接
    [acut_2_Samples appendData:acut_1_Samples];
    
    //输出
    NSString *appendAudio_path = [document stringByAppendingPathComponent:@"appendAudio.wav"];
    [PcmAddWavHeader PcmAddWavHeader:acut_2_Samples toFile:appendAudio_path];
}



-(void)audioPlayer
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"cut_2.wav"];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
    [audioPlayer play];
}

-(void)timeRunAndTime:(NSInteger)runTime
{
    //线形运动，不要缓动
    [UIView animateWithDuration:139 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self->vv setContentOffset:CGPointMake(self->ww-screenW, 0) animated:NO];
    } completion:^(BOOL finished) {
        
    }];
    
}









@end
