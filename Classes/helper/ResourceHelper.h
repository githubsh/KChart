//  https://github.com/zhiyu/chartee/
//
//  Created by zhiyu on 7/11/11.
//  Copyright 2011 zhiyu. All rights reserved.
//  资源 工具类

@interface ResourceHelper : NSObject

+ (UIImage *) loadImageByTheme:(NSString *) name;
+ (UIImage *) loadImage:(NSString *) name;

+ (NSObject *) getUserDefaults:(NSString *) name;
+ (void) setUserDefaults:(NSObject *) defaults forKey:(NSString *) key;

@end
