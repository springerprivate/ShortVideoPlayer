//
//  AGVideoResourceCacheManager.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGVideoResourceCacheManager.h"
#import "AGDataTool.h"


@implementation AGVideoResourceCacheManager
+ (NSURL *)getLocalResoureWithCacheKey:(NSString *)cacheKey{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"video"];
    NSString *destinationPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",cacheKey]];
    if ([AGDataTool isExistFile:destinationPath]) {
        return [NSURL fileURLWithPath:destinationPath];
    }else{
        return nil;
    }
}

+ (NSString *)cacheKeyWithResourceUrl:(NSURL *)resourceUrl{
    return [AGDataTool md5:resourceUrl.absoluteString];
}

@end
