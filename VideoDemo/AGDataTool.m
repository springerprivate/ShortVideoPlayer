//
//  AGDataTool.m
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import "AGDataTool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AGDataTool

+ (NSString *)md5:(NSString *)key {
    if(!key) {
        return nil;
    }
    const char *str = [key UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}
+ (BOOL)createFolder:(NSString *)path{
    NSError *error = nil;
    if (![self isExistFile:path]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        return success;
    } else {
        return YES;
    }
}
+ (BOOL)isExistFile:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

@end
