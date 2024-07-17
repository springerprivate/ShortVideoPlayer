//
//  ViewController.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic ,strong) AVURLAsset           *urlAsset;               //视频资源
@property (nonatomic ,strong) AVPlayerItem         *playerItem;             //视频资源载体
@property (nonatomic ,strong) AVPlayer             *player;                 //视频播放器
@property (nonatomic ,strong) AVPlayerLayer        *playerLayer;            //视频播放器图形化载体

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    
    
    NSURL *url = [NSURL URLWithString:@"https://newplatform-1301970825.file.myqcloud.com/videos/2022-02-18/1645164602863334.mp4"];
//    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://newplatform-1301970825.file.myqcloud.com/videos/2022-02-18/1645164602863334.mp4"]];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoplayback" ofType:@"mp4"];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    self.playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    //观察playerItem.status属性
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    //切换当前AVPlayer播放器的视频源
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
//    
//    
//    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//    _playerLayer.frame = self.view.bounds;
//    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////    _playerLayer.hidden = NO;
//    [self.view.layer addSublayer:_playerLayer];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self playerTest];
}

- (void)playerTest{
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = self.view.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //    _playerLayer.hidden = NO;
        [self.view.layer addSublayer:_playerLayer];
//    self.urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:@"https://newplatform-1301970825.file.myqcloud.com/videos/2022-02-18/1645164602863334.mp4"] options:nil];
//    //设置AVAssetResourceLoaderDelegate代理
//    [self.urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    //初始化AVPlayerItem
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

// 监听资源加载过程
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            NSLog(@"播放状态：：%ld", _playerItem.status);
            /*
             AVPlayerItemStatusUnknown = 0,
             AVPlayerItemStatusReadyToPlay = 1,
             AVPlayerItemStatusFailed = 2
             */
            if (AVPlayerItemStatusReadyToPlay == self.playerItem.status) {
                
            }else if (AVPlayerItemStatusReadyToPlay == self.playerItem.status){
                
            }
        }
    }
}


@end
