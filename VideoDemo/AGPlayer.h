//
//  AGPlayer.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 播放类  只能通过 AGPlayerManager 创建 分配 管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AGDownloadDelegate.h"

typedef NS_ENUM(NSInteger,AGPlayerStatus) {
    AGPlayerStatusLoading,// 加载资源
    AGPlayerStatusFailure,// 失败
    AGPlayerStatusReady,// 准备好
    AGPlayerStatusPlay,// 播放
    AGPlayerStatusPause,// 暂停
};

@interface AGPlayer : NSObject<AGDownloadDelegate>

@property (nonatomic,weak)UIView *layerView;// 盛放playerlayer

/// 播放状态
@property (nonatomic,assign)AGPlayerStatus playerStatus;

/// 资源远程地址， 只作为标识
@property (nonatomic,strong)NSURL *resourceUrl;

/// 播放状态回调 （包含了资源加载）
@property (nonatomic,copy)void(^onPlayerStatusBlock)(AGPlayerStatus playerStatus);

/// 播放进度回调
@property (nonatomic,copy)void(^onPlayProgressBlock)(float current,float total);

/// 播放 内部会做逻辑处理
- (void)play;

/// 暂停 内部会做逻辑处理
- (void)pause;

/// 从新播放 内部会做处理
- (void)replay;

@end

