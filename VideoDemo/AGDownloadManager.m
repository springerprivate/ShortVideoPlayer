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

@property (nonatomic,strong)NSMutableArray <AGDownload *>*downloadQueueMuArr;// 待下载队列

@property (nonatomic,strong)AGDownload *currentDownload;// 当前下载

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
#pragma mark -set
- (void)setCurrentDownload:(AGDownload *)currentDownload{
    _currentDownload = currentDownload;
    [_currentDownload startDownload];
}
#pragma mark -public
- (void)createDownloadWithResourceUrl:(NSURL *)resourceUrl result:(void (^)(AGDownload *))onResultBlock{
    NSLog(@"downloadManager --- %@ %@",NSStringFromSelector(_cmd),resourceUrl.absoluteString);
    dispatch_async(dispatch_queue_create("com.renrui.videoDwonloadManager.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
        // 如果资源已存在，则不再处理
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:resourceUrl]];
        if (localUrl) {// 如果与播放器绑定，回调给播放器
            if (onResultBlock) {
                onResultBlock(nil);
            }
            return;
        }
        if (self.currentDownload) {
            if ([self.currentDownload.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                if (onResultBlock) {
                    onResultBlock(self.currentDownload);
                }
                return;
            }else{
                [self.currentDownload cancelDownload];
            }
        }
        for (AGDownload *download in self.downloadQueueMuArr) {
            if ([download.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                if (onResultBlock) {
                    onResultBlock(download);
                }
                self.currentDownload = download;
                return;
            }
        }
        AGDownload *download =  [self createDownloadWithResourceUrl:resourceUrl];
        self.currentDownload = download;
        if (onResultBlock) {
            onResultBlock(download);
        }
    });
}
- (void)predownloadWithResourceUrl:(NSURL *)resourceUrl{
    NSLog(@"downloadManager --- %@ %@",NSStringFromSelector(_cmd),resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        for (AGDownload *download in self.downloadQueueMuArr) {
            if ([download.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                return;
            }
        }
        [self createDownloadWithResourceUrl:resourceUrl];
        if (nil == self.currentDownload) {
            [self reloadDownload];
        }
    });
}
- (void)reloadDownload{
    if ([self.downloadQueueMuArr count]) {
        self.currentDownload = self.downloadQueueMuArr[0];
    }
}
- (AGDownload *)createDownloadWithResourceUrl:(NSURL *)resourceUrl{
    NSLog(@"downloadManager --- %@ %@",NSStringFromSelector(_cmd),resourceUrl.absoluteString);
    AGDownload *downLoad = [AGDownload new];
    downLoad.resourceUrl = resourceUrl;
    __weak typeof(self) weakSelf = self;
    downLoad.onEndDownloadBlock = ^(AGDownloadStatus downloadStatus, AGDownload *download, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf->_serialQueue, ^{
            if (AGDownloadStatusSuccess == downloadStatus) {// 成功
                [strongSelf.downloadQueueMuArr removeObject:download];
                if (strongSelf.currentDownload == download) {
                    strongSelf.currentDownload = nil;
                    [strongSelf reloadDownload];
                }
            }else if(AGDownloadStatusFailure == downloadStatus || AGDownloadStatusStoreFailure == downloadStatus){// 失败
                if (strongSelf.currentDownload == download) {
                    [strongSelf reloadDownload];
                }
            }
        });
    };
    [self.downloadQueueMuArr insertObject:downLoad atIndex:0];
    return downLoad;
}

#pragma mark -lazy load
- (NSMutableArray<AGDownload *> *)downloadQueueMuArr{
    if (nil == _downloadQueueMuArr) {
        _downloadQueueMuArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _downloadQueueMuArr;
}
@end
