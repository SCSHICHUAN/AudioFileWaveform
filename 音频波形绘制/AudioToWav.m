//
//  AudioToWav.m
//  音频波形绘制
//
//  Created by Stan on 2021/2/21.
//  Copyright © 2021 石川. All rights reserved.
//

#import "AudioToWav.h"
#include <AVFoundation/AVFoundation.h>

@implementation AudioToWav
/*
 重轨道中读取数据放入格式化多轨道中
 */
+(void)FormatPath:(nonnull NSString*)path seavePath:(nonnull NSString *)seavePath
{
    NSError *error = nil;
    
    //输入
    NSURL *f_url = [NSURL URLWithString:path];
    AVURLAsset *formatAsset = [AVURLAsset URLAssetWithURL:f_url options:nil];
    AVAssetReader *assetReader=[[AVAssetReader alloc]initWithAsset:formatAsset error:&error];
    if (error) {
        NSLog(@"assetReader error:%@",error);
    }
    
    //设置outPut
    NSDictionary *outputSettings=@{(id)AVFormatIDKey:@(kAudioFormatLinearPCM)};
    AVAssetTrack *formatTrack=[[formatAsset tracksWithMediaType:AVMediaTypeAudio]firstObject];
    AVAssetReaderTrackOutput *trackOutput=[[AVAssetReaderTrackOutput alloc]initWithTrack:formatTrack outputSettings:outputSettings];
    
    //添加输入轨道
    [assetReader addOutput:trackOutput];
   

    
    //输入
    NSURL *outputURL=[NSURL fileURLWithPath:seavePath];
    AVAssetWriter *assetWriter=[[AVAssetWriter alloc]initWithURL:outputURL fileType:AVFileTypeWAVE error:nil];
    
    //lin PCM需要设置PCM一些相关的属性
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *writerOutputSetting=
    @{(id)AVFormatIDKey:@(kAudioFormatLinearPCM),
      (id)AVSampleRateKey:[NSNumber numberWithFloat:44100.0],
      AVNumberOfChannelsKey:[NSNumber numberWithInt: 2],
      AVLinearPCMBitDepthKey:[NSNumber numberWithInt:16],
      AVLinearPCMIsNonInterleaved:[NSNumber numberWithBool:NO],
      AVLinearPCMIsFloatKey:[NSNumber numberWithBool:NO],
      AVLinearPCMIsBigEndianKey:[NSNumber numberWithBool:NO],
      AVChannelLayoutKey:[NSData dataWithBytes:&channelLayout length: sizeof(AudioChannelLayout)]};
    
    AVAssetWriterInput *writerInput=[[AVAssetWriterInput alloc]initWithMediaType:AVMediaTypeAudio outputSettings:writerOutputSetting];
    //添加输入轨道
    [assetWriter addInput:writerInput];
    
    
    
    //开始工作
    if (![assetReader startReading]) {
        NSLog(@"Can't read asset:%ld",(long)[assetReader status]);
    }
    if (![assetWriter startWriting]) {
        NSLog(@"Can't wrinting asset:%ld",(long)[assetWriter status]);
    }
    
    
    //读取 转换 写入
    dispatch_queue_t dispatchQueue=dispatch_queue_create("readWrite", NULL);
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{

        bool complete=NO;

        while ([writerInput isReadyForMoreMediaData]&& !complete) {

           
            
            //输入轨道中读取数据
            @try {
               
                CMSampleBufferRef sampleBuffer=[trackOutput copyNextSampleBuffer];
                
                CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                size_t buff_size = CMSampleBufferGetTotalSampleSize(sampleBuffer);
                if (buff_size) {
                    NSLog(@"read_buff_size: %zu,pesent_time:%lld",buff_size,timeStamp.value/timeStamp.timescale);
                }
                
                if(buff_size){
                    //输出轨道添加数据
                    BOOL result=[writerInput appendSampleBuffer:sampleBuffer];
                    CFRelease(sampleBuffer);
                    complete=!result;

                }else{
                    [writerInput markAsFinished];
                    complete=YES;
                }
                
            } @catch (NSException *exception) {
                //添加输入轨道 决绝输入轨道掉了的bug
                [assetReader addOutput:trackOutput];
            }
            
        }
        
    
        if(complete){
             
            //输出完成
            [assetWriter finishWritingWithCompletionHandler:^{

                AVAssetWriterStatus status=assetWriter.status;
                NSLog(@"%@",assetWriter.error);
                if(status==AVAssetWriterStatusCompleted){
                    NSLog(@"AVAssetWriterStatusCompleted");
                }else{
                    NSLog(@"AVAssetWriterStatusFailed");
                }
            }];

        }

    }];
    
}
@end
