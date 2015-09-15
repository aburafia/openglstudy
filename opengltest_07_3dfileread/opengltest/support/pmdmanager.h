///*
// * support_gl_Pmd.h
// *
// * 簡易MMDファイル読み込みライブラリ
// * 各構造体の文字列部分についてはsjis->utf8変換を見込んで大きめに確保してある
// *  Created on: 2014/02/18
// */
//#import "vert.h"
//#import "support_RawData.h"
//
///**
// * PMDファイルのヘッダ情報
// */
//typedef struct PmdHeader {
//    /**
//     * バージョン番号
//     */
//    GLfloat version;
//
//    /**
//     * モデル名
//     */
//    GLchar name[32];
//
//    /**
//     * コメント
//     */
//    GLchar comment[256 + 128];
//} PmdHeader;
//
///**
// * PMDファイルが格納する頂点情報
// */
//typedef struct PmdVertex {
//    /**
//     * 位置
//     */
//    vec3raw position;
//
//    /**
//     * テクスチャUV
//     */
//    vec2raw uv;
//
//    /**
//     * 法線
//     */
//    vec3raw normal;
//
//    /**
//     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
//     */
//    struct {
//
//        /**
//         * 関連付けられたボーン番号
//         */
//        GLshort bone_num[2];
//
//        /**
//         * ボーンの重み情報（最大100）
//         * bone_num[0]の影響度がbone_weight、bone_num[1]の影響度が100 - bone_weightで表される
//         */
//        GLbyte bone_weight;
//
//        /**
//         * エッジ表示フラグ
//         * 0=無効
//         * 1=有効
//         */
//        GLbyte edge_flag;
//    } extra;
//} PmdVertex;
//
///**
// * PMD材質情報
// */
//typedef struct PmdMaterial {
//    /**
//     * 拡散反射光
//     */
//    vec4raw diffuse;
//
//    /**
//     * 頂点数
//     */
//    GLint indices_num;
//
//    /**
//     * テクスチャファイル名
//     */
//    GLchar diffuse_texture_name[20 + 12];
//
//    /**
//     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
//     */
//    struct {
//
//        /**
//         * 輪郭フラグ
//         */
//        GLbyte edge_flag;
//
//        /**
//         *
//         */
//        GLfloat shininess;
//
//        /**
//         * スペキュラ色
//         */
//        vec3raw specular_color;
//
//        /**
//         * 環境光
//         */
//        vec3raw ambient_color;
//        /**
//         *
//         */
//        GLbyte toon_index;
//
//        /**
//         * エフェクト用テクスチャ名
//         * .sph/.spaファイルが指定される。サンプル内では利用しない
//         */
//        GLchar effect_texture_name[20 + 12];
//    } extra;
//
//} PmdMaterial;
//
///**
// * ボーン情報
// */
//typedef struct PmdBone {
//    /**
//     * ボーン名
//     */
//    GLchar name[20 + 12];
//
//    /**
//     * 親ボーン番号
//     * 無い場合は0xFFFF = -1
//     */
//    GLshort parent_bone_index;
//
//    /**
//     * ボーンの位置
//     */
//    vec3raw position;
//
//    /**
//     * サンプルでは使用しないが、PMDファイル仕様的に含まれている情報
//     */
//    struct {
//        /**
//         * 制御ボーン
//         */
//        GLshort tail_pos_bone_index;
//
//        /**
//         * ボーンの種類
//         */
//        GLbyte type;
//
//        /**
//         * IKボーン
//         * サンプルではベイク済みもしくは手動制御を前提とする
//         */
//        GLshort ik_parent_bone_index;
//    } extra;
//} PmdBone;
//
///**
// * PMDファイルコンテナ
// */
//typedef struct PmdFile {
//    /**
//     * ヘッダファイル
//     */
//    PmdHeader header;
//
//    /**
//     * 頂点配列
//     */
//    PmdVertex *vertices;
//
//    /**
//     * 頂点数
//     */
//    GLuint vertices_num;
//
//    /**
//     * 頂点インデックス
//     */
//    GLushort *indices;
//
//    /**
//     * 頂点インデックス数
//     */
//    GLuint indices_num;
//
//    /**
//     * 材質情報
//     */
//    PmdMaterial *materials;
//
//    /**
//     * 管理している材質数
//     */
//    GLuint materials_num;
//
//    /**
//     * ボーン情報
//     */
//    PmdBone *bones;
//
//    /**
//     * ボーン数
//     */
//    GLuint bones_num;
//} PmdFile;
//
///**
// * テクスチャ用構造体
// */
//typedef struct Texture {
//    /**
//     * 画像幅
//     */
//    int width;
//    
//    /**
//     * 画像高さ
//     */
//    int height;
//    
//    /**
//     * GL側のテクスチャID
//     */
//    GLuint id;
//} Texture;
//
///**
// * テクスチャ名とTexture構造体のマッピングを行う
// */
//typedef struct PmdTextureList {
//    /**
//     * テクスチャ名配列
//     */
//    GLchar **texture_names;
//
//    /**
//     * テクスチャの実体配列
//     */
//    Texture **textures;
//
//    /**
//     * 管理しているテクスチャ数
//     */
//    int textures_num;
//} PmdTextureList;
//
//@interface pmdmanager : NSObject{
//    GLint _attr_pos;
//    GLint _attr_uv;
//    NSMutableArray* vert_array;
//    NSMutableArray* triangle_array;
//}
//
//
//+(bool)PmdFile_loadHeader:(PmdHeader *)result data:(RawData *)data;
//+(void)PmdFile_loadVertices:(PmdFile *)result data:(RawData *)data;
//+(void)PmdFile_loadIndices:(PmdFile *)result data:(RawData *)data;
//+(void)PmdFile_loadMaterial:(PmdFile *)result data:(RawData *)data;
//+(void)PmdFile_loadBone:(PmdFile *)result data:(RawData *)data;
//
//
//
//
//
///**
// * PMDファイルを生成する
// */
//-(PmdFile)PmdFile_create:(RawData*)data;
//
///**
// * PMDファイルをロードする
// */
//-(PmdFile)PmdFile_load:(const NSString*)file_name;
//
///**
// * PMDファイルを解放する
// */
////extern void PmdFile_free(PmdFile *pmd);
//-(void)PmdFile_free:(PmdFile *)pmd;
//
///**
// * 最小最大地点を求める
// */
//-(void)PmdFile_calcAABB:(PmdFile *)pmd minPoint:(vec3raw*)minPoint maxPoint:(vec3raw*)maxPoint;
//
///**
// * PMDファイル内のテクスチャを列挙する
// *
// * 注意）
// * PMDの性質上、テクスチャファイルはtgaやbmp等の巨大ファイルになる恐れがある。
// * そのため、pngに変換したファイルをhoge.bmp.pngのような形で".png"を付けて配置する。
// * 処理をラクにするため、PNGファイルの場合もhoge.png.pngのように共通化する。
// */
////extern PmdTextureList* PmdFile_createTextureList(PmdFile *pmd);
//-(PmdTextureList*) PmdFile_createTextureList:(PmdFile *)pmd;
//
///**
// * 指定した名前のテクスチャを取得する
// */
//-(Texture*) PmdFile_getTexture:(PmdTextureList *)texList name:(const GLchar *)name;
//
///**
// * 管理しているテクスチャを解放する
// */
////extern void PmdFile_freeTextureList(PmdTextureList* texList);
//-(void)PmdFile_freeTextureList:(PmdTextureList*)texList;
//
//@end
//
