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

// 播放控制
- (BOOL)playerPlayWithPlayer:(AGPlayer *)player errorBlock:(void(^)(NSError *))errorBlock;
- (BOOL)playerPauseWithPlayer:(AGPlayer *)player errorBlock:(void(^)(NSError *))errorBlock;
- (BOOL)playerReplayWithPlayer:(AGPlayer *)player errorBlock:(void(^)(NSError *))errorBlock;

- (void)pauseAll;

@end

