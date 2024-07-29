//
//  AGDownloadManager.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 下载管理类
/*
 1、持有、管理资源下载
 2、做线程安全管理
 3、下载优先级管理，对于当前要播放的，取消正在下载项，优先下载当前播放资源。
 4、下载完成（成功或者失败），取消持有关系
 5、预下载，存放在下载队列中。当前下载完成或者没有当前下载项。取下载队列第一项进行下载
 */
#import <Foundation/Foundation.h>

@class AGDownload;
@interface AGDownloadManager : NSObject

/// 单例
+ (instancetype)shareManager;

/// 下载创建
/// - Parameters:
///   - resourceUrl: 下载资源
///   - onResultBlock: 下载创建回调  如果资源已存在，download 为空，切不会将下载放到下载队列中 （因为做了线程安全管理，所以用block返回） 若返回download为nil，说明资源已存在
- (void)createDownloadWithResourceUrl:(NSURL *)resourceUrl result:(void(^)(AGDownload *download))onResultBlock;

/// 预下载
/// - Parameter resourceUrl: 下载资源
- (void)predownloadWithResourceUrl:(NSURL *)resourceUrl;

@end

