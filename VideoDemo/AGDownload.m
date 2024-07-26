//
//  AGDownload.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGDownload.h"
#import "AGVideoResourceCacheManager.h"
#import "AGDataTool.h"

@interface AGDownload ()<NSURLSessionDownloadDelegate>{
    dispatch_queue_t _serialQueue;
}

@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,strong)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong)NSURL *localURL;

@property (nonatomic,assign)AGDownloadStatus downloadStatus;// 下载状态

@end

@implementation AGDownload

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.renrui.videoDwonload.serialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setDelegate:(id<AGDownloadDelegate>)delegate{
    dispatch_async(_serialQueue, ^{
        if (self->_delegate && (self->_delegate != delegate)) {// 代理替换
            
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {// 原有代理
                [self->_delegate agDownloadStatus:AGDownloadStatusReplace
                                   localUrl:nil
                                      error:[self errorWithDownloadStatus:AGDownloadStatusReplace]
                              downloadBytes:0
                                 totalBytes:0];
            }
            self->_delegate = delegate;
            if (self->_delegate && [self->_delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {// 替换代理
                [self->_delegate agDownloadStatus:self.downloadStatus
                                   localUrl:AGDownloadStatusSuccess == self.downloadStatus ? self.localURL : nil
                                      error:[self errorWithDownloadStatus:self.downloadStatus]
                              downloadBytes:0
                                 totalBytes:0];
            }
        }else{
            self->_delegate = delegate;
        }
    });
}
- (void)startDownload{
    dispatch_async(_serialQueue, ^{
        // 若资源存在，直接返回成功
        NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:self.resourceUrl]];
        if (localUrl) {
            NSLog(@"不用下载  %@",self.resourceUrl.absoluteString);
            self.downloadStatus = AGDownloadStatusSuccess;
            if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                [self.delegate agDownloadStatus:AGDownloadStatusSuccess
                                   localUrl:localUrl
                                      error:[self errorWithDownloadStatus:AGDownloadStatusSuccess]
                              downloadBytes:0
                                 totalBytes:0];
            }
            if (self.downloadBlock) {
                self.downloadBlock(self,nil);
            }
            return;
        }
        NSLog(@"开始下载  %@",self.resourceUrl.absoluteString);
        self.downloadStatus = AGDownloadStatusUnkown;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        self.downloadTask = [self.session downloadTaskWithURL:self.resourceUrl];
        [self.downloadTask resume];
    });
}

- (void)cancelDownload{
    dispatch_async(_serialQueue, ^{
        [self.downloadTask cancel];
    });
}

#pragma mark -NSURLSessionDownloadDelegate
// 下载完成时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"下载完成");
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"video"];
    
    if (![AGDataTool createFolder:path]) {
        dispatch_async(_serialQueue, ^{
            self.downloadStatus = AGDownloadStatusStoreFailure;
            if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                [self.delegate agDownloadStatus:AGDownloadStatusStoreFailure
                                   localUrl:nil
                                      error:[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]
                              downloadBytes:0
                                 totalBytes:0];
            }
            if (self.downloadBlock) {
                self.downloadBlock(self,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
            }
        });
    }else{
        NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[AGVideoResourceCacheManager  cacheKeyWithResourceUrl:self.resourceUrl]]];
        NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager moveItemAtURL:location toURL:destinationURL error:&error];
        dispatch_async(_serialQueue, ^{
            if (error) {
                self.downloadStatus = AGDownloadStatusStoreFailure;
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusStoreFailure
                                           localUrl:nil
                                              error:[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]
                                      downloadBytes:0
                                         totalBytes:0];
                }
                if (self.downloadBlock) {
                    self.downloadBlock(self,[self errorWithDownloadStatus:AGDownloadStatusStoreFailure]);
                }
            } else {
                self.localURL = [NSURL fileURLWithPath:destinationPath];
                self.downloadStatus = AGDownloadStatusSuccess;
                if (self.delegate && [self.delegate respondsToSelector:@selector(agDownloadStatus:localUrl:error:downloadBytes:totalBytes:)]) {
                    [self.delegate agDownloadStatus:AGDownloadStatusSuccess
                                           localUrl:self.localURL
                                              error:[self errorWithDownloadStatus:AGDownloadStatusSuccess]
                                      downloadBytes:0
                                         totalBytes:0];
                }
                if (self.downloadBlock) {
                    self.downloadBlock(self,[self errorWithDownloadStatus:AGDownloadStatusSuccess]);
                }
            }
        });
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        dispatch_async(_serialQueue, ^{
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
                    self.downloadBlock(self,[self errorWithDownloadStatus:AGDownloadStatusCancel]);
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
                    self.downloadBlock(self,[self errorWithDownloadStatus:AGDownloadStatusFailure]);
                }
            }
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
    dispatch_async(_serialQueue, ^{
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
    NSLog(@"download  %@ %@",NSStringFromSelector(_cmd),self);
}

@end
