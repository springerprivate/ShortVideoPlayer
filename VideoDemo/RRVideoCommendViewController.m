//
//  RRVideoCommendViewController.m
//  RenkangClass
//
//  Created by agui on 2024/7/15.
//

#import "RRVideoCommendViewController.h"

#import "AGPlayerManager.h"
#import "AGDownloadManager.h"

#import "MyCell.h"

@interface RRVideoCommendViewController ()<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *list;

@property (nonatomic, assign)BOOL isCurPlayerPause;
@property (nonatomic, strong)NSIndexPath *currentIndex;

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation RRVideoCommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    [self rrAddViews];
//    
    [self rrRequestData];
}
#pragma mark -base method
- (void)rrAddViews{
    [self.view addSubview:self.tableView];
}
- (void)rrRequestData{
    [self.list addObjectsFromArray:@[@"https://newplatform-1301970825.file.myqcloud.com/videos/2021-12-02/1638434498997867.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2021-12-29/1640776380665634.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/1702022756212823/5ESeKXRp6Pw3_rFydDdlF.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2022-09-22/1663836144457216.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-04-17/a6f75e05204f623de9012949e90d655f.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/2023-06-21/FcWzx1TW8feweafUduRjTa8873184b30a599256d848875e7b978b.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/16970901184861049/VU84dti7hOaOzADM-BptF.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-10-24/37236a3a8887564bb9e506e7bdf4cb5d.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/17007099789252384/gAb5tjhSBomngvgGWWdTI.MOV"]];
    [self.tableView reloadData];
}
#pragma mark tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.list[indexPath.row];
    NSLog(@"player --- %@ %@",NSStringFromSelector(_cmd),str);
    //填充视频数据
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyCell class]) forIndexPath:indexPath];
    cell.contentView.layer.borderWidth = 4;
    cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
    cell.indexPath = indexPath;
    AGPlayer *player = [[AGPlayerManager shareManager] playerWithResourceUrl:[NSURL URLWithString:str] errorBlock:nil];
    if (player) {
        cell.player = player;
        [[AGDownloadManager shareManager] downloadWithResourceUrl:[NSURL URLWithString:str] player:(id <AGDownloadDelegate>)player];
    }else{
        cell.statusLab.text = @"文件下载地址格式有问题";
    }
    return cell;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self handleCellDisplay];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self handleCellDisplay];
}
- (void)handleCellDisplay {
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self didDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}
- (void)didDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((_currentIndex && _currentIndex == indexPath)) {
        return;
    }
    _currentIndex = indexPath;
    NSLog(@"----------------------------------------");
    
    // 如果文件下载失败，则重新下载
    AGPlayer *player = ((MyCell *)cell).player;
    
    if ([player resouceDownloadFailure]) {
        [[AGDownloadManager shareManager] downloadWithResourceUrl:player.resourceUrl player:player];
    }
    
    [[AGPlayerManager shareManager] playerPlayWithPlayer:((MyCell *)cell).player];
    
    for (int index = 1; index < 3; index ++) {
        if ([self.list count] > (index + indexPath.row)) {
            NSString *str = self.list[indexPath.row + index];
            [[AGDownloadManager shareManager] downloadWithResourceUrl:[NSURL URLWithString:str] player:nil];
        }
    }
}
#pragma mark -lazyLoad
- (NSMutableArray<NSString *> *)list{
    if (nil == _list) {
        _list = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _list;
}
- (UITableView *)tableView{
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _tableView.backgroundColor = [UIColor yellowColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.pagingEnabled = YES;
        [_tableView registerClass:[MyCell class] forCellReuseIdentifier:NSStringFromClass([MyCell class])];
    }
    return _tableView;
}
@end
