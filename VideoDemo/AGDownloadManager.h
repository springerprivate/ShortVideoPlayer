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
 3、下载有优先级管理，对于当前要播放的，优先下载。 如果取消下载，则将下载移到待下载队列中管理。
 4、下载完成，取消持有关系
 */
#import <Foundation/Foundation.h>

@class AGDownload;
@interface AGDownloadManager : NSObject

/// 单例
+ (instancetype)shareManager;

/// 下载创建
/// - Parameters:
///   - resourceUrl: 下载资源
///   - onResultBlock: 下载创建回调  如果资源已存在，download 为空，切不会将下载放到下载队列中
- (void)createDownloadWithResourceUrl:(NSURL *)resourceUrl result:(void(^)(AGDownload *download))onResultBlock;

/// 预下载
/// - Parameter resourceUrl: 下载资源
- (void)predownloadWithResourceUrl:(NSURL *)resourceUrl;

@end

