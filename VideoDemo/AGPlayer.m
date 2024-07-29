//
//  AGPlayer.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "AGVideoResourceCacheManager.h"

@interface AGPlayer (){
    BOOL _isReadyToplay;// 
    BOOL _playFlag;
}

@property (nonatomic ,strong)AVPlayerItem *playerItem;//视频资源载体
@property (nonatomic ,strong)AVPlayer *player;//视频播放器
@property (nonatomic ,strong)AVPlayerLayer *playerLayer;//视频播放器图形化载体
@property (nonatomic ,strong)id timeObserver;//视频播放器周期性调用的观察者

/// 播放状态
@property (nonatomic,assign)AGPlayerStatus playerStatus;

@end

@implementation AGPlayer

#pragma mark -set
- (void)setOnPlayerStatusBlock:(void (^)(AGPlayerStatus))onPlayerStatusBlock
{
    _onPlayerStatusBlock = onPlayerStatusBlock;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.onPlayerStatusBlock) {
            self.onPlayerStatusBlock(self.playerStatus);
        }
    });
}
- (void)setDownload:(AGDownload *)download
{
    _download = download;
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (_download) {
        __weak typeof(self)weakSelf = self;
        _download.onDownloadBlock = ^(AGDownloadStatus downloadStatus, NSError *error) {// 下载回调
            __strong typeof(weakSelf)strongSelf = weakSelf;
            switch (downloadStatus) {
                case AGDownloadStatusSuccess:{// 下载成功
                    strongSelf->_download = nil;
                    strongSelf.playerItem = nil;
                    [strongSelf createPlayer];
                    break;
                }
                case AGDownloadStatusFailure:
                case AGDownloadStatusStoreFailure:
                case AGDownloadStatusCancel:{//下载失败
                    strongSelf->_download = nil;
                    strongSelf.playerItem = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf.playerStatus = AGPlayerStatusFailure;
                        if (strongSelf.onPlayerStatusBlock) {
                            strongSelf.onPlayerStatusBlock(AGPlayerStatusFailure);
                        }
                    });
                    break;
                }
                case AGDownloadStatusDownloading:{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        strongSelf.playerStatus = AGPlayerStatusLoading;
                        if (strongSelf.onPlayerStatusBlock) {
                            strongSelf.onPlayerStatusBlock(AGPlayerStatusLoading);
                        }
                    });
                }
                    
                default:
                    break;
            }
        };
        [_download reportDownloadStatus];
    }else{
        self.playerItem = nil;
        [self createPlayer];
    }
}
#pragma mark -public
-(void)play
{
    _playFlag = YES;
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
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
    }
}
- (void)pause
{
    _playFlag = NO;
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
    _playFlag = NO;
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
- (BOOL)playFlag{
    return _playFlag;
}

#pragma mark - create player
- (void)createPlayer{
    if (!self.player) {//
        self.playerItem = [AVPlayerItem playerItemWithURL:[AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:self.resourceUrl]]];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        [self addProgressObserver];
        [self addNotifyWithObject:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.layerView) {
            self.playerLayer.frame = self.layerView.layer.frame;
            [self.layerView.layer addSublayer:self.playerLayer];
        }
    });
}
#pragma mark -observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            NSLog(@"player --- playerItem状态：：%ld  %@", _playerItem.status,self.resourceUrl.absoluteString);
            if (AVPlayerItemStatusReadyToPlay == self.playerItem.status) {
                _isReadyToplay = YES;
                if (self.onReadyBlock) {
                    self.onReadyBlock(self);
                }
            }else if (AVPlayerItemStatusFailed == self.playerItem.status){
                _isReadyToplay = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.playerStatus = AGPlayerStatusFailure;
                    if (self.onPlayerStatusBlock) {
                        self.onPlayerStatusBlock(AGPlayerStatusFailure);
                    }
                });
            }
        }
    }
}
- (void)playerItemDidReachEnd:(NSNotification *)notify
{// 播放结束
    if (notify.object && notify.object == self.playerItem) {
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
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_isReadyToplay) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds([strongSelf.playerItem duration]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.onPlayProgressBlock) {//更新视频播放进度方法回调
                    strongSelf.onPlayProgressBlock(current, total);
                }
            });
        }
    }];
}
- (void)addNotifyWithObject:(AVPlayerItem *)playerItem
{// 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
}
#pragma mark -dealloc
- (void)dealloc
{
    NSLog(@"player --- dealloc--- %@ %@",NSStringFromSelector(_cmd),self);
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
    }
}

@end
