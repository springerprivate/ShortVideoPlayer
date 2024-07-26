//
//  MyCell.m
//  VideoDemo
//
//  Created by agui on 2024/7/17.
//

#import "MyCell.h"
#import "AGPlayer.h"

@interface MyCell ()

@property (nonatomic,strong)UILabel *indexLab;

@end

@implementation MyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.statusLab];
        [self.contentView addSubview:self.indexLab];
    }
    return self;
}
- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
    self.indexLab.text = @(indexPath.row).stringValue;
}

- (void)setPlayer:(AGPlayer *)player{
    NSLog(@"player --- %@ %@ %@",NSStringFromSelector(_cmd),player.resourceUrl.absoluteString,[NSThread currentThread]);
    self.statusLab.text = @"";
    _player = player;
    _player.layerView = self.contentView;
    _player.onPlayProgressBlock = ^(float current, float total) {
//        NSLog(@"cell progress current == %f total == %f",current,total);
    };
    __weak typeof(self)weakSelf = self;
    _player.onPlayerStatusBlock = ^(AGPlayerStatus playerStatus) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
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
