//
//  SeeAudio.h
//  音频波形绘制
//
//  Created by 石川 on 2019/12/24.
//  Copyright © 2019 石川. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface SeeAudio : UIView
-(instancetype)initWithFrame:(CGRect)frame;
- (void)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset
                                      done:(void(^)(UIImage *image,NSInteger imageWidth))done;
@end

NS_ASSUME_NONNULL_END
