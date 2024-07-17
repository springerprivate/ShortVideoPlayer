//
//  AGDownloadManager.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGDownloadManager.h"
#import "AGDownload.h"

@interface AGDownloadManager ()

@property (nonatomic,strong)NSMutableArray <NSURL *>*downloadQueueMuArr;// 待下载队列
@property (nonatomic,strong)NSMutableArray <AGDownload *>*downloadingMuArr;// 下载

@end

@implementation AGDownloadManager

+ (instancetype)shareManager {
    static AGDownloadManager *downloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[self alloc] init];
    });
    return downloadManager;
}

#pragma mark -public
- (void)downloadWithResourceUrl:(NSURL *)resourceUrl player:(id <AGDownloadDelegate>)player{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
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
        if ([strongSelf.downloadingMuArr containsObject:download]) {
            [strongSelf.downloadingMuArr removeObject:download];
        }
        [strongSelf reloadDownload];
    };
    [downLoad startDownload];
    [self.downloadingMuArr addObject:downLoad];
}

- (void)cancelDownloadWithResourceUrl:(NSURL *)resourceUrl{
    if (!(resourceUrl && resourceUrl.scheme)) {// 无效
        return;
    }
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
