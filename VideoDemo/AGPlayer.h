//
//  AGPlayer.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 播放类  只能通过 AGPlayerManager 创建 分配 管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AGDownloadDelegate.h"

typedef NS_ENUM(NSInteger,AGPlayerStatus) {
    AGPlayerStatusLoading,// 加载资源
    AGPlayerStatusFailure,// 失败
    AGPlayerStatusPlay,// 播放
    AGPlayerStatusPause,// 暂停
    AGPlayerStatusEndPlay,// 结束播放
};

@interface AGPlayer : NSObject<AGDownloadDelegate>

@property (nonatomic,weak)UIView *layerView;// 盛放playerlayer

/// 资源远程地址， 只作为标识
@property (nonatomic,strong)NSURL *resourceUrl;

#pragma mark - 回调给 显示 （与当前播放状态、进度 有关）
/// 播放状态回调 （包含了资源加载）
@property (nonatomic,copy)void(^onPlayerStatusBlock)(AGPlayerStatus playerStatus);
/// 播放进度回调
@property (nonatomic,copy)void(^onPlayProgressBlock)(float current,float total);

#pragma mark -回调给 播放管理器（与播放控制有关）
/// 播放完成后 seek到zero
@property (nonatomic,copy)void(^onPlayEndResetBlock)(AGPlayer *player);
/// 资源准备完成
@property (nonatomic,copy)void(^onReadyBlock)(AGPlayer *player);


///  资源下载是否失败
- (BOOL)resouceDownloadFailure;

#pragma mark -只能在 播放器管理类里调用
/// 播放
- (void)play;
/// 暂停（切后台）
- (void)pause;
/// 结束播放
- (void)endPlay;

@end

