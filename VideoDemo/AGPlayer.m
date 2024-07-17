//
//  AGPlayer.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface AGPlayer ()

@property (nonatomic ,strong)AVPlayerItem *playerItem;//视频资源载体
@property (nonatomic ,strong)AVPlayer *player;//视频播放器

@end

@implementation AGPlayer

- (void)setIsCurrentPlay:(BOOL)isCurrentPlay{
    _isCurrentPlay = isCurrentPlay;
    
}

#pragma mark -AGDownloadDelegate
- (void)downloadFailure:(NSError *)error {
    
}
- (void)downloadSuccess:(NSURL *)url { 
    
}

@end
