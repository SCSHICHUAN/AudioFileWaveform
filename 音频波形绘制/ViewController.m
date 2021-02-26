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
 
    
//    [self turnFormat];
//    [self cutAudio];
   [self seeAudio];
//    [self audioPlayer];
//    [self appendAudio];
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
-(void)audioPlayer
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"test.wav"];
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
    rr.length = ((44100*16*2)/8.0)*11;
    allSongSamples = (NSMutableData*)[allSongSamples subdataWithRange:rr];
    
    
    
    NSString *path1 = [document stringByAppendingPathComponent:@"cut_1.wav"];
    [PcmAddWavHeader PcmAddWavHeader:allSongSamples toFile:path1];
}


-(void)appendAudio
{
    count = 1;
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"appand1.wav"];
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"m4a"];
    [AudioToWav FormatPath:url1.absoluteString seavePath:path];
    
    
    

    NSString *path2 = [document stringByAppendingPathComponent:@"appand2.wav"];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"4" withExtension:@"m4a"];
    [AudioToWav FormatPath:url2.absoluteString seavePath:path2];

  
   
}
-(void)append
{
     NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
       NSString *path11 = [document stringByAppendingPathComponent:@"appand1.wav"];
       NSMutableData *wdata1 = [[NSMutableData alloc] initWithContentsOfFile:path11];
    
        
      long wav1DataSize = [wdata1 length] - 44-4096;
       
       allSongSamples = [[NSMutableData alloc] initWithCapacity:wav1DataSize];
       [allSongSamples appendData:[wdata1 subdataWithRange:NSMakeRange(44+4096, wav1DataSize)]];
       wdata1  =  allSongSamples;
    
       
    
    
    
    
       NSString *path22 = [document stringByAppendingPathComponent:@"appand2.wav"];
       NSMutableData *wdata2 = [[NSMutableData alloc] initWithContentsOfFile:path22];
    
    
    
    {
        long wav1DataSize = [wdata2 length] - 44-4096;
        allSongSamples = [[NSMutableData alloc] initWithCapacity:wav1DataSize];
        [allSongSamples appendData:[wdata2 subdataWithRange:NSMakeRange(44+4096, wav1DataSize)]];
        wdata2  =  allSongSamples;
    }
    
    
    
    
       [wdata1 appendData:wdata2];
       NSString *path1 = [document stringByAppendingPathComponent:@"test.wav"];
      [PcmAddWavHeader PcmAddWavHeader:wdata1 toFile:path1];
}

-(void)turnFormat
{
    NSURL *formatUrl =  [[NSBundle mainBundle] URLForResource:@"小青蛙唱歌" withExtension:@"mp3"];
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"小青蛙唱歌.wav"];
    NSLog(@"document=%@",document);
    
    [AudioToWav FormatPath:formatUrl.absoluteString seavePath:path];

}




@end
