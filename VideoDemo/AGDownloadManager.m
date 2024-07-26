//
//  AGDownloadManager.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGDownloadManager.h"
#import "AGDownload.h"
#import "AGVideoResourceCacheManager.h"

@interface AGDownloadManager (){
    dispatch_queue_t _serialQueue;
}

@property (nonatomic,strong)NSMutableArray <NSURL *>*downloadQueueMuArr;// 待下载队列
@property (nonatomic,strong)NSMutableArray <AGDownload *>*downloadingMuArr;// 下载

@end

@implementation AGDownloadManager

+ (instancetype)shareManager {
    static AGDownloadManager *downloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] init];
        downloadManager->_serialQueue = dispatch_queue_create("com.renrui.videoDwonloadManager.serialQueue", DISPATCH_QUEUE_SERIAL);
    });
    return downloadManager;
}

#pragma mark -public
- (void)downloadWithResourceUrl:(NSURL *)resourceUrl player:(id <AGDownloadDelegate>)player{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
        return;
    }
    dispatch_async(_serialQueue, ^{
        // 如果资源已存在，则不再处理
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:resourceUrl]];
        if (localUrl) {// 如果与播放器绑定，回调给播放器
            if (player && [player respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                [player agDownloadStatus:AGDownloadStatusSuccess localUrl:localUrl error:nil downloadBytes:0 totalBytes:0];
            }
            return;
        }
        for (AGDownload *download in self.downloadingMuArr) {
            if ([download.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                download.delegate = player;
                return;
            }
        }
        for (NSURL *url in self.downloadQueueMuArr) {
            if ([url.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                if (player || [self.downloadingMuArr count] < 5) {
                    [self.downloadQueueMuArr removeObject:url];
                    [self createDownloadWithResourceUrl:resourceUrl player:player];
                }
                return;
            }
        }
        if ([self.downloadingMuArr count] < 5) {
            [self createDownloadWithResourceUrl:resourceUrl player:player];
        }else{
            [self.downloadQueueMuArr addObject:resourceUrl];
        }
    });
}

- (void)reloadDownload{
    while ([self.downloadQueueMuArr count] && [self.downloadingMuArr count] < 5) {
        NSURL *url = [self.downloadQueueMuArr objectAtIndex:0];
        [self.downloadQueueMuArr removeObject:url];
        [self createDownloadWithResourceUrl:url player:nil];
    }
}

- (void)createDownloadWithResourceUrl:(NSURL *)resourceUrl player:(id <AGDownloadDelegate>)player{
    AGDownload *downLoad = [AGDownload new];
    downLoad.resourceUrl = resourceUrl;
    downLoad.delegate = player;
    __weak typeof(self) weakSelf = self;
    downLoad.downloadBlock = ^(AGDownload *download,NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf->_serialQueue, ^{
            if ([strongSelf.downloadingMuArr containsObject:download]) {
                [strongSelf.downloadingMuArr removeObject:download];
            }
            [strongSelf reloadDownload];
        });
    };
    [self.downloadingMuArr addObject:downLoad];
    [downLoad startDownload];
}

- (void)cancelDownloadWithResourceUrl:(NSURL *)resourceUrl{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
        return;
    }
    dispatch_async(_serialQueue, ^{
        for (AGDownload *download in self.downloadingMuArr) {
            if ([download.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                [download cancelDownload];
                return;
            }
        }
        for (NSURL *url in self.downloadQueueMuArr) {
            if ([url.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                [self.downloadQueueMuArr removeObject:url];
                return;
            }
        }
    });
}
#pragma mark -lazy load
- (NSMutableArray<NSURL *> *)downloadQueueMuArr{
    if (nil == _downloadQueueMuArr) {
        _downloadQueueMuArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _downloadQueueMuArr;
}
- (NSMutableArray<AGDownload *> *)downloadingMuArr{
    if (nil == _downloadingMuArr) {
        _downloadingMuArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _downloadingMuArr;
}

@end
