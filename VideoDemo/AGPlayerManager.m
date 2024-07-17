//
//  AGPlayerManager.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGPlayerManager.h"
#import "AGPlayer.h"

@interface AGPlayerManager (){
    AGPlayer *_currentPlayPlayer;//当前播放类
}

@property (nonatomic,strong)NSMutableArray <AGPlayer *>* playerMuArr;// 持有播放类，做数量限制 时间越近，坐标越靠前

@end

@implementation AGPlayerManager

+ (instancetype)shareManager {
    static AGPlayerManager *playerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[self alloc] init];
    });
    return playerManager;
}

- (AGPlayer *)playerWithResourceUrl:(NSURL *)resourceUrl errorBlock:(void (^)(NSError *))errorBlock{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
        if (errorBlock) {
            errorBlock([NSError errorWithDomain:@"" code:-100 userInfo:@{NSLocalizedDescriptionKey:@"获取播放器失败",NSLocalizedFailureReasonErrorKey:@"url 无效"}]);
        }
        return nil;
    }
    for (AGPlayer *player in self.playerMuArr) {
        if ([player.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
            // 优先级调整
            AGPlayer *priorPlayer = player;
            [self.playerMuArr removeObject:priorPlayer];
            [self.playerMuArr insertObject:priorPlayer atIndex:0];
            return player;
        }
    }
    return [self createNewPlayerWithResourceUrl:resourceUrl];
}

- (BOOL)playerPlayWithPlayer:(AGPlayer *)player{
    if (_currentPlayPlayer) {
        if (_currentPlayPlayer == player) {
            [_currentPlayPlayer play];
            return YES;
        }else{
            [_currentPlayPlayer pause];
        }
    }
    for (AGPlayer *tmpPlayer in self.playerMuArr) {
        if (tmpPlayer == player) {
            [player play];
            _currentPlayPlayer = player;
            return YES;
        }
    }
    return NO;
}
- (BOOL)playerPauseWithPlayer:(AGPlayer *)player{
    if (_currentPlayPlayer && _currentPlayPlayer == player) {
        [_currentPlayPlayer pause];
        return YES;
    }
    for (AGPlayer *tmpPlayer in self.playerMuArr) {
        if (tmpPlayer == player) {
            [player pause];
            _currentPlayPlayer = nil;
            return YES;
        }
    }
    return NO;
}
- (BOOL)playerReplayWithPlayer:(AGPlayer *)player{
    if (_currentPlayPlayer) {
        if (_currentPlayPlayer == player) {
            [_currentPlayPlayer replay];
            return YES;
        }else{
            [_currentPlayPlayer pause];
        }
    }
    for (AGPlayer *tmpPlayer in self.playerMuArr) {
        if (tmpPlayer == player) {
            [player replay];
            _currentPlayPlayer = player;
            return YES;
        }
    }
    return NO;
}
- (void)pauseAll{
    for (AGPlayer *player in self.playerMuArr) {
        [player pause];
    }
    _currentPlayPlayer = nil;
}

- (AGPlayer *)createNewPlayerWithResourceUrl:(NSURL *)resouceUrl{
    AGPlayer *player = [AGPlayer new];
    player.resourceUrl = resouceUrl;
    [self.playerMuArr insertObject:player atIndex:0];
    // 长度限制
    while ([self.playerMuArr count] >= 10) {
        [self.playerMuArr removeLastObject];
    }
    return player;
}

#pragma mark -lazy load
- (NSMutableArray<AGPlayer *> *)playerMuArr{
    if (nil == _playerMuArr) {
        _playerMuArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _playerMuArr;
}

@end
