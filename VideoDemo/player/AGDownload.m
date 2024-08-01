//
//  AGDownload.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGDownload.h"
#import "AGVideoResourceCacheManager.h"
#import "AGDataTool.h"

@interface AGDownload ()<NSURLSessionDownloadDelegate>

@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,strong)NSURLSessionDownloadTask *downloadTask;

@property (nonatomic,assign)AGDownloadStatus downloadStatus;// 下载状态

@end

@implementation AGDownload

#pragma mark -public

- (void)startDownload
{
    // 开始下载
    self.downloadStatus = AGDownloadStatusDownloading;
    if (self.onDownloadBlock) {
        self.onDownloadBlock(AGDownloadStatusDownloading, nil);
    }
    if (self.onEndDownloadBlock) {
        __weak typeof(self)weakSelf = self;
        self.onEndDownloadBlock(AGDownloadStatusDownloading,weakSelf,nil);
    }
    NSLog(@"download --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    self.downloadTask = nil;
    [self.downloadTask resume];
}

- (void)cancelDownload
{
    NSLog(@"download --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    [self.downloadTask cancel];
}

- (void)reportDownloadStatus
{
    NSLog(@"download --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (self.onDownloadBlock) {
        self.onDownloadBlock(self.downloadStatus, [self errorWithDownloadStatus:self.downloadStatus]);
    }
}
#pragma mark -NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"download --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"video"];
    if (![AGDataTool createFolder:path]) {
        NSLog(@"download --- store failure");
        self.downloadStatus = AGDownloadStatusStoreFailure;
        if (self.onDownloadBlock) {
            self.onDownloadBlock(AGDownloadStatusStoreFailure, [self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
        }
        if (self.onEndDownloadBlock) {
            __weak typeof(self)weakSelf = self;
            self.onEndDownloadBlock(AGDownloadStatusStoreFailure,weakSelf,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
        }
    }else{
        NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[AGVideoResourceCacheManager  cacheKeyWithResourceUrl:self.resourceUrl]]];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager moveItemAtURL:location toURL:destinationURL error:&error];
        if (error) {
            NSLog(@"download --- store failure");
            self.downloadStatus = AGDownloadStatusStoreFailure;
            if (self.onDownloadBlock) {
                self.onDownloadBlock(AGDownloadStatusStoreFailure, [self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
            }
            if (self.onEndDownloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.onEndDownloadBlock(AGDownloadStatusStoreFailure,weakSelf,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
            }
        } else {
            NSLog(@"download --- success");
            self.downloadStatus = AGDownloadStatusSuccess;
            if (self.onDownloadBlock) {
                self.onDownloadBlock(AGDownloadStatusSuccess, nil);
            }
            if (self.onEndDownloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.onEndDownloadBlock(AGDownloadStatusSuccess,weakSelf,nil);
            }
        }
    }
    [self.session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"download --- %@ %@",NSStringFromSelector(_cmd),self.resourceUrl.absoluteString);
    if (error) {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            NSLog(@"download --- cancel");
            self.downloadStatus = AGDownloadStatusCancel;
            if (self.onDownloadBlock) {
                self.onDownloadBlock(AGDownloadStatusCancel, [self errorWithDownloadStatus:AGDownloadStatusCancel]);
            }
            if (self.onEndDownloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.onEndDownloadBlock(AGDownloadStatusCancel,weakSelf,[self errorWithDownloadStatus:AGDownloadStatusCancel]);
            }
        } else {
            NSLog(@"download --- failure");
            self.downloadStatus = AGDownloadStatusFailure;
            if (self.onDownloadBlock) {
                self.onDownloadBlock(AGDownloadStatusFailure, [self errorWithDownloadStatus:AGDownloadStatusFailure]);
            }
            if (self.onEndDownloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.onEndDownloadBlock(AGDownloadStatusFailure,weakSelf,[self errorWithDownloadStatus:AGDownloadStatusFailure]);
            }
        }
        [self.session invalidateAndCancel];
    }
}

- (NSError *)errorWithDownloadStatus:(AGDownloadStatus)downloadStatus
{
    switch (downloadStatus) {
        case AGDownloadStatusCancel:{
            return [NSError errorWithDomain:@"com.ag.download"
                                       code:AGDownloadStatusCancel
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"取消下载"}];
            break;
        }
        case AGDownloadStatusFailure:{
            return [NSError errorWithDomain:@"com.ag.download"
                                       code:AGDownloadStatusFailure
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"下载失败"}];
            break;
        }
        case AGDownloadStatusStoreFailure:{
            return [NSError errorWithDomain:@"com.ag.download" 
                                       code:AGDownloadStatusStoreFailure
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"文件存储错误"}];
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite 
{
}
#pragma mark - lazy load
- (NSURLSession *)session
{
    if (nil == _session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = 15;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}
- (NSURLSessionDownloadTask *)downloadTask
{
    if (nil == _downloadTask) {
        _downloadTask = [self.session downloadTaskWithURL:self.resourceUrl];
    }
    return _downloadTask;
}
#pragma mark -dealloc
- (void)dealloc
{
    NSLog(@"download ---- %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
}

@end
