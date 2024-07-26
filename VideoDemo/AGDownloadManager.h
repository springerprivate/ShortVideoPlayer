//
//  AGDownloadManager.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 下载管理类
/*
 1、持有、管理视频资源下载
 2、做线程安全管理
 3、下载有优先级管理，对于当前要播放的，优先下载。同时下载做数量限制。有待下载队列管理。
 */
#import <Foundation/Foundation.h>
#import "AGDownloadDelegate.h"

@class AGDownload,AGPlayer;
@interface AGDownloadManager : NSObject

/// 单例
+ (instancetype)shareManager;

/// 下载资源  若资源已存在，直接通知 player 或 不再处理。
/// - Parameters:
///   - resourceUrl: 资源地址
///   - player: 可为空 若为空，则下载不关联播放器，且该下载可能会放在待下载队列中。
- (void)downloadWithResourceUrl:(NSURL *)resourceUrl player:(id <AGDownloadDelegate>)player;

/// 取消下载
/// - Parameter resourceUrl: 资源地址
- (void)cancelDownloadWithResourceUrl:(NSURL *)resourceUrl;

@end

