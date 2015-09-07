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
    index_array = [NSMutableArray array];
    
    return self;
}

-(void)addVert:(vert*)v{
    [vert_array addObject:v];
}

-(void)addVert:(GLfloat)x y:(GLfloat)y z:(GLfloat)z u:(GLfloat)u v:(GLfloat)v{
    vert* myvert = [[vert alloc] init:[[vec4 alloc] init:x y:y z:z w:1]
                                  uv:[[vec2 alloc] init:u y:v]];
    [self addVert:myvert];
}


-(void)addTriangle:(int)a b:(int)b c:(int)c{
    indexTriangle i = (indexTriangle){a,b,c};
    NSValue* obj = [NSValue value:&i withObjCType:@encode(indexTriangle)];
    [index_array addObject:obj];
}

-(void)indexExportToArray:(indexTriangle*)array_holder{

    int count = (int)index_array.count;
    indexTriangle struct_list[count];
    
    for(int i=0; i<count; i++){
        NSValue* v = [index_array objectAtIndex:i];
        indexTriangle it;
        [v getValue:&it];
        struct_list[i] = it;
    }
    
    array_holder = struct_list;
}

-(void)vertExportToArray:(vertraw*)array_holder{
    
    int count = (int)vert_array.count;
    vertraw struct_list[count];
    
    for(int i=0; i<count; i++){
        vert* v = [vert_array objectAtIndex:i];
        struct_list[i] = [v exportRaw];
    }
    
    array_holder = struct_list;
}

-(void)draw{
    
    vertraw posTri[4];
    [self vertExportToArray:posTri];
    
    glVertexAttribPointer(_attr_pos, 4, GL_FLOAT, GL_FALSE, sizeof(vertraw), (GLvoid*)posTri);
    
    glVertexAttribPointer(_attr_uv, 2, GL_FLOAT, GL_FALSE, sizeof(vertraw), (GLvoid*)((GLubyte*)posTri + sizeof(vec4raw)));    
    
}

@end