//
//  AGDownload.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 下载类
/*
 下载管理类会持有下载类，当下载完成（成功或者失败），从下载管理类中移除 只能在下载管理类中创建
 下载类弱持有播放类，将下载情况传递给播放类
 
 */

#import <Foundation/Foundation.h>
#import "AGDownloadDelegate.h"
#import "AGDataTool.h"

typedef NS_ENUM(NSInteger,AGDownloadStatus) {
    AGDownloadStatusUnkown,
    AGDownloadStatusSuccess,// 成功
    AGDownloadStatusCancel,// 取消
    AGDownloadStatusFailure,// 失败
    AGDownloadStatusStoreFailure,// 存放失败
};

@interface AGDownload : NSObject

@property (nonatomic,strong)NSURL *resourceUrl;// 资源地址
@property (nonatomic,weak)id<AGDownloadDelegate> delegate;// 播放类
@property (nonatomic,copy)void(^downloadBlock)(AGDownload *download,NSError *error);// 下载管理类

- (void)startDownload;

- (void)cancelDownload;

@end

