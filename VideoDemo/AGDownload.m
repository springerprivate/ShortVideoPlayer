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

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation AGDownload

- (void)setDelegate:(id<AGDownloadDelegate>)delegate{
    if (_delegate && (_delegate != delegate)) {
        [_delegate downloadFailure:[NSError errorWithDomain:@"" code:300 userInfo:@{NSLocalizedDescriptionKey:@"下载失败",NSLocalizedFailureReasonErrorKey:@"下载被替代"}]];
    }
    _delegate = delegate;
}
- (void)startDownload{
    // 若资源存在，直接返回成功
    NSURL *localUrl = [AGVideoResourceCacheManager getLocalResoureWithCacheKey:[AGVideoResourceCacheManager cacheKeyWithResourceUrl:self.resourceUrl]];
    if (localUrl) {
        if (self.delegate) {
            [self.delegate downloadSuccess:localUrl];
        }
        if (self.downloadBlock) {
            self.downloadBlock(self,nil);
        }
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.downloadTask = [self.session downloadTaskWithURL:self.resourceUrl];
    [self.downloadTask resume];
}

- (void)cancelDownload{
    [self.downloadTask cancel];
}

#pragma mark -NSURLSessionDownloadDelegate
// 下载完成时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"video"];
    if (![AGDataTool createFolder:path]) {
        NSError *error = [NSError errorWithDomain:@"" code:AGDownloadStatusStoreFailure userInfo:@{NSLocalizedDescriptionKey:@"下载失败",NSLocalizedFailureReasonErrorKey:@"文件存储错误"}];
        if (self.delegate) {
            [self.delegate downloadFailure:error];
        }
        if (self.downloadBlock) {
            self.downloadBlock(self,error);
        }
        return;
    }
    NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[AGVideoResourceCacheManager  cacheKeyWithResourceUrl:self.resourceUrl]]];
    NSURL *destinationURL = [NSURL fileURLWithPath:destinationPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager moveItemAtURL:location toURL:destinationURL error:&error];
    if (error) {
        NSError *error = [NSError errorWithDomain:@"" code:AGDownloadStatusStoreFailure userInfo:@{NSLocalizedDescriptionKey:@"下载失败",NSLocalizedFailureReasonErrorKey:@"文件存储错误"}];
        if (self.delegate) {
            [self.delegate downloadFailure:error];
        }
        if (self.downloadBlock) {
            self.downloadBlock(self,error);
        }
    } else {
        if (self.delegate) {
            [self.delegate downloadSuccess:[NSURL fileURLWithPath:destinationPath]];
        }
        if (self.downloadBlock) {
            self.downloadBlock(self,nil);
        }
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
            NSError *error = [NSError errorWithDomain:@"" code:AGDownloadStatusCancel userInfo:@{NSLocalizedDescriptionKey:@"下载失败",NSLocalizedFailureReasonErrorKey:@"取消下载"}];
            if (self.delegate) {
                [self.delegate downloadFailure:error];
            }
            if (self.downloadBlock) {
                self.downloadBlock(self,error);
            }
        } else {
            NSError *failError = [NSError errorWithDomain:@"" code:AGDownloadStatusFailure userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription,NSLocalizedFailureReasonErrorKey:error.localizedFailureReason}];
            if (self.delegate) {
                [self.delegate downloadFailure:failError];
            }
            if (self.downloadBlock) {
                self.downloadBlock(self,failError);
            }
        }
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    NSLog(@"下载进度: %.2f%%", progress * 100);
}
#pragma mark -dealloc
- (void)dealloc{
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),self);
}

@end
