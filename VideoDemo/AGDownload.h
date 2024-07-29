//
//  AGDownload.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 下载类
/*
 下载类只能在下载管理类中创建，管理。
 下载管理类、player 会持有下载类。
 下载管理类会持有下载类，当下载完成（成功），从下载管理类中移除 只能在下载管理类中创建
 播放类持有（如果资源没有下载）下载类
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,AGDownloadStatus) {
    AGDownloadStatusUnknow,// 未知
    AGDownloadStatusDownloading,// 下载中
    AGDownloadStatusSuccess,// 下载成功
    AGDownloadStatusFailure,// 下载失败
    AGDownloadStatusStoreFailure,// 资源存放失败
    AGDownloadStatusCancel,// 取消下载
};

@interface AGDownload : NSObject

@property (nonatomic,strong)NSURL *resourceUrl;// 资源地址

@property (nonatomic,copy)void(^onEndDownloadBlock)(AGDownloadStatus downloadStatus,AGDownload *download,NSError *error);// 下载回调 回调给下载管理类（管理下载）
@property (nonatomic,copy)void(^onDownloadBlock)(AGDownloadStatus downloadStatus,NSURL *localUrl,NSError *error);// 下载状态回调，回调给 player

/// 开始下载
- (void)startDownload;

/// 取消下载
- (void)cancelDownload;

/// 下载状态上报  主要是上报给 显示
- (void)reportDownloadStatus;

@end

