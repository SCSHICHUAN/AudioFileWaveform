//
//  SeeAudio.m
//  音频波形绘制
//
//  Created by 石川 on 2019/12/24.
//  Copyright © 2019 石川. All rights reserved.
//
/*
 if(x<=-50){
 return -50;
 }else{
 if(x>=0){
 return 0;
 }else{
 return x;
 }
 }

1.为了音视频的编辑显示以及其他处理，需要设置一个最的小标准，因而产生CMTime，
（eg:如果音视频编辑器上的一格，表示好几帧，那么这几帧无法拆分）
2.eg：0.001s 播放了 1 帧，用CMTime表示，最好是一个CMTime的value增加 1 ，音视频增加1帧。
（只要设置timescale=1000，value = 0.001s * （1000份/s）= 1 份 ）
3.不能以增加零点几个CMTime的value，音视频增加1帧，这样就没有意义了，所以只能大，可以用增加几个CMTime的value，音视频增加1帧。
eg：如果设置 timescale = 10000  CMTime的value增加10，音视频增加1帧。

typedef struct {
CMTimeValue value; // 当前的CMTimeValue 的值
CMTimeScale timescale; //时间尺  时间基  当前的CMTimeValue 的参考标准 ( 即把1s分为多少份)
CMTimeFlags flags;
CMTimeEpoch epoch;
} CMTime

eg:timescale = 1000 份/s; 时间 2.5s 转换为CMTime 的value为多大
value = 2.5 * 1000 = 2500;

真实时间 = value/timescale = （2500 份） / （1000 份/s）= 2.5s;
时间标尺下的总时长（CMTime value）（timescale 即把1s分为多少份 ）
*/
#import "SeeAudio.h"
#import <stdlib.h>
#define noiseFloor (-50.0)
#define decibel(amplitude) (20 * log10( fabsf(amplitude)/32767.0 )) //转换为[0 - 100]
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x)) //(x<=noiseFloor?noiseFloor:(x>=0?0:x)
#define spaceX 4
#define KimageHeight 200
#define padding 40
#define halfScreenW ([UIScreen mainScreen].bounds.size.width/2)

@interface SeeAudio ()
@end


@implementation SeeAudio

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}
//get data
- (void)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset
                                      done:(void(^)(UIImage *image,NSInteger imageWidth))done
{
    // TODO: break out subsampling code
    //声道数
    UInt32 channelCount = 0;
    //最大平均值
    Float32 maximum;
    //存所有平均值
    NSMutableData *fullSongData;
    NSError *error = nil;
    //创建多媒体阅读器
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    //筛选出audio
    NSArray *audioTracks = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    //获取其中的一个音频轨道
    AVAssetTrack *songTrack =[audioTracks objectAtIndex:0];
    //CMTime  时间 = value / 时间基
    float duration = songAsset.duration.value/songAsset.duration.timescale;
    int32_t timescale = songAsset.duration.timescale;
    
    NSLog(@"duration=%f",duration);
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    // You can read the samples in the track in their stored format, or you can convert them to a different format.
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    
    
    
    NSArray *formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        //获取多媒体描述
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (!fmtDesc) return; //!
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    maximum = noiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    if(fullSongData){
        fullSongData = nil;
    }
    
    
    fullSongData = [[NSMutableData alloc] init];
    [reader startReading];
    
    /*
     CMVideoFormatDesc：video的格式，包括宽高、颜色空间、编码格式、SPS、PPS
     CVPixelBuffer:包含未压缩的像素格式，宽高
     CMBlockBuffer:未压缩的的图像数据
     CMSampleBuufer:存放一个或多个压缩或未压缩的媒体文件
     */
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        //CMSampleBufferRef:这是一个包含零个或多个解码后（未解码）特定媒体类型的样本（音频，视频，多路复用等）
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef) {
            //未压缩的的图像数据
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            NSMutableData * data = [NSMutableData dataWithLength:bufferLength];
            /*
             @param    theSourceBuffer
             @param    offsetToData
             @param    dataLength
             @param    destination
             */
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data.mutableBytes);
            
            
            SInt16 *samples = (SInt16 *)data.mutableBytes;
            // 16 = [8][8],两位表示一个fream
            long sampleCount = bufferLength / bytesPerInputSample;
            for (int i=0; i<sampleCount; i++) {
                
                Float32 sample = (Float32) *samples++;//获取一帧一帧的采样
                //求出50以内的值，最大值50
                sample = decibel(sample);
                sample = minMaxX(sample,noiseFloor,0);
                tally += sample;
                //获取多个声道中的一个声道数据
                for (int j=1; j<channelCount; j++)
                    samples++;
                
                tallyCount++;
                
                /*
                 把帧加起来求平均值，因为帧数太多
                 从音频中获取采样率为，1s，44100
                 份为10份，一份为44100/10 = 4410，
                 把这4410加起来求平均值，然后放入缓冲区，即一个条形的高度
                 */
                if (tallyCount == (timescale/10)) {
                    
                    sample = tally / tallyCount;
                    maximum = maximum > sample ? maximum : sample;//求最大的平均值
                    int sampleLen = sizeof(sample);
                    [fullSongData appendBytes:&sample length:sampleLen];
                    tally = 0;
                    tallyCount = 0;
                    outSamples++;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            data =nil;
        }
    }
    //每一秒画 10 个条形图
    NSInteger drowCount = duration*10;
    
    if (reader.status == AVAssetReaderStatusCompleted){
        NSLog(@"FDWaveformView: start rendering PNG W= %f", outSamples);
        [self plotLogGraph:(Float32 *)fullSongData.bytes
              maximumValue:maximum
                 drowCount:drowCount
                      done:done];
    }
    
    
}
//get plot
- (void) plotLogGraph:(Float32 *) samples
         maximumValue:(Float32) normalizeMax
            drowCount:(NSInteger)drowCount
                 done:(void(^)(UIImage *image,NSInteger imageWidth))done
{
    // TODO: switch to a synchronous function that paints onto a given context
    
    
    
    CGSize imageSize = CGSizeMake(drowCount*spaceX+halfScreenW*2, KimageHeight);
    // 0.0 表示不做任何缩放，必须这初始化，其他方法会造成颜色变淡
    UIGraphicsBeginImageContextWithOptions(imageSize,YES,0.0); // this is leaking memory?
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    int imageCentreY = KimageHeight/2;
    int offsetX = halfScreenW;
    int secend = 0;
    int time = 0;
    int start = -1;
    /*
     控制振幅在一定范围内
     KimageHeight = 最大振幅*2*k+padding,k 比例系数，padding，内边距。
     - KimageHeight = ((fabsf(normalizeMax)-50)*k - padding)*2;
     */
    CGFloat k = (((-KimageHeight)/2)+padding)/(fabsf(normalizeMax)-50);
    
    for (NSInteger intSample=0; intSample<=drowCount; intSample++) {
        Float32 sample = *(samples++);
        if(!sample) { NSLog(@"wrong wrong------"); break;}
        int offsetY = (fabsf(sample)-50)*k;
        //        printf("%d  ",offsetY);
        CGContextSetAlpha(context,1.0);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
        CGContextMoveToPoint(context, offsetX, imageCentreY-offsetY);
        CGContextAddLineToPoint(context, offsetX, imageCentreY+offsetY);
        CGContextStrokePath(context);
        
        //时间刻度和时间,一个豆腐砍9刀分为10份
        if (secend == 9 || start == -1) {
            start = 0;
            
            CGContextSetAlpha(context,1.0);
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
            CGContextMoveToPoint(context, offsetX,0);
            CGContextAddLineToPoint(context, offsetX,10);
            CGContextStrokePath(context);
            secend = 0;
            
            
            CGContextSetLineWidth(context, 1.0);
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
            CGContextStrokePath(context);
            NSDictionary *dict  =@{NSFontAttributeName:[UIFont systemFontOfSize:8],
                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
            NSString *timeStr = [NSString stringWithFormat:@"%.2d:%.2d",time/60,time%60];
            [timeStr drawAtPoint:CGPointMake(offsetX-5,12) withAttributes:dict];
            time++;
        }else{
            CGContextSetAlpha(context,1.0);
            CGContextSetLineWidth(context, 0.5);
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor.CGColor);
            CGContextMoveToPoint(context, offsetX,0);
            CGContextAddLineToPoint(context, offsetX,6);
            CGContextStrokePath(context);
            secend++;
        }
        
        offsetX+=spaceX;
    }
    
    
    //draw line
    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(0, 0)];
    [line addLineToPoint:CGPointMake(imageSize.width,0)];
    [line setLineWidth:1.0];
//    [line stroke];
    //center line
    [line moveToPoint:CGPointMake(0, KimageHeight/2)];
    [line addLineToPoint:CGPointMake(imageSize.width, KimageHeight/2)];
    [line setLineWidth:1.0];
    //    [line stroke];
    
    [line moveToPoint:CGPointMake(0, KimageHeight)];
    [line addLineToPoint:CGPointMake(imageSize.width, KimageHeight)];
    [line setLineWidth:1.0];
    //    [line stroke];
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    done(image,drowCount*spaceX+halfScreenW*2);
}
@end
