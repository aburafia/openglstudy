//
//  util_str.m
//  opengltest
//
//  Created by ryu on 2015/09/21.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "util_str.h"

@implementation util_str

+(void)sjis2utf8:(char*)str{
    
    // 一旦NULLターミネート文字列をNSDataに落とす
    NSData *sjisData = [NSData dataWithBytes:str length:strlen(str)];
    
    // 対象のNSDataがsjisコードであることを指定してNSStringを作成
    NSString* string = [[NSString alloc] initWithData:sjisData encoding:NSShiftJISStringEncoding];
    
    str = (char*)[string UTF8String];
}

@end
