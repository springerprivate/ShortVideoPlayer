//
//  AGDownloadDelegate.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,AGDownloadStatus) {
    AGDownloadStatusUnkown,
    AGDownloadStatusDownloading,// 下载中
    AGDownloadStatusSuccess,// 成功
    AGDownloadStatusCancel,// 取消
    AGDownloadStatusFailure,// 失败
    AGDownloadStatusStoreFailure,// 存放失败
    AGDownloadStatusReplace,// 代理被替换
};

// 下载代理
@protocol AGDownloadDelegate <NSObject>

/// 下载回调
/// - Parameters:
///   - downloadStatus: 下载状态
///   - localUrl: 下载成功后本地资源
///   - error: 错误
///   - downloadBytes: 已下载文件大小
///   - totalBytes: 文件大小
- (void)agDownloadStatus:(AGDownloadStatus)downloadStatus localUrl:(NSURL *)localUrl error:(NSError *)error downloadBytes:(int64_t)downloadBytes totalBytes:(int64_t)totalBytes;;

@end

