//
//  AGPlayer.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface AGPlayer (){
    BOOL _isReadyToplay;// 
}

@property (nonatomic ,strong)AVPlayerItem *playerItem;//视频资源载体
@property (nonatomic ,strong)AVPlayer *player;//视频播放器
@property (nonatomic ,strong)AVPlayerLayer *playerLayer;//视频播放器图形化载体
@property (nonatomic ,strong)id timeObserver;//视频播放器周期性调用的观察者

/// 播放状态
@property (nonatomic,assign)AGPlayerStatus playerStatus;

@end

@implementation AGPlayer

- (instancetype)init{
    self = [super init];
    if (self) {
        [self addNotify];
        self.playerStatus = AGPlayerStatusLoading;
    }
    return self;
}
- (void)setOnPlayerStatusBlock:(void (^)(AGPlayerStatus))onPlayerStatusBlock{
    _onPlayerStatusBlock = onPlayerStatusBlock;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_onPlayerStatusBlock) {
            self->_onPlayerStatusBlock(self.playerStatus);
        }
    });
}
#pragma mark -public
-(void)play
{
    NSLog(@"player --- %@ %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString,[NSThread currentThread]);
    if (_isReadyToplay) {
        if (0 == self.player.rate) {
            [self.player play];
        }
        self.playerStatus = AGPlayerStatusPlay;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayerStatusBlock) {
                self.onPlayerStatusBlock(AGPlayerStatusPlay);
            }
        });
    }else{
        
    }
}
- (void)pause
{
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (_isReadyToplay) {
        if (0 != self.player.rate) {
            [self.player pause];
        }
        self.playerStatus = AGPlayerStatusPause;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayerStatusBlock) {
                self.onPlayerStatusBlock(AGPlayerStatusPause);
            }
        });
    }
}
- (void)endPlay
{
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (_isReadyToplay) {
        if (0 != self.player.rate) {
            [self.player pause];
        }
        [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
        self.playerStatus = AGPlayerStatusEndPlay;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayerStatusBlock) {
                self.onPlayerStatusBlock(AGPlayerStatusEndPlay);
            }
        });
    }
}
- (BOOL)resouceDownloadFailure{
    return AGPlayerStatusFailure == self.playerStatus;
}
#pragma mark -AGDownloadDelegate
- (void)agDownloadStatus:(AGDownloadStatus)downloadStatus localUrl:(NSURL *)localUrl error:(NSError *)error downloadBytes:(int64_t)downloadBytes totalBytes:(int64_t)totalBytes
{
    if (AGDownloadStatusSuccess == downloadStatus) {
        if (self.playerItem) {
            [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
        }
        self.playerItem = [AVPlayerItem playerItemWithURL:localUrl];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self addProgressObserver];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.layerView) {
                [self.layerView.layer removeAllAnimations];
                self.playerLayer.frame = self.layerView.layer.frame;
                [self.layerView.layer addSublayer:self.playerLayer];
            }
        });
    }else if(AGDownloadStatusDownloading == downloadStatus || AGDownloadStatusUnkown == downloadStatus){//
        self.playerStatus = AGPlayerStatusLoading;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayerStatusBlock) {
                self.onPlayerStatusBlock(AGPlayerStatusLoading);
            }
        });
    }else{
        self.playerStatus = AGPlayerStatusFailure;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayerStatusBlock) {
                self.onPlayerStatusBlock(AGPlayerStatusFailure);
            }
        });
        
    }
}
#pragma mark -observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            NSLog(@"playerItem状态：：%ld", _playerItem.status);
            if (AVPlayerItemStatusReadyToPlay == self.playerItem.status) {
                _isReadyToplay = YES;
                NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.onReadyBlock) {
                        self.onReadyBlock(self);
                    }
                });
            }else if (AVPlayerItemStatusFailed == self.playerItem.status){
                _isReadyToplay = NO;
                self.playerStatus = AGPlayerStatusFailure;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.onPlayerStatusBlock) {
                        self.onPlayerStatusBlock(AGPlayerStatusFailure);
                    }
                });
            }
        }
    }
}
- (void)playerItemDidReachEnd
{// 播放结束
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (self.playerItem) {
        __weak typeof(self) weakSelf = self;
        [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            __weak typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.onPlayEndResetBlock) {
                strongSelf.onPlayEndResetBlock(strongSelf);
            }
        }];
    }
}
-(void)addProgressObserver
{// 播放监听
    if (_timeObserver) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_isReadyToplay) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds([strongSelf.playerItem duration]);
            //更新视频播放进度方法回调
            if (strongSelf.onPlayProgressBlock) {
                strongSelf.onPlayProgressBlock(current, total);
            }
        }
    }];
}
- (void)addNotify
{// 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}
#pragma mark -dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
    }
    NSLog(@"dealloc--- %@ %@",NSStringFromSelector(_cmd),self);
}

@end
