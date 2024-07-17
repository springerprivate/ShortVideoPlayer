//
//  AGDataTool.h
//  VideoDemo
//
//  Created by agui on 2024/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGDataTool : NSObject

+ (NSString *)md5:(NSString *)key;
+ (BOOL)createFolder:(NSString *)path;

+ (BOOL)isExistFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
