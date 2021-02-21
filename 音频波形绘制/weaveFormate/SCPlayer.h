//
//  SCPlayer.h
//  PudongNews
//
//  Created by 石川 on 2019/11/20.
//  Copyright © 2019 SHICHUAN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SCPlayerDelegate <NSObject>
@optional
-(void)shareButtonClick:(BOOL)b;
-(void)fullScreenButtonClick:(BOOL)b;
-(void)itemPlayToEnd;
-(void)timeRunAndTime:(NSInteger)runTime;
@end
@interface SCPlayer : UIView
@property (nonatomic, strong) UIView *supperView;
@property (nonatomic, weak) id<SCPlayerDelegate> delegate;
@property (nonatomic,strong)UIImage *shotCurrenImg;
@property (nonatomic,assign)BOOL isLive;
-(void)replaceCurrentUrl:(NSString*)urlStr;
-(void)scplayersotp;
-(void)screenChange;
-(void)pasuesc;
-(void)setHeadTitle:(NSString*)title;
-(NSString*)shotImagePath;
@end

NS_ASSUME_NONNULL_END
