//
//  matCamera.m
//  opengltest
//
//  Created by ryu on 2015/07/18.
//  Copyright (c) 2015年 ryu. All rights reserved.
//

#import "matCameraObj.h"

//4つまで指定OK
static caminfo CAMINFOS[4];

@implementation matCameraObj

+(void)setCamInfo:(int)camnum
           campos:(vec3)campos
          lookpos:(vec3)lookpos
               up:(vec3)up
             near:(GLfloat)near
              far:(GLfloat)far
       fovYradian:(GLfloat)fovYradian
           aspect:(GLfloat)aspect{
    
    
    CAMINFOS[camnum].campos = campos;
    CAMINFOS[camnum].lookpos = lookpos;
    CAMINFOS[camnum].up = up;
    CAMINFOS[camnum].near = near;
    CAMINFOS[camnum].far = far;
    CAMINFOS[camnum].fovYradian = fovYradian;
    CAMINFOS[camnum].aspect = aspect;
}


//ビュー変換行列
//カメラの位置  campos
//カメラが見るポイントの位置  lookpos
//カメラの上向き  up
+(mat4)viewMat4:(int)camnum{

    vec3 campos = CAMINFOS[camnum].campos;
    vec3 lookpos = CAMINFOS[camnum].lookpos;
    vec3 up = CAMINFOS[camnum].up;
    
    mat4 r;
    
    //ここわかりやすかｔった。
    //http://tech-sketch.jp/2011/11/3d3.html


    //lookからeye引いて、カメラが向いているベクトルを取得
    vec3 lookatvec = [vec3obj init:lookpos.x-campos.x y:lookpos.y-campos.y z:lookpos.z-campos.z ];
    
    //
    //カメラが向いている方をZ軸の-1の方と考える。
    //だから、変数名もカメラのZ軸て感じの名前にする
    vec3 camAxis_z = [vec3obj normalize:lookatvec]; //f
    
    //カメラの向きを知りたいだけなので正規化しとく
    vec3 u = [vec3obj normalize:up];
    
    
    //Y軸はこの段階では求められない。うまく説明できないけど、絵に描いたらわかると思う。
    //upがZと直行してないから。まず、直交してるときはモニターの真ん中に写る。
    //Y方向にちょっとずらしていったら、真ん中からはずれるけど写る。
    //そういうケースもある。だからZと必ずしも直交はしてない。
    //でもカメラのX軸とは直行してるはず。だから、ここで一旦X軸を算出
    vec3 camAxis_x = [vec3obj normalize:[vec3obj cross:camAxis_z v1:u]]; //s
    
    //XとYができたので、改めてY軸求められる。
    vec3 camAxis_y = [vec3obj cross:camAxis_x v1:camAxis_z]; //u
    
    r.m[0].x = camAxis_x.x;
    r.m[0].y = camAxis_x.y;
    r.m[0].z = camAxis_x.z;
    
    r.m[1].x = camAxis_y.x;
    r.m[1].y = camAxis_y.y;
    r.m[1].z = camAxis_y.z;
    
    r.m[2].x = camAxis_z.x;
    r.m[2].y = camAxis_z.y;
    r.m[2].z = camAxis_z.z;
    
    //カメラの軸からみた、lookposの位置はいかのとおり。移動行列の逆行列だから-1ね
    r.m[0].w = -1 * [vec3obj dot:camAxis_x v1:campos];
    r.m[1].w = -1 * [vec3obj dot:camAxis_y v1:campos];
    r.m[2].w = -1 * [vec3obj dot:camAxis_z v1:campos];
    
    r.m[3].x = 0;
    r.m[3].y = 0;
    r.m[3].z = 0;
    r.m[3].w = 1;
    
    
    /*
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
    
    return r;
}

//射影変換行列
+(mat4)perspective:(int)camnum{
    
    GLfloat near = CAMINFOS[camnum].near;
    GLfloat far = CAMINFOS[camnum].far;
    GLfloat fovYradian = CAMINFOS[camnum].fovYradian;
    GLfloat aspect = CAMINFOS[camnum].aspect;
    
    mat4 r = [mat4obj init];
    
    //z=1の時のy=0(カメラが0地点だからね)からみた、カメラに映る高さはいかのとおり。
    //龍メモ
    //zは基本マイナスだけど、計算上楽だから、z=1を使ってる。
    GLfloat heightZ1 = 1 / tan(fovYradian) / 2;
    
    //だって、、、画角半分の上しか見てない、、下も見なきゃじゃない？
    //いらないの？？
    //heightZ1 *= 2;
    
    r.m[0].x = 1 / heightZ1 * aspect;
    r.m[1].y = 1 / heightZ1;
    r.m[2].x = 1;
    r.m[2].y = 1;
    r.m[2].z = 1;
    r.m[2].w = 1;
    
    //r.m[2].z = far / (far - near);
    //r.m[2].w = (far * near) / (far - near);

    r.m[3].z = 1;
    r.m[3].w = 0;
    
    return r;
}


@end
