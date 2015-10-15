//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//  缓存 工具类

@interface CacheHelper : NSObject

+ (void) setObject:(NSData *) data forKey:(NSString *) key withExpires:(int) expires;

+ (NSData *)get:(NSString *) key;

+ (NSString *)getTempPath:(NSString*)key;

+ (BOOL)fileExists:(NSString *)filepath;

+ (BOOL)isExpired:(NSString *) key;

@end
