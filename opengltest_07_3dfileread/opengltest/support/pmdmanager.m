///*
// * support_gl_Pmd.c
// *
// *  Created on: 2014/02/18
// */
//
////#include    <math.h>
//#import "pmdmanager.h"
//
///**
// * PMDヘッダ
// * モデル名
// */
//#define PMDFILE_HEADER_MODELNAME_LENGTH 20
//
///**
// * PMDヘッダ
// * コメント
// */
//#define PMDFILE_HEADER_COMMENT_LENGTH 256
//
///**
// * マテリアル
// * テクスチャ名
// */
//#define PMDFILE_MATERIAL_TEXTURENAME_LENGTH 20
//
///**
// * ボーン名
// */
//#define PMDFILE_BONE_NAME_LENGTH 20
//
//@implementation pmdmanager
//
///**
// * ヘッダファイルを読み込む
// */
//+(bool)PmdFile_loadHeader:(PmdHeader *)result data:(RawData *)data{
//    
//    // マジックナンバーをチェックする
//    {
//        GLbyte magic[3] = "";
//        RawData_readBytes(data, magic, sizeof(magic));
//        if (memcmp("Pmd", magic, sizeof(magic))) {
//            NSLog(@"Magic Error %c%c%c", magic[0], magic[1], magic[2]);
//            return false;
//        }
//    }
//
//    // version check
//    RawData_readBytes(data, &result->version, sizeof(GLfloat));
//    if (result->version != 1.0f) {
//        NSLog(@"File Version Error(%f)", result->version);
//        return false;
//    }
//
//    // モデル名
//    RawData_readBytes(data, result->name, PMDFILE_HEADER_MODELNAME_LENGTH);
//
//    // コメント
//    RawData_readBytes(data, result->comment, PMDFILE_HEADER_COMMENT_LENGTH);
//
//    // SJISで文字列が格納されているため、UTF-8に変換をかける
//    ES20_sjis2utf8(result->name, sizeof(result->name));
//    ES20_sjis2utf8(result->comment, sizeof(result->comment));
//
//    NSLog(@"Name(%s)", result->name);
//    NSLog(@"Comment(%s)", result->comment);
//
//    return true;
//}
//
///**
// * 頂点情報を取得する
// */
//+(void)PmdFile_loadVertices:(PmdFile *)result data:(RawData *)data{
//    // 頂点数取得
//    const GLuint numVertices = RawData_readLE32(data);
//    NSLog(@"vertices[%d]", numVertices);
//
//    // 頂点領域を確保
//    result->vertices = malloc(sizeof(PmdVertex) * numVertices);
//    result->vertices_num = numVertices;
//
//    // 頂点数分読み込む
//    int i = 0;
//    for (i = 0; i < numVertices; ++i) {
//        PmdVertex *v = &result->vertices[i];
//
//        // 頂点情報ロード
//        RawData_readBytes(data, &v->position, sizeof(vec3raw)); // 位置
//        RawData_readBytes(data, &v->normal, sizeof(vec3raw)); // 法線
//        RawData_readBytes(data, &v->uv, sizeof(vec2raw)); // UV
//        RawData_readBytes(data, &v->extra.bone_num, sizeof(GLushort) * 2); // ボーン設定
//        RawData_readBytes(data, &v->extra.bone_weight, sizeof(GLbyte)); // ボーン重み
//        RawData_readBytes(data, &v->extra.edge_flag, sizeof(GLbyte)); // 輪郭フラグ
//
//        NSLog(@"v[%d] p(%f, %f, %f), u(%f, %f)", i, v->position.x, v->position.y, v->position.z, v->uv.x, v->uv.y);
//    }
//}
//
///**
// * インデックス情報を取得する
// */
//+(void)PmdFile_loadIndices:(PmdFile *)result data:(RawData *)data{
//    // インデックス数取得
//    const GLuint numIndices = RawData_readLE32(data);
//    NSLog(@"indices[%d]", numIndices);
//
//    // インデックス領域を確保
//    result->indices = malloc(sizeof(GLuint) * numIndices);
//    result->indices_num = numIndices;
//
//    // インデックス読み込み
//    RawData_readBytes(data, result->indices, sizeof(GLushort) * numIndices);
//
//    // 整合性チェック
//    {
//        int i = 0;
//        for (i = 0; i < numIndices; ++i) {
//            // インデックスの指す値は頂点数を下回らなければならない
//            assert(result->indices[i] < result->vertices_num);
//        }
//    }
//}
//
///**
// * 材質情報を取得する
// */
//+(void)PmdFile_loadMaterial:(PmdFile *)result data:(RawData *)data{
//
//    const GLuint numMaterials = RawData_readLE32(data);
//
//    // マテリアル領域を確保
//    result->materials = malloc(sizeof(PmdMaterial) * numMaterials);
//    result->materials_num = numMaterials;
//
//    NSLog(@"materials[%d]", numMaterials);
//    int i = 0;
//
//    int sumVert = 0;
//    for (i = 0; i < numMaterials; ++i) {
//        PmdMaterial *m = &result->materials[i];
//
//        RawData_readBytes(data, &m->diffuse, sizeof(vec4raw));
//        RawData_readBytes(data, &m->extra.shininess, sizeof(GLfloat));
//        RawData_readBytes(data, &m->extra.specular_color, sizeof(vec3raw));
//        RawData_readBytes(data, &m->extra.ambient_color, sizeof(vec3raw));
//        RawData_readBytes(data, &m->extra.toon_index, sizeof(GLubyte));
//        RawData_readBytes(data, &m->extra.edge_flag, sizeof(GLubyte));
//        RawData_readBytes(data, &m->indices_num, sizeof(GLuint));
//
//        // テクスチャ名を読み込む
//        {
//            RawData_readBytes(data, m->diffuse_texture_name, PMDFILE_MATERIAL_TEXTURENAME_LENGTH);
//
//            // エフェクトテクスチャが含まれていれば文字列を分離する
//            // diffuse.png*effect.spaのように"*"で区切られている
//            GLchar *p = strchr(m->diffuse_texture_name, '*');
//            if (p) {
//                // diffuseは"*"を無効化することで切る
//                *p = '\0';
//                // エフェクトは文字列コピーする
//                strcpy(m->extra.effect_texture_name, p + 1);
//            } else {
//                // エフェクトが無いなら最初の文字でターミネートする
//                m->extra.effect_texture_name[0] = '\0';
//            }
//
//            // SJISで文字列が格納されているため、UTF-8に変換をかける
//            ES20_sjis2utf8(m->diffuse_texture_name, sizeof(m->diffuse_texture_name));
//            ES20_sjis2utf8(m->extra.effect_texture_name, sizeof(m->extra.effect_texture_name));
//
//        }
//
//        NSLog(@"material[%d] tex(%s) effect(%s) vert(%d) face(%d) toon(%d)", i, m->diffuse_texture_name, m->extra.effect_texture_name, m->indices_num, m->indices_num / 3, (int )m->extra.toon_index);
//
//        sumVert += m->indices_num;
//    }
//
//    NSLog(@"sum vert(%d) -> num(%d)", sumVert, result->indices_num);
//    assert(sumVert == result->indices_num);
//}
//
//+(void)PmdFile_loadBone:(PmdFile *)result data:(RawData *)data{
//
//    const GLuint numBones = RawData_readLE16(data);
//
//    // ボーン領域を確保
//    result->bones = malloc(sizeof(PmdBone) * numBones);
//    result->bones_num = numBones;
//    NSLog(@"bones[%d]", numBones);
//
//    // ボーンを読み込む
//    int i;
//    for (i = 0; i < numBones; ++i) {
//        PmdBone *bone = &result->bones[i];
//
//        RawData_readBytes(data, bone->name, PMDFILE_BONE_NAME_LENGTH);
//        // SJISで文字列が格納されているため、UTF-8に変換をかける
//        ES20_sjis2utf8(bone->name, sizeof(bone->name));
//
//        RawData_readBytes(data, &bone->parent_bone_index, sizeof(GLshort));
//        RawData_readBytes(data, &bone->extra.tail_pos_bone_index, sizeof(GLshort));
//        RawData_readBytes(data, &bone->extra.type, sizeof(GLbyte));
//        RawData_readBytes(data, &bone->extra.ik_parent_bone_index, sizeof(GLshort));
//        RawData_readBytes(data, &bone->position, sizeof(vec3raw));
//
//        NSLog(@"bone[%d] name(%s)", i, bone->name);
//    }
//}
//
///**
// * PMDファイルを生成する
// */
//-(PmdFile*)PmdFile_create:(RawData *)data {
//    
//    PmdFile *result = calloc(1, sizeof(PmdFile));
//
//    // ファイルヘッダを読み込む
//    bool b = [pmdmanager PmdFile_loadHeader:&result->header data:data];
//    
//    if (!b) {
//        // 読み込み失敗
//        PmdFile_free(result);
//        return NULL;
//    }
//
//    // 頂点データを読み込み
//    [pmdmanager PmdFile_loadVertices:result data:data];
//    [pmdmanager PmdFile_loadIndices:result data:data];
//    [pmdmanager PmdFile_loadMaterial:result data:data];
//    [pmdmanager PmdFile_loadBone:result data:data];
//    
//    /*
//    PmdFile_loadVertices(result, data);
//    // インデックスデータを読み込み
//    PmdFile_loadIndices(result, data);
//    // 材質情報を読み込み
//    PmdFile_loadMaterial(result, data);
//    // ボーン情報を読み込み
//    PmdFile_loadBone(result, data);
//     */
//    
//    return result;
//}
//
///**
// * PMDファイルをロードする
// */
//-(PmdFile*) PmdFile_load:(const NSString*) file_name {
//    
//    
//    RawData *data = RawData_loadFile([file_name UTF8String]);
//    if (!data) {
//        return NULL;
//    }
//
//    PmdFile* result = [self PmdFile_create:data];
//
//    RawData_freeFile(data);
//
//    return result;
//}
//
///**
// * PMDファイルを解放する
// */
//-(void)PmdFile_free:(PmdFile *)pmd {
//
//    if (!pmd) {
//        return;
//    }
//
//    free(pmd->vertices);
//    free(pmd->indices);
//    free(pmd->materials);
//    free(pmd->bones);
//    free(pmd);
//}
//
///**
// * 最小最大地点を求める
// */
//-(void)PmdFile_calcAABB:(PmdFile *)pmd minPoint:(vec3raw*)minPoint maxPoint:(vec3raw*)maxPoint {
//    
//    *minPoint = (vec3raw){10000, 10000, 10000};
//    *maxPoint = (vec3raw){-10000, -10000, -10000};
//
//    if (!pmd) {
//        // PMDが無いため、適当な位置を指定する
//        *minPoint = (vec3raw){-10, -10, -10};
//        *maxPoint = (vec3raw){10, 10, 10};
//        return;
//    }
//
//    int i = 0;
//    for (i = 0; i < pmd->vertices_num; ++i) {
//        minPoint->x = (GLfloat) fmin(minPoint->x, pmd->vertices[i].position.x);
//        minPoint->y = (GLfloat) fmin(minPoint->y, pmd->vertices[i].position.y);
//        minPoint->z = (GLfloat) fmin(minPoint->z, pmd->vertices[i].position.z);
//
//        maxPoint->x = (GLfloat) fmax(maxPoint->x, pmd->vertices[i].position.x);
//        maxPoint->y = (GLfloat) fmax(maxPoint->y, pmd->vertices[i].position.y);
//        maxPoint->z = (GLfloat) fmax(maxPoint->z, pmd->vertices[i].position.z);
//    }
//}
//
///**
// * PMDファイル内のテクスチャを列挙する
// */
//-(PmdTextureList*)PmdFile_createTextureList:(PmdFile *)pmd {
//    
//    PmdTextureList *result = calloc(1, sizeof(PmdTextureList));
//
//    // 読み込み時の一時ファイル名
//    GLchar load_name[32] = { };
//
//    // マテリアル数だけチェックする
//    int i;
//    for (i = 0; i < pmd->materials_num; ++i) {
//
//        PmdMaterial *material = &pmd->materials[i];
//
//        // テクスチャ名が設定されている
//        if (strlen(material->diffuse_texture_name)) {
//            // diffuseチェック
//            Texture *t = PmdFile_getTexture(result, material->diffuse_texture_name);
//
//            if (!t) {
//                // テクスチャがまだ読み込まれていない
//                sprintf(load_name, "%s.png", material->diffuse_texture_name);
//                // テクスチャを読み込む
//                t = Texture_load(app, load_name, TEXTURE_RAW_RGBA8);
//
//                // テクスチャの読み込みに成功したら末尾へ登録する
//                if (t) {
//                    // メモリを確保する
//                    if (result->textures) {
//                        result->textures = realloc(result->textures, sizeof(Texture*) * result->textures_num + 1);
//                        result->texture_names = realloc(result->texture_names, sizeof(GLchar*) * result->textures_num + 1);
//                    } else {
//                        result->textures = malloc(sizeof(Texture*));
//                        result->texture_names = malloc(sizeof(GLchar*));
//                    }
//
//                    const int index = result->textures_num;
//                    result->textures_num++;
//
//                    result->textures[index] = t;
//                    result->texture_names[index] = malloc(strlen(material->diffuse_texture_name) + 1);
//                    // ファイル名をコピーする
//                    strcpy(result->texture_names[index], material->diffuse_texture_name);
//                }else {
//                    NSLog(@"Texture load fail(%s)", material->diffuse_texture_name);
//                }
//            }
//        }
//    }
//
//    return result;
//}
//
///**
// * 指定した名前のテクスチャを取得する
// */
//-(Texture*)PmdFile_getTexture:(PmdTextureList *)texList name:(const GLchar *)name {
//    if (!name[0] || !texList) {
//        // 空文字の場合はNULLを返す
//        return NULL;
//    }
//
//    int i = 0;
//    for (i = 0; i < texList->textures_num; ++i) {
//        // 名前が一致したらそれを返す
//        if (strcmp(texList->texture_names[i], name) == 0) {
//            return texList->textures[i];
//        }
//    }
//
//    return NULL;
//}
//
///**
// * 管理しているテクスチャを解放する
// */
//-(void)PmdFile_freeTextureList:(PmdTextureList*) texList {
//    if (!texList) {
//        return;
//    }
//
//// 各々のテクスチャを解放する
//    {
//        int i = 0;
//        for (i = 0; i < texList->textures_num; ++i) {
//            free(texList->texture_names[i]);
//            Texture_free(texList->textures[i]);
//        }
//
//        // 配列をクリアする
//        free(texList->texture_names);
//        free(texList->textures);
//    }
//    free(texList);
//}
//
//@end