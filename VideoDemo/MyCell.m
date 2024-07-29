//
//  MyCell.m
//  VideoDemo
//
//  Created by agui on 2024/7/17.
//

#import "MyCell.h"
#import "AGPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MyCell ()

@property (nonatomic,strong)UILabel *indexLab;
@property (nonatomic,strong)UILabel *statusLab;

@end

@implementation MyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.statusLab];
        [self addSubview:self.indexLab];
    }
    return self;
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    self.indexLab.text = @(indexPath.row).stringValue;
}

- (void)setPlayer:(AGPlayer *)player{
    // cell layer 清除原有显示。
    for (CALayer *layer in [self.contentView.layer sublayers]) {
        if ([layer isKindOfClass:[AVPlayerLayer class]]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
    NSLog(@"cell --- %@ %@ %@",NSStringFromSelector(_cmd),player.resourceUrl.absoluteString,[NSThread currentThread]);
    self.statusLab.text = @"";
    _player = player;
    _player.layerView = self.contentView;
    _player.onPlayProgressBlock = ^(float current, float total) {
//        NSLog(@"cell progress current == %f total == %f",current,total);
    };
    __weak typeof(self)weakSelf = self;
    _player.onPlayerStatusBlock = ^(AGPlayerStatus playerStatus) {// 在主线程中
        __strong typeof(weakSelf)strongSelf = weakSelf;
        NSLog(@"cell --- %@ %@ %@ %@",NSStringFromSelector(_cmd),player.resourceUrl.absoluteString,[NSThread currentThread],@(playerStatus).stringValue);
        NSString *statusStr = @"";
        switch (playerStatus) {
            case AGPlayerStatusLoading:{
                statusStr = @"资源加载中";
                break;
            }
            case AGPlayerStatusFailure:{
                statusStr = @"资源加载失败";
                break;
            }
            case AGPlayerStatusPlay:{
                statusStr = @"播放";
                break;
            }
            case AGPlayerStatusPause:{
                statusStr = @"暂停";
                break;
            }
            case AGPlayerStatusEndPlay:{
                statusStr = @"结束播放";
                break;
            }
            default:
                break;
        }
        strongSelf.statusLab.text = statusStr;
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
#pragma mark -lazy load
- (UILabel *)statusLab{
    if (nil == _statusLab) {
        _statusLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 150, 40)];
        _statusLab.textColor = [UIColor redColor];
        _statusLab.backgroundColor = [UIColor yellowColor];
    }
    return _statusLab;
}
- (UILabel *)indexLab{
    if (nil == _indexLab) {
        _indexLab = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 150, 40)];
        _indexLab.textColor = [UIColor blueColor];
        _indexLab.backgroundColor = [UIColor cyanColor];
    }
    return _indexLab;
}

@end
