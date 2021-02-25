//
//  PcmAddWavHeader.m
//  音频波形绘制
//
//  Created by Stan on 2021/2/25.
//  Copyright © 2021 石川. All rights reserved.
//

#import "PcmAddWavHeader.h"

#define AUDIO_SAMPLE_RATE 44100
#define AUDIO_FRAMES_PER_PACKET 1
#define AUDIO_CHANNELS_PER_FRAME 2
#define AUDIO_BITS_PER_CHANNEL 16
#define AUDIO_BYTES_PER_PACKET 2
#define AUDIO_BYTES_PER_FRAME 2


@implementation PcmAddWavHeader

+(void)PcmAddWavHeader:(NSData *)data toFile:(NSString *)targetFilePath
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
}
@end
