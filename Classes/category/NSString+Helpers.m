//
//  String.m
//  tzz
//
//  Created by zzy on 10/26/11.
//  Copyright 2011 Zhengzhiyu. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString(Helpers)

//  转换为utf8字符串  // not used
- (NSString *)toUTF8String
{
    CFStringRef nonAlphaNumValidChars = CFSTR("![DISCUZ_CODE_1]’()*+,-./:;=?@_~");          
    NSString *preprocessedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    NSString *newStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8));
    return newStr;          
}

@end
