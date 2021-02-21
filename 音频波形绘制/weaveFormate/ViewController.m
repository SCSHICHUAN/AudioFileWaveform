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

@interface ViewController ()<SCPlayerDelegate>
{
    AVURLAsset *asset;
    UIScrollView *vv;
    NSInteger ww;
    NSMutableData *allSongSamples;
    AVAudioPlayer *audioPlayer;
    int count;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
      NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
      NSString *path = [document stringByAppendingPathComponent:@"test2.wav"];
    
    
//    NSURL *url =  [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"m4a"];
//       [self convertTapped:url toFileName:path resultBlock:nil];
    
//    [self turnFormat];
//    [self cutAudio];
//       [self getWav];
   [self seeAudio];
//    [self audioPlayer];
//    [self appendAudio];
}
-(void)seeAudio
{
    
    AVURLAsset  *asset = [[AVURLAsset alloc]initWithURL:
                          [[NSBundle mainBundle] URLForResource:@"小青蛙唱歌" withExtension:@"mp3"] options:nil];
    SeeAudio *seec = [[SeeAudio alloc] initWithFrame:self.view.bounds];
    
    [seec renderPNGAudioPictogramLogForAsset:asset done:^(UIImage *image,NSInteger imageWidth) {
        UIScrollView *scrv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [scrv setContentSize:CGSizeMake(imageWidth, 200)];
        [self.view addSubview:scrv];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, imageWidth, 200)];
        imgv.image = image;
        [scrv addSubview:imgv];
        [self.view addSubview:scrv];
        self->vv = scrv;
        
        
        SCPlayer *scp = [[SCPlayer alloc] initWithFrame:CGRectMake(0, 400, screenW, 300)];
        [scp replaceCurrentUrl:[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] URLForResource:@"小青蛙唱歌" withExtension:@"mp3"]]];
        scp.delegate = self;
        [self.view addSubview:scp];
        
        self->ww = imageWidth;
        
    }];
    UIView *v =[[UIView alloc] initWithFrame:CGRectMake(screenW/2, 0, 1, screenW)];
    v.backgroundColor = UIColor.redColor;
    [self.view addSubview:v];
}
-(void)audioPlayer
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"test.wav"];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:&error];
   [audioPlayer play];
}
-(void)getWav
{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"test2.wav"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"whenImissYou" withExtension:@"mp3"];
    [self convertTapped:url toFileName:path resultBlock:nil];
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
    NSString *path = [document stringByAppendingPathComponent:@"test2.wav"];
    
    
    NSData *allSongSamples1 = [[NSData alloc] initWithContentsOfFile:path];
    
    //新版的ios可能脑子进水了，在转为wav时会增加4000字节的空值，需要去掉，索性去掉4096吧:)
    long wav1DataSize = [allSongSamples1 length] - 44-4096;
    
    allSongSamples = [[NSMutableData alloc] initWithCapacity:wav1DataSize];
    [allSongSamples appendData:[allSongSamples1 subdataWithRange:NSMakeRange(44+4096, wav1DataSize)]];
    
    
    NSRange rr;
    rr.location = 0;
    rr.length = ((44100*16)/4.0)*6;
    allSongSamples = (NSMutableData*)[allSongSamples subdataWithRange:rr];
    
    
    
    NSString *path1 = [document stringByAppendingPathComponent:@"test.wav"];
    
    

    [self writeAudioData:allSongSamples toFile:path1];
}
#define AUDIO_SAMPLE_RATE 44100
#define AUDIO_FRAMES_PER_PACKET 1
#define AUDIO_CHANNELS_PER_FRAME 2
#define AUDIO_BITS_PER_CHANNEL 16
#define AUDIO_BYTES_PER_PACKET 2
#define AUDIO_BYTES_PER_FRAME 2
-(void)writeAudioData:(NSData *)data toFile:(NSString *)targetFilePath
{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:targetFilePath error:nil];
    
    NSString *wavFilePath = targetFilePath;
    int i=0;
    for(i=0;i<[data length];i++){
        const char* values = [data bytes];
        if(values[i]!='0')
            break;
    }
    NSLog(@"value null:%d",i);
    
    FILE *fout;
    
    short NumChannels = AUDIO_CHANNELS_PER_FRAME;
    short BitsPerSample = AUDIO_BITS_PER_CHANNEL;
    int SamplingRate = AUDIO_SAMPLE_RATE;
    NSInteger numOfSamples = [data length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    NSInteger DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    NSInteger totalSize = 36 + DataSize;
    short audioFormat = 1;
    
    if((fout = fopen([wavFilePath cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
    }
    
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    
    fclose(fout);
    
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFilePath];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    [self audioPlayer];
}






//把voice转换为wav，pcm格式才可以随便拼接
typedef void (^ConvertPCMCompletionBlock)(NSString *destFilePath);
-(void)convertTapped:(NSURL*)fromUrl toFileName:(NSString *)exportPath resultBlock:(ConvertPCMCompletionBlock)callback{
   
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:fromUrl options:nil];
    if(songAsset==nil) return;
    NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                                error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AVAssetTrack *track = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                               assetReaderAudioMixOutputWithAudioTracks:[NSArray arrayWithObject:track]
                                               audioSettings: nil];
    
    
    if (! [assetReader canAddOutput: assetReaderOutput]) {
       
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                           fileType:AVFileTypeWAVE
                                                              error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                               outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 
                 CMSampleBufferInvalidate(nextBuffer);
//                 CFRelease(nextBuffer);
//                 nextBuffer = NULL;
                 
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWritingWithCompletionHandler:^{
                     NSLog(@"已经存入磁盘");
                     if (self->count==2) {
                         [self append];
                     }
                     self->count++;
                 }];
                 [assetReader cancelReading];
                 if(callback!=nil)
                     callback(exportPath);
                 break;
             }
         }
         
     }];
    NSLog (@"bottom of convertTapped:");
}

-(void)appendAudio
{
    count = 1;
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"appand1.wav"];
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"3" withExtension:@"m4a"];
    [self convertTapped:url1 toFileName:path resultBlock:nil];
    

    NSString *path2 = [document stringByAppendingPathComponent:@"appand2.wav"];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"4" withExtension:@"m4a"];
    [self convertTapped:url2 toFileName:path2 resultBlock:nil];
    

  
   
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
       [self writeAudioData:wdata1 toFile:path1];
}

-(void)turnFormat
{

    NSURL *formatUrl =  [[NSBundle mainBundle] URLForResource:@"whenImissYou" withExtension:@"mp3"];
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [document stringByAppendingPathComponent:@"test2.wav"];
    
    [AudioToWav FormatPath:formatUrl.absoluteString seavePath:path];
    return;
    
      
}




@end
