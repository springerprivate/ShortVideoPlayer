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
@property (nonatomic,strong)NSURL *localURL;

@property (nonatomic,assign)AGDownloadStatus downloadStatus;// 下载状态

@end

@implementation AGDownload

- (void)setDelegate:(id<AGDownloadDelegate>)delegate{
    if (self->_delegate && (self->_delegate != delegate)) {// 代理替换
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {// 原有代理
            dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
                [self->_delegate agDownloadStatus:AGDownloadStatusReplace
                                   localUrl:nil
                                      error:[self errorWithDownloadStatus:AGDownloadStatusReplace]
                              downloadBytes:0
                                 totalBytes:0];
            });
        }
        self->_delegate = delegate;
        if (self->_delegate && [self->_delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {// 替换代理
            dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
                [self->_delegate agDownloadStatus:self.downloadStatus
                                   localUrl:AGDownloadStatusSuccess == self.downloadStatus ? self.localURL : nil
                                      error:[self errorWithDownloadStatus:self.downloadStatus]
                              downloadBytes:0
                                 totalBytes:0];
            });
        }
    }else{
        self->_delegate = delegate;
    }
}
- (void)startDownload{
    NSLog(@"download -------------  %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
    dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
        // 若资源存在，直接返回成功
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:self.resourceUrl]];
        if (localUrl) {
            self.downloadStatus = AGDownloadStatusSuccess;
            if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                [self.delegate agDownloadStatus:AGDownloadStatusSuccess
                                   localUrl:localUrl
                                      error:[self errorWithDownloadStatus:AGDownloadStatusSuccess]
                              downloadBytes:0
                                 totalBytes:0];
            }
            if (self.downloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.downloadBlock(weakSelf,nil);
            }
            return;
        }
        self.downloadStatus = AGDownloadStatusUnkown;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.downloadTask = [self.session downloadTaskWithURL:self.resourceUrl];
        [self.downloadTask resume];
    });
}

- (void)cancelDownload{
    NSLog(@"download -------------  %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
    dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
        [self.downloadTask cancel];
    });
}

#pragma mark -NSURLSessionDownloadDelegate
// 下载完成时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"video"];
    NSLog(@"download ------------- complete %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
    if (![AGDataTool createFolder:path]) {
        dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
            self.downloadStatus = AGDownloadStatusStoreFailure;
            NSLog(@"download ------------- createfolder storefailure %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
            if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                [self.delegate agDownloadStatus:AGDownloadStatusStoreFailure
                                   localUrl:nil
                                      error:[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]
                              downloadBytes:0
                                 totalBytes:0];
            }
            if (self.downloadBlock) {
                __weak typeof(self)weakSelf = self;
                self.downloadBlock(weakSelf,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
            }
            [self.session invalidateAndCancel];
        });
    }else{
        NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[AGVideoResourceCacheManager  cacheKeyWithResourceUrl:self.resourceUrl]]];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager moveItemAtURL:location toURL:destinationURL error:&error];
        dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
            if (error) {
                self.downloadStatus = AGDownloadStatusStoreFailure;
                NSLog(@"download ------------- storefailure %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusStoreFailure
                                           localUrl:nil
                                              error:[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]
                                      downloadBytes:0
                                         totalBytes:0];
                }
                if (self.downloadBlock) {
                    __weak typeof(self)weakSelf = self;
                    self.downloadBlock(weakSelf,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
                }
            } else {
                self.localURL = [NSURL fileURLWithPath:destinationPath];
                self.downloadStatus = AGDownloadStatusSuccess;
                NSLog(@"download ------------- success %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusSuccess
                                           localUrl:self.localURL
                                              error:[self errorWithDownloadStatus:AGDownloadStatusSuccess]
                                      downloadBytes:0
                                         totalBytes:0];
                }
                if (self.downloadBlock) {
                    __weak typeof(self)weakSelf = self;
                    self.downloadBlock(weakSelf,[self errorWithDownloadStatus:AGDownloadStatusSuccess]);
                }
            }
            [self.session invalidateAndCancel];
        });
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        NSLog(@"download ------------- error %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
        dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                self.downloadStatus = AGDownloadStatusCancel;
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusStoreFailure
                                       localUrl:nil
                                          error:[self errorWithDownloadStatus:AGDownloadStatusCancel]
                                  downloadBytes:0
                                     totalBytes:0];
                }
                
                if (self.downloadBlock) {
                    __weak typeof(self)weakSelf = self;
                    self.downloadBlock(weakSelf,[self errorWithDownloadStatus:AGDownloadStatusCancel]);
                }
            } else {
                self.downloadStatus = AGDownloadStatusFailure;
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusFailure
                                       localUrl:nil
                                          error:[self errorWithDownloadStatus:AGDownloadStatusFailure]
                                  downloadBytes:0
                                     totalBytes:0];
                }
                if (self.downloadBlock) {
                    __weak typeof(self)weakSelf = self;
                    self.downloadBlock(weakSelf,[self errorWithDownloadStatus:AGDownloadStatusFailure]);
                }
            }
            [self.session invalidateAndCancel];
        });
    }
}

- (NSError *)errorWithDownloadStatus:(AGDownloadStatus)downloadStatus{
    switch (downloadStatus) {
        case AGDownloadStatusCancel:{
            return [NSError errorWithDomain:@"" 
                                       code:AGDownloadStatusCancel
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"取消下载"}];
            break;
        }
        case AGDownloadStatusFailure:{
            return [NSError errorWithDomain:@"" 
                                       code:AGDownloadStatusFailure
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"下载失败"}];
            break;
        }
        case AGDownloadStatusStoreFailure:{
            return [NSError errorWithDomain:@"" 
                                       code:AGDownloadStatusStoreFailure
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"文件存储错误"}];
            break;
        }
        case AGDownloadStatusReplace:{
            return [NSError errorWithDomain:@""
                                       code:AGDownloadStatusReplace
                                   userInfo:@{NSLocalizedDescriptionKey:@"下载失败",
                                              NSLocalizedFailureReasonErrorKey:@"下载被替代"}];
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dispatch_async(dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL), ^{
        self.downloadStatus = AGDownloadStatusDownloading;
        if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
            [self.delegate agDownloadStatus:AGDownloadStatusDownloading
                               localUrl:nil
                                  error:[self errorWithDownloadStatus:AGDownloadStatusDownloading]
                          downloadBytes:totalBytesWritten
                             totalBytes:totalBytesExpectedToWrite];
        }
    });
}
#pragma mark -dealloc
- (void)dealloc{
    NSLog(@"download -------------  %@ %@ %@",NSStringFromSelector(_cmd),self,self.resourceUrl.absoluteString);
}

@end
