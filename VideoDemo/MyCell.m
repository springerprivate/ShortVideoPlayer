//
//  MyCell.m
//  VideoDemo
//
//  Created by agui on 2024/7/17.
//

#import "MyCell.h"

#import "AGPlayerManager.h"

#import "AGPlayer.h"

@interface MyCell ()

@property (nonatomic ,strong)AVPlayerLayer *playerLayer;//视频播放器图形化载体

@end

@implementation MyCell

- (void)setPlayer:(AGPlayer *)player{
    _player = player;
    _player.layerView = self.contentView;
    _player.onPlayProgressBlock = ^(float current, float total) {
        NSLog(@"cell progress current == %f total == %f",current,total);
    };
    __weak typeof(_player)weakPlayer = _player;
    _player.onPlayerStatusBlock = ^(AGPlayerStatus playerStatus) {
        __strong typeof(weakPlayer)strongPlayer = weakPlayer;
        if (AGPlayerStatusReady == playerStatus) {
            [[AGPlayerManager shareManager] playerPlayWithPlayer:strongPlayer];
        }
    };
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
