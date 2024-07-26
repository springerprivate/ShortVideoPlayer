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
    dispatch_queue_t _serialQueue;
}

@property (nonatomic,strong)NSMutableArray <AGPlayer *>* playerMuArr;// 持有播放类，做数量限制 时间越近，坐标越靠前

@end

@implementation AGPlayerManager

+ (instancetype)shareManager {
    static AGPlayerManager *playerManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[self alloc] init];
        playerManager->_serialQueue = dispatch_queue_create("com.renrui.playerManager.serialQueue", DISPATCH_QUEUE_SERIAL);
    });
    return playerManager;
}
#pragma mark -public
- (void)playerPlayWithPlayer:(AGPlayer *)player
{
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),player.resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        if (self->_currentPlayPlayer && self->_currentPlayPlayer != player) {
            NSLog(@"player --- %@ %@ ---- ",NSStringFromSelector(_cmd),self->_currentPlayPlayer.resourceUrl.absoluteString);
            [self->_currentPlayPlayer endPlay];
        }
        self->_currentPlayPlayer = player;
        NSLog(@"player --- %@ %@ ----",NSStringFromSelector(_cmd),player.resourceUrl.absoluteString);
        [self->_currentPlayPlayer play];
    });
}
- (void)playerPause
{
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),_currentPlayPlayer.resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        if (self->_currentPlayPlayer) {
            NSLog(@"player --- %@ %@----",NSStringFromSelector(_cmd),self->_currentPlayPlayer.resourceUrl.absoluteString);
            [self->_currentPlayPlayer pause];
        }
    });
}
- (void)playerEndplay
{
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),_currentPlayPlayer.resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        if (self->_currentPlayPlayer) {
            NSLog(@"player --- %@ %@---",NSStringFromSelector(_cmd),self->_currentPlayPlayer.resourceUrl.absoluteString);
            [self->_currentPlayPlayer endPlay];
        }
    });
}
- (AGPlayer *)playerWithResourceUrl:(NSURL *)resourceUrl errorBlock:(void (^)(NSError *))errorBlock{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
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
- (AGPlayer *)createNewPlayerWithResourceUrl:(NSURL *)resouceUrl{
    AGPlayer *player = [AGPlayer new];
    player.resourceUrl = resouceUrl;
    __weak typeof(self) weakSelf = self;
    player.onPlayEndResetBlock = ^(AGPlayer *player) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf playerPlayWithPlayer:player];
    };
    player.onReadyBlock = ^(AGPlayer *player) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf playerPlayWithPlayer:player];
    };
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
