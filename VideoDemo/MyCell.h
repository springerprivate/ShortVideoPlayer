//
//  MyCell.h
//  VideoDemo
//
//  Created by agui on 2024/7/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AGPlayer;
@interface MyCell : UITableViewCell

@property (nonatomic,strong)AGPlayer *player;

@property (nonatomic,strong)NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
