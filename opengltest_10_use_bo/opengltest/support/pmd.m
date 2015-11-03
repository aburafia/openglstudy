/*
 * support_gl_Pmd.c
 *
 *  Created on: 2014/02/18
 */

//#include    <math.h>
#import "pmd.h"
#import "util_str.h"

/**
 * PMDヘッダ
 * モデル名
 */
#define PMDFILE_HEADER_MODELNAME_LENGTH 20

/**
 * PMDヘッダ
 * コメント
 */
#define PMDFILE_HEADER_COMMENT_LENGTH 256

/**
 * マテリアル
 * テクスチャ名
 */
#define PMDFILE_MATERIAL_TEXTURENAME_LENGTH 20

/**
 * ボーン名
 */
#define PMDFILE_BONE_NAME_LENGTH 20

@implementation pmd

/**
 * ヘッダファイルを読み込む
 */
-(bool)loadHeader{
    
    // マジックナンバーをチェックする
    {
        GLbyte magic[3] = "";
        RawData_readBytes(data, magic, sizeof(magic));
        if (memcmp("Pmd", magic, sizeof(magic))) {
            NSLog(@"Magic Error %c%c%c", magic[0], magic[1], magic[2]);
            return false;
        }
    }

    // version check
    RawData_readBytes(data, &_pmdheader.version, sizeof(GLfloat));
    if (_pmdheader.version != 1.0f) {
        NSLog(@"File Version Error(%f)", _pmdheader.version);
        return false;
    }

    // モデル名
    RawData_readBytes(data, _pmdheader.name, PMDFILE_HEADER_MODELNAME_LENGTH);

    // コメント
    RawData_readBytes(data, _pmdheader.comment, PMDFILE_HEADER_COMMENT_LENGTH);
    
    // SJISで文字列が格納されているため、UTF-8に変換をかける
    [util_str sjis2utf8:_pmdheader.name];
    [util_str sjis2utf8:_pmdheader.comment];

    NSLog(@"Name(%s)", _pmdheader.name);
    NSLog(@"Comment(%s)", _pmdheader.comment);

    return true;
}



/**
 * 頂点情報を取得する
 */
-(void)loadVertices{
    // 頂点数取得
    const GLuint numVertices = RawData_readLE32(data);
    NSLog(@"vertices[%d]", numVertices);

    // 頂点領域を確保
    _result.vertices = malloc(sizeof(PmdVertex) * numVertices);
    _result.vertices_num = numVertices;

    // 頂点数分読み込む
    int i = 0;
    for (i = 0; i < numVertices; ++i) {
        PmdVertex *v = &_result.vertices[i];

        // 頂点情報ロード
        RawData_readBytes(data, &v->position, sizeof(vec3raw)); // 位置
        RawData_readBytes(data, &v->normal, sizeof(vec3raw)); // 法線
        RawData_readBytes(data, &v->uv, sizeof(vec2raw)); // UV
        RawData_readBytes(data, &v->extra.bone_num, sizeof(GLushort) * 2); // ボーン設定
        RawData_readBytes(data, &v->extra.bone_weight, sizeof(GLbyte)); // ボーン重み
        RawData_readBytes(data, &v->extra.edge_flag, sizeof(GLbyte)); // 輪郭フラグ

//        NSLog(@"v[%d] p(%f, %f, %f), u(%f, %f), n(%f, %f, %f)",
//              i,
//              v->position.x,
//              v->position.y,
//              v->position.z,
//              v->uv.x,
//              v->uv.y,
//              v->normal.x,
//              v->normal.y,
//              v->normal.z
//              );
    }
}

/**
 * インデックス情報を取得する
 */
-(void)loadIndices{
    // インデックス数取得
    const GLuint numIndices = RawData_readLE32(data);
    NSLog(@"indices[%d]", numIndices);

    // インデックス領域を確保
    _result.indices = malloc(sizeof(GLuint) * numIndices);
    _result.indices_num = numIndices;

    // インデックス読み込み
    RawData_readBytes(data, _result.indices, sizeof(GLushort) * numIndices);

    // 整合性チェック
    {
        int i = 0;
        for (i = 0; i < numIndices; ++i) {
            // インデックスの指す値は頂点数を下回らなければならない
            assert(_result.indices[i] < _result.vertices_num);
        }
    }
}

/**
 * 材質情報を取得する
 */
-(void)loadMaterial{

    const GLuint numMaterials = RawData_readLE32(data);

    // マテリアル領域を確保
    _result.materials = malloc(sizeof(PmdMaterial) * numMaterials);
    _result.materials_num = numMaterials;

    NSLog(@"materials[%d]", numMaterials);
    int i = 0;

    int sumVert = 0;
    for (i = 0; i < numMaterials; ++i) {
        PmdMaterial *m = &_result.materials[i];

        RawData_readBytes(data, &m->diffuse, sizeof(vec4raw));
        RawData_readBytes(data, &m->extra.shininess, sizeof(GLfloat));
        RawData_readBytes(data, &m->extra.specular_color, sizeof(vec3raw));
        RawData_readBytes(data, &m->extra.ambient_color, sizeof(vec3raw));
        RawData_readBytes(data, &m->extra.toon_index, sizeof(GLubyte));
        RawData_readBytes(data, &m->extra.edge_flag, sizeof(GLubyte));
        RawData_readBytes(data, &m->indices_num, sizeof(GLuint));

        // テクスチャ名を読み込む
        {
            RawData_readBytes(data, m->diffuse_texture_name, PMDFILE_MATERIAL_TEXTURENAME_LENGTH);

            // エフェクトテクスチャが含まれていれば文字列を分離する
            // diffuse.png*effect.spaのように"*"で区切られている
            GLchar *p = strchr(m->diffuse_texture_name, '*');
            if (p) {
                // diffuseは"*"を無効化することで切る
                *p = '\0';
                // エフェクトは文字列コピーする
                strcpy(m->extra.effect_texture_name, p + 1);
            } else {
                // エフェクトが無いなら最初の文字でターミネートする
                m->extra.effect_texture_name[0] = '\0';
            }

            // SJISで文字列が格納されているため、UTF-8に変換をかける
            //ES20_sjis2utf8(m->diffuse_texture_name, sizeof(m->diffuse_texture_name));
            //ES20_sjis2utf8(m->extra.effect_texture_name, sizeof(m->extra.effect_texture_name));
            
            [util_str sjis2utf8:m->diffuse_texture_name];
            [util_str sjis2utf8:m->extra.effect_texture_name];


        }

        NSLog(@"material[%d] tex(%s) effect(%s) vert(%d) face(%d) toon(%d)", i, m->diffuse_texture_name, m->extra.effect_texture_name, m->indices_num, m->indices_num / 3, (int )m->extra.toon_index);

        sumVert += m->indices_num;
    }

    NSLog(@"sum vert(%d) -> num(%d)", sumVert, _result.indices_num);
    assert(sumVert == _result.indices_num);
}

-(void)loadBone{

    const GLuint numBones = RawData_readLE16(data);

    // ボーン領域を確保
    _result.bones = malloc(sizeof(PmdBone) * numBones);
    _result.bones_num = numBones;
    NSLog(@"bones[%d]", numBones);

    // ボーンを読み込む
    int i;
    for (i = 0; i < numBones; ++i) {
        PmdBone *bone = &_result.bones[i];

        RawData_readBytes(data, bone->name, PMDFILE_BONE_NAME_LENGTH);
        // SJISで文字列が格納されているため、UTF-8に変換をかける
        //ES20_sjis2utf8(bone->name, sizeof(bone->name));
        [util_str sjis2utf8:bone->name];


        RawData_readBytes(data, &bone->parent_bone_index, sizeof(GLshort));
        RawData_readBytes(data, &bone->extra.tail_pos_bone_index, sizeof(GLshort));
        RawData_readBytes(data, &bone->extra.type, sizeof(GLbyte));
        RawData_readBytes(data, &bone->extra.ik_parent_bone_index, sizeof(GLshort));
        RawData_readBytes(data, &bone->position, sizeof(vec3raw));

        NSLog(@"bone[%d] name(%s)", i, bone->name);
    }
}

/**
 * assets配下からファイルを読み込む
 */
-(RawData*)RawData_loadFile:(NSString*)file_name {
    
    NSURL* filepath = [[NSBundle mainBundle] URLForResource:file_name withExtension:@""];
    NSData* filedata = [[NSData alloc] initWithContentsOfFile:[filepath path]];

    if(!filedata) {
        NSLog(@"file not found(%@)", file_name);
        return NULL;
    }
    
    RawData *raw = (RawData*)malloc(sizeof(RawData));
    raw->length = (int)filedata.length;
    raw->head = malloc(raw->length);
    raw->read_head = (uint8_t*)raw->head;
    
    memcpy(raw->head, filedata.bytes, raw->length);
    return raw;
}

/**
 * PMDファイルをロードする
 */
-(void)load:(NSString*)file_name{
    
    
    data = [self RawData_loadFile:file_name];
    if (!data) {
        return;
    }

    // ファイルヘッダを読み込む
    bool b = [self loadHeader];
    
    if (!b) {
        // 読み込み失敗
        //        [self free];
        return;
    }
    
    // 頂点データを読み込み
    [self loadVertices];
    [self loadIndices];
    [self loadMaterial];
    [self loadBone];

    return;
}

/**
 * PMDファイルを解放する
 */
-(void)PmdFile_free:(PmdFile *)pmd {

    if (!pmd) {
        return;
    }

    free(pmd->vertices);
    free(pmd->indices);
    free(pmd->materials);
    free(pmd->bones);
    free(pmd);
}

/**
 * 最小最大地点を求める
 */
-(void)calcAABB:(vec3raw*)minPoint maxPoint:(vec3raw*)maxPoint {
    
    *minPoint = (vec3raw){10000, 10000, 10000};
    *maxPoint = (vec3raw){-10000, -10000, -10000};

    if (_result.vertices_num == (GLuint)nil) {
        // 読み込んでないため、適当な位置を指定する
        *minPoint = (vec3raw){-10, -10, -10};
        *maxPoint = (vec3raw){10, 10, 10};
        return;
    }

    int i = 0;
    for (i = 0; i < _result.vertices_num; ++i) {
        minPoint->x = (GLfloat) fmin(minPoint->x, _result.vertices[i].position.x);
        minPoint->y = (GLfloat) fmin(minPoint->y, _result.vertices[i].position.y);
        minPoint->z = (GLfloat) fmin(minPoint->z, _result.vertices[i].position.z);

        maxPoint->x = (GLfloat) fmax(maxPoint->x, _result.vertices[i].position.x);
        maxPoint->y = (GLfloat) fmax(maxPoint->y, _result.vertices[i].position.y);
        maxPoint->z = (GLfloat) fmax(maxPoint->z, _result.vertices[i].position.z);
    }
}

/**
 * PMDファイル内のテクスチャを列挙するして、テクスチャ管理に登録する
 */
-(void)loadTextures:(textures*)texlist{
 
    // マテリアル数だけチェックする
    int i;
    for (i = 0; i < _result.materials_num; ++i) {

        PmdMaterial material = _result.materials[i];

        // テクスチャ名が設定されている
        if (strlen(material.diffuse_texture_name) == 0) {
            NSLog(@"テクスチャ名がありません");
            continue;
        }
        
        NSString *texture_name = [[NSString alloc] initWithUTF8String:material.diffuse_texture_name ];
        
        // diffuseチェック
        texture* t = [texlist get:texture_name];
        
        if (t == nil) {
            NSLog(@"テクスチャ読み込み開始 name=%@",texture_name);
            [texlist add:texture_name];
        }else{
            NSLog(@"すでにロード済み name=%@",texture_name);
        }
    }
}


@end