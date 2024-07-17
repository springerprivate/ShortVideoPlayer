//
//  AGDownloadManager.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 下载管理类
/*
 
 */
#import <Foundation/Foundation.h>
#import "AGDownloadDelegate.h"

@class AGDownload,AGPlayer;
@interface AGDownloadManager : NSObject

/// 单例
+ (instancetype)shareManager;

/// 下载资源
/// - Parameters:
///   - resourceUrl: 资源地址
///   - player: 可为空 若为空，则下载不关联播放器，且该下载可能会放在待下载队列中
- (void)downloadWithResourceUrl:(NSURL *)resourceUrl player:(id <AGDownloadDelegate>)player;

/// 取消下载
/// - Parameter resourceUrl: 资源地址
- (void)cancelDownloadWithResourceUrl:(NSURL *)resourceUrl;

@end

