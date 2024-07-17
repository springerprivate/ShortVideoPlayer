//
//  AGPlayer.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 播放类  只能通过 AGPlayerManager 创建 分配 管理
#import <Foundation/Foundation.h>
#import "AGDownloadDelegate.h"

@interface AGPlayer : NSObject<AGDownloadDelegate>

@property (nonatomic,strong)NSURL *resourceUrl;
@property (nonatomic,assign)BOOL isCurrentPlay;// 当前播放

- (void)play;
- (void)pause;
- (void)replay;

@end

