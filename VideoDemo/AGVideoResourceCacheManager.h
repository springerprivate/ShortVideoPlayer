//
//  AGVideoResourceCacheManager.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//
// 视频资源缓存管理类 缓存到disk
#import <Foundation/Foundation.h>
#import "AGDataTool.h"

@interface AGVideoResourceCacheManager : NSObject

/// 获取本地资源地址，若为空，则说明本地没有资源
/// - Parameter cacheKey: 资源标识
+ (NSURL *)getLocalResoureWithCacheKey:(NSString *)cacheKey;

/// 获取资源的标识
/// - Parameter resourceUrl: 资源地址
+ (NSString *)cacheKeyWithResourceUrl:(NSURL *)resourceUrl;

+ (void)clearDisk;

@end

