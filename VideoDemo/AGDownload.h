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

@interface AGDownload : NSObject

@property (nonatomic,strong)NSURL *resourceUrl;// 资源地址
@property (nonatomic,weak)id<AGDownloadDelegate> delegate;// 播放类 1、创建下载类是设置  2、替换设置 设置时，应回传当前下载状态
@property (nonatomic,copy)void(^downloadBlock)(AGDownload *download,NSError *error);// 下载完成或失败回调 回调给下载管理类（下载管理管理该下载）

- (void)startDownload;

- (void)cancelDownload;

@end

