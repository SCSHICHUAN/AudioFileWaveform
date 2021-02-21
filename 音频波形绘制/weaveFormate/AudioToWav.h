//
//  AudioToWav.h
//  音频波形绘制
//
//  Created by Stan on 2021/2/21.
//  Copyright © 2021 石川. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioToWav : NSObject
+(void)FormatPath:(nonnull NSString*)path seavePath:(nonnull NSString *)seavePath;
@end

NS_ASSUME_NONNULL_END
