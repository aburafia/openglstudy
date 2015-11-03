//
//  texture.m
//  opengltest
//
//  Created by ryu on 2015/09/12.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "textures.h"

@implementation textures

-(id)init{
    texturelist = [[NSMutableDictionary alloc] init];
    return self;
}

-(void)add:(NSString*)filename{
    
    texture* t = [[texture alloc] init:filename];
    [texturelist setValue:t forKey:filename];
}

-(texture*)get:(NSString*)filename{
    return [texturelist valueForKey:filename];

}
-(void)bind:(NSString*)filename{
    [[texturelist valueForKey:filename] bind];
}

-(void)free{
    
    for (id key in [texturelist keyEnumerator]) {
        
        [[texturelist valueForKey:key] free];
        [texturelist removeObjectForKey:key];
        NSLog(@"Key:%@", key);

    }
}

@end
