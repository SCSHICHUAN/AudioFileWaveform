//
//  SCPlayer.m
//  PudongNews
//
//  Created by 石川 on 2019/11/20.
//  Copyright © 2019 SHICHUAN. All rights reserved.
//
#define statuH ([UIApplication sharedApplication].statusBarFrame.size.height)
#define screenW ([UIScreen mainScreen].bounds.size.width)
#define screenH ([UIScreen mainScreen].bounds.size.height)
#define screenZ ([UIScreen mainScreen].bounds)

#import "SCPlayer.h"
#import <ARKit/ARKit.h>
#import <Photos/Photos.h>

@interface SCPlayer()
@property (nonatomic, assign)BOOL centUpdatTime;
@property (nonatomic, assign)BOOL canPlay;
@property (nonatomic, assign)BOOL playButtonStatu;
@property (nonatomic, assign)BOOL canHidden;
@property (nonatomic, assign)BOOL lockScreen;
@property (nonatomic, assign)BOOL openTooBar;
@property (nonatomic, assign)float allTime;
@property (nonatomic, assign)float currentTime;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) AVPlayerItemVideoOutput * playerOutput;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *fallButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *takePhoto;
@property (nonatomic, strong) UIButton *loackScreen;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIImageView *cutImgv;
@property (nonatomic, strong) UIView *cutView;
@property (nonatomic, assign) CGRect oldFream;
@property (nonatomic, strong) UIButton *selfButton;
@property (nonatomic, strong) UIProgressView *progressView2;
@property (nonatomic, strong) UIProgressView *progressView3;
@property (nonatomic, strong) NSTimer *closeTimer;
@property (nonatomic, assign) int closeTimerGOTime;
@property (nonatomic, strong) UIActivityIndicatorView *activt;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *headLab;
@property (nonatomic, strong) UIButton *shotSave;
@property (nonatomic, strong) UIButton *shotShare;
@property (nonatomic, strong) UIButton *shotCancle;
@property (nonatomic, strong) UILabel *successSeaveToPhoto;
@end
@implementation SCPlayer
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.oldFream = frame;
    [self addRecognizer];
    
    [self.toolBar addSubview:self.playButton];
    [self.toolBar addSubview:self.fallButton];
    [self.toolBar addSubview:self.progressView];
    [self.toolBar addSubview:self.progressSlider];
    [self.toolBar addSubview:self.timeLab];
    
    [self.progressView3 addSubview:self.progressView2];
    
    [self.headView addSubview:self.backButton];
    [self.headView addSubview:self.headLab];
    
    [self.cutView addSubview:self.cutImgv];
    [self.cutView addSubview:self.shotSave];
    [self.cutView addSubview:self.shotShare];
    [self.cutView addSubview:self.shotCancle];
    
    [self addProgressObserver];
    [self addNotificationCenter];
    
    
    self.playButtonStatu = YES;
    self.takePhoto.hidden = YES;
    self.cutView.hidden = YES;
    self.shareButton.hidden = YES;
    self.loackScreen.hidden = YES;
    self.headView.hidden = YES;
    self.lockScreen = YES;
    self.openTooBar = NO;
    self.shotCurrenImg = [[UIImage alloc] init];
    [self hiddeButton:YES];
    self.closeTimerGOTime = 0;
    [self.closeTimer fire];
    self.successSeaveToPhoto.hidden = YES;
    
    return self;
}
- (AVPlayer *)player {
    if (!_player) {
        //初始化播放器对象
        _player = [[AVPlayer alloc] init];
        //显示画面
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
        layer.backgroundColor = UIColor.blackColor.CGColor;
        //设置画布frame
        layer.frame = self.bounds;
        //视频填充模式
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer = layer;
        [self.layer addSublayer:layer];
        [self addSubview:self.selfButton];
        [self addSubview:self.toolBar];
        [self addSubview:self.takePhoto];
        [self addSubview:self.shareButton];
        [self addSubview:self.loackScreen];
        [self addSubview:self.progressView3];
        [self addSubview:self.activt];
        [self addSubview:self.headView];
        [self addSubview:self.successSeaveToPhoto];
        [self addSubview:self.cutView];
    }
    return _player;
}
-(UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-30, self.bounds.size.width, 30)];
        _toolBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _toolBar;
}
-(UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 30, 30)];
        [_playButton setImage:[UIImage imageNamed:@"pause_button"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateSelected];
        _playButton.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
-(UIButton *)fallButton
{
    if (!_fallButton) {
        _fallButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame)-40, 0, 30, 30)];
        [_fallButton setImage:[UIImage imageNamed:@"video_full"] forState:UIControlStateNormal];
        [_fallButton setImage:[UIImage imageNamed:@"exit_fullscreen_button"] forState:UIControlStateSelected];
        _fallButton.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [_fallButton addTarget:self action:@selector(fallButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fallButton;
}
-(UIButton *)selfButton
{
    if (!_selfButton) {
        _selfButton = [[UIButton alloc] initWithFrame:self.bounds];;
    }
    return _selfButton;
}
-(UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 0,screenW-50-50-80, 30)];
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        _progressSlider.minimumTrackTintColor = [UIColor redColor];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"yuan_normal"] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(sliderChangeClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}
-(UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(52, 30/2-1.5/2+0.5, screenW-50-50-80, 1.5)];
        _progressView.trackTintColor = UIColor.whiteColor;
        _progressView.progressTintColor = UIColor.grayColor;
        _progressView.layer.cornerRadius = 1;
        _progressView.transform = CGAffineTransformMakeScale(1.0f,1.5f);
    }
    return _progressView;
}
-(UIProgressView *)progressView2
{
    if (!_progressView2) {
        _progressView2 = [[UIProgressView alloc] initWithFrame:self.progressView3.bounds];
        _progressView2.trackTintColor = UIColor.clearColor;
        _progressView2.progressTintColor = UIColor.redColor;
    }
    return _progressView2;
}
-(UIProgressView *)progressView3
{
    if (!_progressView3) {
        _progressView3 = [[UIProgressView alloc] initWithFrame:CGRectMake(0,self.bounds.size.height-1.5, screenW, 1.5)];
        _progressView3.trackTintColor = UIColor.whiteColor;
        _progressView3.progressTintColor = UIColor.grayColor;
    }
    return _progressView3;
}
-(UILabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.progressSlider.frame)+10, 0, 80, 30)];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        _timeLab.textColor = UIColor.whiteColor;
        _timeLab.font = [UIFont systemFontOfSize:10];
        _timeLab.text = @"00:00 / 00:00";
    }
    return _timeLab;
}
-(UIButton *)takePhoto
{
    if (!_takePhoto) {
        _takePhoto = [[UIButton alloc] initWithFrame:CGRectMake(screenH-50, 100, 40, 40)];
        _takePhoto.backgroundColor = UIColor.lightGrayColor;
        _takePhoto.backgroundColor = UIColor.clearColor;
        [_takePhoto setImage:[UIImage imageNamed:@"screenshot_normal"] forState:UIControlStateNormal];
        [_takePhoto addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhoto;
}
-(UIButton *)shareButton
{
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(screenH-50, 200, 40, 40)];
        _shareButton.backgroundColor = UIColor.lightGrayColor;
        _shareButton.backgroundColor = UIColor.clearColor;
        [_shareButton setImage:[UIImage imageNamed:@"share_normal"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}
-(UIButton *)loackScreen
{
    if (!_loackScreen) {
        _loackScreen = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _loackScreen.backgroundColor = UIColor.lightGrayColor;
        _loackScreen.backgroundColor = UIColor.clearColor;
        [_loackScreen setImage:[UIImage imageNamed:@"orientation_lock"] forState:UIControlStateNormal];
        [_loackScreen setImage:[UIImage imageNamed:@"orientation_locked"] forState:UIControlStateSelected];
        [_loackScreen addTarget:self action:@selector(loackScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loackScreen;
}
-(UIImageView *)cutImgv
{
    if (!_cutImgv) {
        UIImageView *imgv = [[UIImageView alloc] init];
        imgv.layer.borderWidth = 1;
        imgv.layer.borderColor = UIColor.whiteColor.CGColor;
        imgv.contentMode = UIViewContentModeScaleAspectFit;
        _cutImgv = imgv;
    }
    return _cutImgv;
}
-(UIView *)cutView
{
    if (!_cutView) {
        _cutView = [[UIView alloc] init];
        _cutView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _cutView;
}
-(UIButton *)shotSave
{
    if (!_shotSave) {
        _shotSave = [[UIButton alloc] init];
        [_shotSave.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_shotSave addTarget:self action:@selector(shotSaveClick) forControlEvents:UIControlEventTouchUpInside];
        _shotSave.layer.borderWidth = 1.0;
        _shotSave.layer.borderColor = UIColor.whiteColor.CGColor;
        _shotSave.layer.cornerRadius = 15.0;
        [_shotSave setTitle:@"保存" forState:UIControlStateNormal];
    }
    return _shotSave;
}
-(UIButton *)shotShare
{
    if (!_shotShare) {
        _shotShare = [[UIButton alloc] init];
        [_shotShare.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_shotShare addTarget:self action:@selector(shotShareClick) forControlEvents:UIControlEventTouchUpInside];
        _shotShare.layer.borderWidth = 1.0;
        _shotShare.layer.borderColor = UIColor.whiteColor.CGColor;
        _shotShare.layer.cornerRadius = 15.0;
        [_shotShare setTitle:@"分享" forState:UIControlStateNormal];
    }
    return _shotShare;
}
-(UIButton *)shotCancle
{
    if (!_shotCancle) {
        _shotCancle = [[UIButton alloc] init];
        [_shotCancle.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_shotCancle addTarget:self action:@selector(shotCancleClick) forControlEvents:UIControlEventTouchUpInside];
        _shotCancle.layer.borderWidth = 1.0;
        _shotCancle.layer.borderColor = UIColor.whiteColor.CGColor;
        _shotCancle.layer.cornerRadius = 15.0;
        [_shotCancle setTitle:@"取消" forState:UIControlStateNormal];
    }
    return _shotCancle;
}
-(NSTimer *)closeTimer
{
    if (!_closeTimer) {
        _closeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(closeTimerGO) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_closeTimer forMode:NSRunLoopCommonModes];
    }
    return _closeTimer;
}
-(UIActivityIndicatorView *)activt
{
    if (!_activt) {
        _activt = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activt.frame = CGRectMake(self.bounds.size.width/2-40/2, self.bounds.size.height/2-40/2, 40, 40);
        [_activt startAnimating];
    }
    return _activt;
}
-(UIView *)headView
{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, -40, screenH, 40)];
        _headView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return _headView;
}
-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
        [_backButton setImage:[UIImage imageNamed:@"danmaku_live_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
-(UILabel *)headLab
{
    if (!_headLab) {
        _headLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backButton.frame), 0, screenH-100, 40)];
        _headLab.textColor = UIColor.whiteColor;
        _headLab.textAlignment = NSTextAlignmentLeft;
    }
    return _headLab;
}
-(UILabel *)successSeaveToPhoto
{
    if (!_successSeaveToPhoto) {
        _successSeaveToPhoto = [[UILabel alloc] init];
        _successSeaveToPhoto.font = [UIFont systemFontOfSize:12];
        _successSeaveToPhoto.textColor = UIColor.whiteColor;
        _successSeaveToPhoto.textAlignment = NSTextAlignmentCenter;
        _successSeaveToPhoto.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return _successSeaveToPhoto;
}
-(void)playButtonClick:(UIButton*)button
{
    button.selected = !button.selected;
    
    if (self.player.rate == 0) {
        [self.player play];
    } else if (self.player.rate > 0) {
        [self.player pause];
    }
    if (!button.isSelected) {
        self.playButtonStatu = YES;
    }else{
        self.playButtonStatu = NO;
    }
}
-(void)fallButtonClick:(UIButton*)button
{
    button.selected = !button.selected;
    [self fallScreen:button.selected];
}

-(void)addRecognizer
{
    //Slider
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.progressSlider addGestureRecognizer:tap];
    [self.progressSlider addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    //self
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap2:)];
    [self.selfButton addGestureRecognizer:tap2];
}
#pragma mark - 点击调进度
- (void)tap:(UITapGestureRecognizer *)sender {
    
//    self.centUpdatTime = NO;
//
//    CGPoint touchPoint = [sender locationInView:self.progressSlider];
//    CGFloat value = touchPoint.x / CGRectGetWidth(self.progressSlider.bounds);
//    [self.progressSlider setValue:value animated:YES];
//    [self sliderChangeClick:self.progressSlider];
//
//
//    [self popTimePlay];
//
//    if (sender.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"结束点击");
//        if (self.playButtonStatu == YES) {
//            if (self.canPlay) {
//                [self.player play];
//            }
//
//        }
//    }
    
    
    
}
-(void)sliderChangeClick:(UISlider *)sender {
    self.centUpdatTime = NO;
    //拖拽的时候先暂停
//    if (self.player.rate > 0) {
//        [self.player pause];
//    }
    
    
    [self popTimePlay];
    NSLog(@"%f",sender.value);
}
#pragma mark - SliederAction
- (void)handleTouchDown:(UISlider *)slider{
    NSLog(@"TouchDown");
//    if (self.playButtonStatu == YES) {
//        self.centUpdatTime = NO;
//    }
    
}

- (void)handleTouchUp:(UISlider *)slider{
    NSLog(@"TouchUp");
//    if (self.playButtonStatu == YES) {
//        self.centUpdatTime = NO;
//        if (self.canPlay) {
//            [self.player play];
//        }
//    }
//
//    [self popTimePlay];
}
//调到播放
-(void)popTimePlay
{
    float fps = 60;//m3u8
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration) * self.progressSlider.value, fps);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"已经跳到时间对应的视频");
        }
    }];
}
-(void)replaceCurrentUrl:(NSString*)urlStr
{
    NSURL *url = [NSURL URLWithString:urlStr];
    // 初始化播放单元
    self.item = [AVPlayerItem playerItemWithURL:url];
    self.playerOutput = [[AVPlayerItemVideoOutput alloc] init];
    [self.item addOutput:self.playerOutput];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    
    [self addObserverToPlayerItem:self.item];
    self.centUpdatTime = YES;
}
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem {
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        NSLog(@"状态%ld", (long)status);
        if (status == AVPlayerStatusReadyToPlay) {
            self.canPlay = YES;
            if (self.playButtonStatu == YES) {
                [self.player play];
            }
        }else{
            self.canPlay = NO;
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //        NSTimeInterval totalBuffer = startSeconds + durationSeconds;;
        float progress = startSeconds+durationSeconds;
        self.progressView.progress = progress/self.allTime;
        self.progressView3.progress = progress/self.allTime;
        
        
        //缓存时间
        //        int currentTime = progress;
        //        int currentHour = currentTime / (60*60);
        //        int currentMin  = currentTime / 60;
        //        int currentSecond  = currentTime % 60;
        //        self.timeLab.text = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",currentHour,currentMin,currentSecond];
        
        if (self.canPlay) {
            if (self.playButtonStatu == YES) {
                [self.player play];
            }
        }
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        NSLog(@"playbackBufferEmpty");
        self.activt.hidden = NO;
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        NSLog(@"playbackLikelyToKeepUp");
        self.centUpdatTime = YES;
        self.activt.hidden = YES;
    }
    
}
#pragma mark-播放系统通知
-(void)addNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector
     (playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 监听
- (void)addProgressObserver {
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        float allTimeF = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        float currentTimeF = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        weakSelf.allTime = allTimeF;
        weakSelf.currentTime = currentTimeF;
        if (weakSelf.centUpdatTime) {
            weakSelf.progressSlider.value = currentTimeF / allTimeF;
            weakSelf.progressView2.progress = currentTimeF / allTimeF;
        }
        
        int allTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
        int currentTime = CMTimeGetSeconds(weakSelf.player.currentItem.currentTime);
        
        //        int allHour = allTime / (60*60);
        int allMin  = allTime / 60;
        int allSecond  = allTime % 60;
        
        //        int currentHour = currentTime / (60*60);
        int currentMin  = currentTime / 60;
        int currentSecond  = currentTime % 60;
        
        if ([weakSelf.delegate respondsToSelector:@selector(timeRunAndTime:)]) {
            [weakSelf.delegate timeRunAndTime:currentTime];
        }
        NSString *aullTime = [NSString stringWithFormat:@"%.2d:%.2d",allMin,allSecond];
        NSString *currentTime1 = [NSString stringWithFormat:@"%.2d:%.2d",currentMin,currentSecond];
        if (!weakSelf.isLive) {
            weakSelf.timeLab.text = [NSString stringWithFormat:@"%@ / %@",currentTime1,aullTime];
        }
    }];
}
-(void)fallScreen:(BOOL)b
{
    if ([self.delegate respondsToSelector:@selector(fullScreenButtonClick:)]) {
        [self.delegate fullScreenButtonClick:b];
    }
    if (b) {
        //横屏
        [UIView animateWithDuration:0.25 animations:^{
            self.takePhoto.hidden = NO;
            self.shareButton.hidden = NO;
            self.loackScreen.hidden = NO;
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [UIApplication sharedApplication].statusBarHidden = YES;
            
            self.frame = CGRectMake(screenW/2.0-screenH/2.0, screenH/2.0-(screenH*(9/16.0))/2, screenH,screenW);
            self.layer.anchorPoint = CGPointMake(0.5, 0.5);
            self.playerLayer.frame = self.bounds;
            self.toolBar.frame = CGRectMake(0,self.bounds.size.height-30, self.bounds.size.width, 30);
            self.progressView.frame = CGRectMake(52, 30/2-1.5/2+0.5, screenH-50-50-80, 1.5);
            self.progressSlider.frame = CGRectMake(50, 0,screenH-50-50-80, 30);
            self.fallButton.frame = CGRectMake(screenH-40, 0, 30, 30);
            self.timeLab.frame =CGRectMake(CGRectGetMaxX(self.progressSlider.frame)+10, 0, 80, 30);
            self.cutView.frame = self.bounds;
            self.cutImgv.frame = CGRectMake(60,screenW/2.0-(screenH/2.0*(9/16.0))/2.0,screenH/2.0,screenH/2.0*(9/16.0));
            self.shotSave.frame = CGRectMake(CGRectGetMaxX(self.cutImgv.frame)+20,CGRectGetMinY(self.cutImgv.frame)+10,70,30);
            self.shotShare.frame = CGRectMake(CGRectGetMaxX(self.cutImgv.frame)+20,CGRectGetMinY(self.cutImgv.frame)+self.cutImgv.bounds.size.height/2.0-15,70,30);
            self.shotCancle.frame = CGRectMake(CGRectGetMaxX(self.cutImgv.frame)+20,CGRectGetMaxY(self.cutImgv.frame)-10-30,70,30);
            self.progressView3.frame = CGRectMake(0,screenW-1.5, screenH, 1.5);
            self.progressView2.frame = self.progressView3.bounds;
            self.selfButton.frame = self.bounds;
            self.loackScreen.frame = CGRectMake(10, screenW/2.0-20, 40, 40);
            self.activt.frame = CGRectMake(screenH/2-40/2, screenW/2-40/2, 40, 40);
            self.headView.frame =  CGRectMake(0, 0, screenH, 40);
            self.successSeaveToPhoto.frame = self.bounds;
            
            self.transform = CGAffineTransformRotate(self.transform, M_PI_2);//后旋转
        }];
        
        
    }else{
        
        //竖屏
        [UIView animateWithDuration:0.25 animations:^{
            self.takePhoto.hidden = YES;
            self.shareButton.hidden = YES;
            self.loackScreen.hidden = YES;
            self.transform = CGAffineTransformRotate(self.transform,-M_PI_2);//选旋转
            [self removeFromSuperview];
            [self.supperView addSubview:self];
            self.frame = self.oldFream;
            self.playerLayer.frame = self.bounds;
            self.toolBar.frame = CGRectMake(0,self.bounds.size.height-30, self.bounds.size.width, 30);
            self.progressView.frame = CGRectMake(52, 30/2-1.5/2+0.5, screenW-50-50-80, 1.5);
            self.progressSlider.frame = CGRectMake(50, 0,screenW-50-50-80, 30);
            self.fallButton.frame = CGRectMake(screenW-40, 0, 30, 30);
            self.timeLab.frame =CGRectMake(CGRectGetMaxX(self.progressSlider.frame)+10, 0, 80, 30);
            self.progressView3.frame = CGRectMake(0,self.bounds.size.height-1.5, screenW, 1.5);
            self.progressView2.frame = self.progressView3.bounds;
            self.selfButton.frame = self.bounds;
            self.loackScreen.frame = CGRectMake(0, 0, 0, 0);
            self.activt.frame = CGRectMake(self.bounds.size.width/2-40/2, self.bounds.size.height/2-40/2, 40, 40);
            self.headView.frame =  CGRectMake(0, -40, screenH, 40);
        }];
        
    }
    
}
-(void)shareButtonClick
{
    if ([self.delegate respondsToSelector:@selector(shareButtonClick:)]) {
        [self.delegate shareButtonClick:NO];
    }
}
-(void)loackScreenButtonClick:(UIButton*)button
{
    button.selected = !button.selected;
    if (button.isSelected) {
        self.lockScreen = NO;
        [self hiddeButton:self.lockScreen];
    }else{
        self.lockScreen = YES;
        [self showButton:self.lockScreen];
    }
}
-(void)takePhotoButtonClick
{
    UIImage *img = [self screenshotsm3u8WithCurrentTime:self.player.currentTime playerItemVideoOutput:self.playerOutput];
    self.cutImgv.image = img;
    self.cutView.hidden = NO;
    self.shotCurrenImg = img;
}
-(void)hiddenCutView
{
    self.cutView.hidden = YES;
}
-(UIImage *)screenshotsm3u8WithCurrentTime:(CMTime)currentTime playerItemVideoOutput:(AVPlayerItemVideoOutput *)output{
    
    CVPixelBufferRef pixelBuffer = [output copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage
                                                   fromRect:CGRectMake(0,0,CVPixelBufferGetWidth(pixelBuffer),
                                                                       CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *frameImg = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    //不释放会造成内存泄漏
    CVBufferRelease(pixelBuffer);
    return frameImg;
}
-(void)scplayersotp
{
    [self.player pause];
    self.player = nil;
    [self.closeTimer invalidate];
}
-(void)screenChange
{
    [self fallButtonClick:self.fallButton];
}
-(void)pasuesc
{
    self.playButton.selected = YES;
    [self.player pause];
    
    if (self.player.rate > 0) {
        [self.player pause];
    }
    self.playButtonStatu = NO;
}
// self touch
#pragma mark - 点击调进度
- (void)tap2:(UITapGestureRecognizer *)sender {
    
    if (self.openTooBar) {
        [self showButton:self.lockScreen];
    }else{
        [self hiddeButton:self.lockScreen];
    }
    
    self.closeTimerGOTime = 0;
    self.openTooBar = !self.openTooBar;
}
-(void)hiddeButton:(BOOL)b
{
    self.toolBar.hidden = YES;
    self.takePhoto.hidden = YES;
    self.loackScreen.hidden = YES;
    self.shareButton.hidden = YES;
    self.headView.hidden = YES;
    
    self.progressView3.hidden = NO;
    
    if(b){
        
    }else{
        
    }
    
}
-(void)showButton:(BOOL)b
{
    if(b){
        self.toolBar.hidden = NO;
        self.takePhoto.hidden = NO;
        self.loackScreen.hidden = NO;
        self.shareButton.hidden = NO;
        self.headView.hidden = NO;
        
        self.progressView3.hidden = YES;
    }else{
        self.progressView3.hidden = NO;
        self.loackScreen.hidden = NO;
    }
    
}
-(void)closeTimerGO
{
    if (self.closeTimerGOTime==5) {
        [self hiddeButton: self.lockScreen];
    }
    self.closeTimerGOTime ++;
}
-(void)setHeadTitle:(NSString*)title
{
    self.headLab.text = title;
}
-(void)back
{
    [self fallButtonClick:self.fallButton];
}
-(NSString*)shotImagePath
{
    if (self.shotCurrenImg) {
        NSString *path =  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shotImage.png"];
        NSData *data = UIImagePNGRepresentation(self.shotCurrenImg);
        
        BOOL b = [data writeToFile:path atomically:YES];
        if (b) {
            return path;
        }
    }
    return @"";
    
}
-(void)shotSaveClick
{
    self.cutView.hidden = YES;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:self.cutImgv.image];
    } error:&error];
    self.successSeaveToPhoto.hidden = NO;
    if (error==nil) {
        self.successSeaveToPhoto.text = @"已保存到手机相册";
    }else{
        self.successSeaveToPhoto.text = @"保存失败";
    }
    [self performSelector:@selector(heddenSeave) withObject:nil afterDelay:1.5];
}
-(void)heddenSeave
{
    self.successSeaveToPhoto.hidden = YES;
}
//分享照片
-(void)shotShareClick
{
    self.cutView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(shareButtonClick:)]) {
        [self.delegate shareButtonClick:YES];
    }
}
-(void)shotCancleClick
{
    self.cutView.hidden = YES;
}
// 播放完成后
- (void)playbackFinished:(NSNotification *)notification {
    NSLog(@"视频播放完成通知");
    if ([self.delegate respondsToSelector:@selector(itemPlayToEnd)]) {
        [self.delegate itemPlayToEnd];
    }
}
-(void)setIsLive:(BOOL)isLive
{
    _isLive = isLive;
    if (isLive) {
        self.progressView.hidden = YES;
        self.progressView2.hidden = YES;
        self.progressView3.hidden = YES;
        self.progressSlider.hidden = YES;
        self.timeLab.textColor = UIColor.redColor;
        self.timeLab.text = @"Live";
    }
}
@end
