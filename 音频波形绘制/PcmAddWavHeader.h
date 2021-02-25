//
//  PcmAddWavHeader.h
//  音频波形绘制
//
//  Created by Stan on 2021/2/25.
//  Copyright © 2021 石川. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PcmAddWavHeader : NSObject
+(void)PcmAddWavHeader:(NSData *)data toFile:(NSString *)targetFilePath;
@end

NS_ASSUME_NONNULL_END
