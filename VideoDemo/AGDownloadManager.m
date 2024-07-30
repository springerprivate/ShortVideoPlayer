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

@property (nonatomic,strong)NSMutableArray <AGDownload *>*downloadQueueMuArr;// 下载队列
@property (nonatomic,strong)AGDownload *currentDownload;// 当前下载

@end

@implementation AGDownloadManager

+ (instancetype)shareManager 
{
    static AGDownloadManager *downloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] init];
        downloadManager->_serialQueue = dispatch_queue_create("com.renrui.videoDwonloadManager.serialQueue", DISPATCH_QUEUE_SERIAL);
    });
    return downloadManager;
}

#pragma mark -set

- (void)setCurrentDownload:(AGDownload *)currentDownload
{
    _currentDownload = currentDownload;
    [_currentDownload startDownload];
}

#pragma mark -public

- (void)createDownloadWithResourceUrl:(NSURL *)resourceUrl result:(void (^)(AGDownload *))onResultBlock
{
    NSLog(@"downloadManager --- %@ %@",NSStringFromSelector(_cmd),resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        // 如果资源已存在，则不再进行下载
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:resourceUrl]];
        if (localUrl) {// 如果与播放器绑定，回调给播放器
            if (onResultBlock) {
                onResultBlock(nil);
            }
            return;
        }
        // 当前下载项
        if (self.currentDownload) {
            if ([self.currentDownload.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                if (onResultBlock) {
                    onResultBlock(self.currentDownload);
                }
                return;
            }else{// 其他资源正在下载，则取消下载
                [self.currentDownload cancelDownload];
            }
        }
        // 在下载队列中 取出，下载
        for (AGDownload *download in self.downloadQueueMuArr) {
            if ([download.resourceUrl.absoluteString isEqualToString:resourceUrl.absoluteString]) {
                self.currentDownload = download;
                if (onResultBlock) {
                    onResultBlock(download);
                }
                return;
            }
        }
        // 创建下载
        AGDownload *download =  [self createDownloadWithResourceUrl:resourceUrl];
        if (onResultBlock) {
            onResultBlock(download);
        }
        self.currentDownload = download;
    });
}

- (void)predownloadWithResourceUrl:(NSURL *)resourceUrl
{
    NSLog(@"downloadManager --- %@ %@",NSStringFromSelector(_cmd),resourceUrl.absoluteString);
    dispatch_async(_serialQueue, ^{
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:resourceUrl]];
        if (localUrl) {// 如果资源已存在，则不再处理
            return;
        }
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

#pragma mark - operation

- (void)reloadDownload
{
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
            if (AGDownloadStatusSuccess == downloadStatus ||
                AGDownloadStatusFailure == downloadStatus ||
                AGDownloadStatusStoreFailure == downloadStatus ||
                AGDownloadStatusCancel == downloadStatus) {// 成功 或 失败
                [strongSelf.downloadQueueMuArr removeObject:download];
                if (strongSelf.currentDownload == download) {
                    strongSelf.currentDownload = nil;
                    [strongSelf reloadDownload];
                }
            }
        });
    };
    [self.downloadQueueMuArr insertObject:downLoad atIndex:0];
    return downLoad;
}

#pragma mark -lazy load

- (NSMutableArray<AGDownload *> *)downloadQueueMuArr
{
    if (nil == _downloadQueueMuArr) {
        _downloadQueueMuArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _downloadQueueMuArr;
}

@end
