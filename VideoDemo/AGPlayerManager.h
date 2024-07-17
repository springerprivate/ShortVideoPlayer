//
//  AGPlayerManager.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 播放器管理类 持有 分配 管理 播放类 AGPlayer  播放、暂停、移除
#import <Foundation/Foundation.h>

@class AGPlayer;
@interface AGPlayerManager : NSObject

/// 单例
+ (instancetype)shareManager;

/// 获取播放类  对url做简单校验
/// - Parameter resourceUrl: 资源地址
- (AGPlayer *)playerWithResourceUrl:(NSURL *)resourceUrl errorBlock:(void(^)(NSError *))errorBlock;

/// 开始播放
/// - Parameter player: 播放器
- (BOOL)playerPlayWithPlayer:(AGPlayer *)player;

/// 暂停播放
/// - Parameter player: 播放器
- (BOOL)playerPauseWithPlayer:(AGPlayer *)player;

/// 重新播放
/// - Parameter player: 播放器
- (BOOL)playerReplayWithPlayer:(AGPlayer *)player;

/// 暂停所有
- (void)pauseAll;

@end

