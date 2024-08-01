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

@interface RRVideoCommendViewController ()<UITableViewDelegate, UITableViewDataSource>

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
    [self rrRequestData];
}
#pragma mark -base method
- (void)rrAddViews{
    [self.view addSubview:self.tableView];
}
- (void)rrRequestData{
    [self.list addObjectsFromArray:@[@"https://newplatform-1301970825.file.myqcloud.com/videos/2022-03-11/1646986592660745.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2022-09-30/1664524971396804.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/2023-06-29/PC7tirXkavzQL4Uh-nafw83077f89e2bc6750278f974d29285647.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/2023-08-02/QhkIu2op74yD6vVTqi5DD0c8ec07f54b723df3130762a8792c9d3.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/16939956075405350/0R-mnW19n-oK7YaHF3qoa.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/16949389328163566/WjwropCbxp6Qt1z6SjKjZ.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/16951160657838334/C0GTJXqspC-YmFBzNXQup.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-10-07/bdf9fbccc7a470c551b704b7568c10d1.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-11-11/b050b08a8ef7cc352469f9877611e4a0.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-11-25/b76b2c72e2aff74a185f561f1ca16cd8.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2021-12-02/1638434498997867.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2021-12-29/1640776380665634.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/1702022756212823/5ESeKXRp6Pw3_rFydDdlF.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/videos/2022-09-22/1663836144457216.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-04-17/a6f75e05204f623de9012949e90d655f.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/2023-06-21/FcWzx1TW8feweafUduRjTa8873184b30a599256d848875e7b978b.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/16970901184861049/VU84dti7hOaOzADM-BptF.mp4",
                                     @"https://newplatform-1301970825.file.myqcloud.com/weidong_test/2023-10-24/37236a3a8887564bb9e506e7bdf4cb5d.mp4",
                                     @"https://tousubiaoyang-1301970825.file.myqcloud.com/shop/17007099789252384/gAb5tjhSBomngvgGWWdTI.MOV"]];
    [self.tableView reloadData];
    if ([self.list count]) {// 播放
        dispatch_async(dispatch_get_main_queue(), ^{
            MyCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (cell) {
                [self didDisplayCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        });
    }
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
    NSLog(@"---------------------------------------- %@ %@ %@",str,indexPath,NSStringFromSelector(_cmd));
    //填充视频数据
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MyCell class]) forIndexPath:indexPath];
//    cell.contentView.layer.borderWidth = 4;
//    cell.contentView.layer.borderColor = [UIColor redColor].CGColor;
    cell.indexPath = indexPath;
    AGPlayer *player = [[AGPlayerManager shareManager] playerWithResourceUrl:[NSURL URLWithString:str]];
//    [[AGDownloadManager shareManager] createDownloadWithResourceUrl:[NSURL URLWithString:str] result:^(AGDownload *download) {
//        player.download = download;
//    }];
    cell.player = player;
    return cell;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self handleCellDisplay];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self handleCellDisplay];
}
- (void)handleCellDisplay {
    NSLog(@"---------------------------------------- handleCellDisplay    %@",[self.tableView visibleCells]);
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
    BOOL downDirection = YES;
    if (_currentIndex) {
        if (indexPath.row < _currentIndex.row) {// 向上
            downDirection = NO;
        }
    }
    
    _currentIndex = indexPath;
    AGPlayer *player = ((MyCell *)cell).player;
    NSLog(@"----------------------------------------didDisplayCell %@ %@ ",indexPath,player.resourceUrl.absoluteString);
    NSString *str = self.list[indexPath.row];
    [[AGDownloadManager shareManager] createDownloadWithResourceUrl:[NSURL URLWithString:str] result:^(AGDownload *download) {
        player.download = download;
        [[AGPlayerManager shareManager] playerPlayWithPlayer:((MyCell *)cell).player];
        
        NSInteger preIndex = 0;
        for (int index = 1; index < 6; index ++) {
            if (downDirection) {
                preIndex = indexPath.row + index;
            }else{
                preIndex = indexPath.row - index;
            }
            if (([self.list count] > preIndex) && (preIndex >= 0)) {
                NSString *str = self.list[preIndex];
                [[AGDownloadManager shareManager] predownloadWithResourceUrl:[NSURL URLWithString:str]];
            }else{
                break;
            }
        }
    }];
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
//        _tableView.estimatedRowHeight = 0;
//        _tableView.estimatedSectionHeaderHeight = 0;
//        _tableView.estimatedSectionFooterHeight = 0;
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
