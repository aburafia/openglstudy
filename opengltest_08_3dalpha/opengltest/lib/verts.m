//
//  indexBuffer.m
//  opengltest
//
//  Created by ryu on 2015/09/02.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "verts.h"

@implementation verts

-(verts*)init{
    vert_array = [NSMutableArray array];
    triangle_array = [NSMutableArray array];
    
    return self;
}

-(int)getTriangleCount{
    return (int)triangle_array.count;
}

-(int)getVertCount{
    return (int)vert_array.count;
}

-(void)addVert:(vert*)v{
    [vert_array addObject:v];
}

-(void)addVert:(GLfloat)x y:(GLfloat)y z:(GLfloat)z u:(GLfloat)u v:(GLfloat)v{
    vert* myvert = [[vert alloc] init:[[vec4 alloc] init:x y:y z:z w:1]
                                  uv:[[vec2 alloc] init:u y:v]];
    [self addVert:myvert];
}


-(void)addTriangle:(GLshort)a b:(GLshort)b c:(GLshort)c{
    Triangle i = (Triangle){a,b,c};
    NSValue* obj = [NSValue value:&i withObjCType:@encode(Triangle)];
    [triangle_array addObject:obj];
}

-(void)indexExportToArray:(GLshort*)array_holder {

    int count = [self getTriangleCount];
    //indexTriangle struct_list[count];
    
    int i = 0;
    for(int j=0; j<count; j++){
        NSValue* v = [triangle_array objectAtIndex:j];
        Triangle it;
        [v getValue:&it];
        array_holder[i] = it.a;
        i++;
        array_holder[i] = it.b;
        i++;
        array_holder[i] = it.c;
        i++;
    }
    
}

-(void)vertExportToArray:(vertraw*)array_holder vertcount:(int)vertcount{
    
    for(int i=0; i<vertcount; i++){
        vert* v = [vert_array objectAtIndex:i];
        vertraw vr = [v exportRaw];
        array_holder[i] = vr;
    }

}

-(void)draw{
    

}

@end
