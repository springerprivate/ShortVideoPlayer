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

+ (void)clearDisk{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [documentsPath stringByAppendingPathComponent:@"video"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDirectory = NO;
    // 检查文件夹是否存在
    BOOL folderExists = [fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory];
    
    if (folderExists && isDirectory) {
        // 删除文件夹及其内容
        BOOL success = [fileManager removeItemAtPath:folderPath error:&error];
        if (success) {
            NSLog(@"文件夹删除成功");
        } else {
            NSLog(@"删除文件夹失败: %@", error.localizedDescription);
        }
    } else {
        NSLog(@"文件夹不存在或不是文件夹");
    }
}

@end
