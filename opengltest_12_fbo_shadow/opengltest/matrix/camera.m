//
//  matCamera.m
//  opengltest
//
//  Created by ryu on 2015/07/18.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "camera.h"

@implementation camera

-(camera*)initWithInfo:(int)_camnum
             campos:(vec3*)_campos
            lookpos:(vec3*)_lookpos
                 up:(vec3*)_up
               near:(GLfloat)_near
                far:(GLfloat)_far
         fovYradian:(GLfloat)_fovYradian
             aspect:(GLfloat)_aspect{
    
    camnum = _camnum;
    campos = _campos;
    lookpos = _lookpos;
    up = _up;
    near = _near;
    far = _far;
    fovYradian = _fovYradian;
    aspect = _aspect;
    
    return self;
}


//ビュー変換行列
-(mat4*)viewMat4{
    
    //ここわかりやすかｔった。
    //http://tech-sketch.jp/2011/11/3d3.html

    //lookからeye引いて、カメラが向いているベクトルを取得
    vec3* lookatvec = [[vec3 alloc] init:lookpos->x - campos->x
                                       y:lookpos->y - campos->y
                                       z:lookpos->z - campos->z ];
    
    //カメラが向いている方をZ軸の-1の方と考える。
    //だから、変数名もカメラのZ軸て感じの名前にする
    vec3* camAxis_z = [lookatvec copy];
    [camAxis_z normalize]; //f
    
    
    //カメラの向きを知りたいだけなので正規化しとく
    vec3* u = [up copy];
    [u normalize];

    
    //Y軸はこの段階では求められない。うまく説明できないけど、絵に描いたらわかると思う。
    //upがZと直行してないから。まず、直交してるときはモニターの真ん中に写る。
    //Y方向にちょっとずらしていったら、真ん中からはずれるけど写る。
    //そういうケースもある。だからZと必ずしも直交はしてない。
    //でもカメラのX軸とは直行してるはず。だから、ここで一旦X軸を算出
    //vec3 camAxis_x = [vec3obj normalize:[vec3obj cross:camAxis_z v1:u]]; //s
    vec3* camAxis_x = [vec3 cross:camAxis_z v1:u];
    [camAxis_x normalize];
    
    
    //XとYができたので、改めてY軸求められる。
    vec3* camAxis_y = [vec3 cross:camAxis_x v1:camAxis_z]; //u
    
    //でも、カメラはマイナス方向を向いてるはず。みぎて座標系だし。
    //欲しいのは、「カメラのZ軸」であって、注視ベクトルが欲しいわけじゃない。
    //だから、向きを逆にする
    //
    //こういうことなのかな？
    //http://d.hatena.ne.jp/tociyuki/20101213/1292252498
    [camAxis_z setLength:-1];
    
    mat4raw r;
    r.row[0].x = camAxis_x->x;
    r.row[0].y = camAxis_x->y;
    r.row[0].z = camAxis_x->z;
    
    r.row[1].x = camAxis_y->x;
    r.row[1].y = camAxis_y->y;
    r.row[1].z = camAxis_y->z;
    
    r.row[2].x = camAxis_z->x;
    r.row[2].y = camAxis_z->y;
    r.row[2].z = camAxis_z->z;
    
    //カメラの軸からみた、lookposの位置はいかのとおり。移動行列の逆行列だから-1ね
    r.row[0].w = -1 * [vec3 dot:camAxis_x v1:campos];
    r.row[1].w = -1 * [vec3 dot:camAxis_y v1:campos];
    r.row[2].w = -1 * [vec3 dot:camAxis_z v1:campos];
    
    r.row[3].x = 0;
    r.row[3].y = 0;
    r.row[3].z = 0;
    r.row[3].w = 1;
    
    
    /*
     参考図書からの写経。いちおうのこしておく
    r.m[0].x = s.x;
     r.m[1].x = s.y;
     r.m[2].x = s.z;
     
     r.m[0].y = u.x;
     r.m[1].y = u.y;
     r.m[2].y = u.z;
     
     r.m[0].z = -f.x;
     r.m[1].z = -f.y;
     r.m[2].z = -f.z;
     
     r.m[3].x = -1 * [vec3obj dot:s v1:eye];
     r.m[3].y = -1 * [vec3obj dot:u v1:eye];
     r.m[3].z = [vec3obj dot:f v1:eye];
     
     r.m[0].w = 0;
     r.m[1].w = 0;
     r.m[2].w = 0;
     r.m[3].w = 1;
     */
    
    return [[mat4 alloc] init:r];
}

//射影変換行列をつくろう
-(mat4*)perspectiveMat4{
    
    //z=1の時のy=0(カメラが0地点だからね)からみた、カメラに映る高さはいかのとおり。
    //しかもどうせ、あとあとzで割られるので、符号は変わらないはず。
    GLfloat heightZ1 = tan(fovYradian) / 2;
    
    //const GLfloat f = (GLfloat) (1.0 / (tan(degree2radian(fovY_degree)) / 2.0)); // 1/tan(x) == cot(x)
    
    mat4raw r = [mat4 tani];
    r.row[0].x = (1 / heightZ1) / aspect;
    r.row[1].y = 1 / heightZ1;
    
    r.row[2].z = (far + near) / (near - far);
    r.row[2].w = (2 * far * near) / (near - far);

    r.row[3].z = -1;
    r.row[3].w = 0;
    
    return [[mat4 alloc] init:r];
}

-(vec4*)cameraCalc:(vec3*)vert{
    
    //ビュー変換行列つくろう
    mat4* view = [self viewMat4];
    //GLfloat viewarr[4][4];
    //[view exportToArrayGLType:viewarr];
    
    //射影変換行列つくろう
    mat4* parspective = [self perspectiveMat4];
    //GLfloat parspectivearr[4][4];
    //[parspective exportToArrayGLType:parspectivearr];
    
    //射影×ビュー変換行列
    mat4* mat1 = [parspective multiplyMat4:view];
    
    vec4* v = [[vec4 alloc] init:vert->x y:vert->y z:vert->z w:1];
    
    //射影×ビュー変換行列×座標
    vec4* r = [mat1 Vec4xMat4:v];
    
    return r;
}



@end
