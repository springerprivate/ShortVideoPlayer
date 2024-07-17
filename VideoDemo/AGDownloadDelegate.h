//
//  AGDownloadDelegate.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import <Foundation/Foundation.h>

// 下载代理
@protocol AGDownloadDelegate <NSObject>

- (void)downloadSuccess:(NSURL *)url;
- (void)downloadFailure:(NSError *)error;

@end

