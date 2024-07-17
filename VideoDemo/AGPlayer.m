//
//  AGPlayer.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGPlayer.h"
#import <AVFoundation/AVFoundation.h>


@interface AGPlayer (){
    BOOL _currentPlayer;// 当前播放
    BOOL _isReadyToplay;// 
}

@property (nonatomic ,strong)AVPlayerItem *playerItem;//视频资源载体
@property (nonatomic ,strong)AVPlayer *player;//视频播放器
@property (nonatomic ,strong)AVPlayerLayer *playerLayer;//视频播放器图形化载体
@property (nonatomic ,strong)id timeObserver;//视频播放器周期性调用的观察者

@end

@implementation AGPlayer

#pragma mark -AGDownloadDelegate
- (void)downloadFailure:(NSError *)error {
    self.playerStatus = AGPlayerStatusFailure;
    if (self.onPlayerStatusBlock) {
        self.onPlayerStatusBlock(AGPlayerStatusFailure);
    }
}
- (void)downloadSuccess:(NSURL *)url {
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    if (self.layerView) {
        [self.layerView.layer addSublayer:self.playerLayer];
    }
}
- (void)setLayerView:(UIView *)layerView{
    _layerView = layerView;
    if (self.playerLayer) {
        [_layerView.layer addSublayer:self.playerLayer];
    }
}

-(void)play{
    _currentPlayer = YES;
    if (_isReadyToplay) {
        if (0 == self.player.rate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player play];
                self.playerStatus = AGPlayerStatusPlay;
                if (self.onPlayerStatusBlock) {
                    self.onPlayerStatusBlock(AGPlayerStatusPlay);
                }
            });
        }
    }
}
- (void)pause{
    _currentPlayer = NO;
    if (_isReadyToplay) {
        if (0 != self.player.rate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player pause];
            });
        }
        self.playerStatus = AGPlayerStatusPause;
        if (self.onPlayerStatusBlock) {
            self.onPlayerStatusBlock(AGPlayerStatusPause);
        }
    }
}
- (void)replay{
    _currentPlayer = YES;
    if (_isReadyToplay) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (0 != self.player.rate) {
                [self.player pause];
            }
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        });
        self.playerStatus = AGPlayerStatusPlay;
        if (self.onPlayerStatusBlock) {
            self.onPlayerStatusBlock(AGPlayerStatusPlay);
        }
    }
}
#pragma mark -observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            NSLog(@"播放状态：：%ld", _playerItem.status);
            if (AVPlayerItemStatusReadyToPlay == self.playerItem.status) {
                _isReadyToplay = YES;
                self.playerStatus = AGPlayerStatusReady;
                if (self.onPlayerStatusBlock) {
                    self.onPlayerStatusBlock(AGPlayerStatusReady);
                }
            }else if (AVPlayerItemStatusFailed == _playerItem.status){
                _isReadyToplay = NO;
                self.playerStatus = AGPlayerStatusFailure;
                if (self.onPlayerStatusBlock) {
                    self.onPlayerStatusBlock(AGPlayerStatusFailure);
                }
            }
        }
    }
}
-(void)addProgressObserver{
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
    }
    __weak typeof(self) weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf->_isReadyToplay) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds([strongSelf.playerItem duration]);
            //重新播放视频
            if(total == current) {
                if (strongSelf->_currentPlayer) {
                    [strongSelf replay];
                }
            }
            //更新视频播放进度方法回调
            if (strongSelf.onPlayProgressBlock) {
                strongSelf.onPlayProgressBlock(current, total);
            }
        }
    }];
}
#pragma mark -dealloc
- (void)dealloc{
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
    }
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),self);
}

@end
