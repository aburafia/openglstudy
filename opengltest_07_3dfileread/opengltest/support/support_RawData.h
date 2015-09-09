/*
 * support_rawdata.h
 *
 *  Created on: 2013/04/07
 */

#ifndef SUPPORT_RAWDATA_H_
#define SUPPORT_RAWDATA_H_

#include    <stdio.h>
#include    <stdlib.h>
#include    <stdbool.h>
#include    <assert.h>
#include    <string.h>
#include    <math.h>

/**
 * 生ファイル情報を保持する
 */
typedef struct RawData {
    /**
     * データ配列の先頭ポインタ
     */
    void* head;

    /**
     * データ配列の長さ（byte）
     */
    int length;

    /**
     * 読込中のヘッダ位置
     */
    uint8_t *read_head;
} RawData;

/**
 * assets配下からファイルを読み込む
 */
extern RawData* RawData_loadFile(const char* file_name);

/**
 * 読み込んだファイルを解放する
 */
extern void RawData_freeFile(RawData *rawData);

/**
 * データ全体の長さを取得する
 */
extern int RawData_getLength(RawData *rawData);

/**
 * 現在の読み取りポインタ位置を取得する
 */
extern void* RawData_getReadHeader(RawData *rawData);

/**
 * 読み取りポインタを指定バイト数移動させる
 */
extern void RawData_offsetHeader(RawData *rawData, int offsetBytes);

/**
 * 読み込みヘッダの位置を指定位置に移動させる
 */
extern void RawData_setHeaderPosition(RawData *rawData, int position);

/**
 * 読み込める残量を取得する
 */
extern int RawData_getAvailableBytes(RawData *rawData);

/**
 * 指定バイト数の情報を読み込む
 */
extern void RawData_readBytes(RawData* rawData, void* result, int bytes);

/**
 * 8bit整数を読み込む
 */
extern int8_t RawData_read8(RawData* rawData);

/**
 * Big Endian格納の16bit整数を読み込む
 */
extern int16_t RawData_readBE16(RawData* rawData);

/**
 * Big Endian格納の32bit整数を読み込む
 */
extern int32_t RawData_readBE32(RawData* rawData);

/**
 * Little Endian格納の16bit整数を読み込む
 */
extern int16_t RawData_readLE16(RawData* rawData);

/**
 * Little Endian格納の32bit整数を読み込む
 */
extern int32_t RawData_readLE32(RawData* rawData);

#endif /* SUPPORT_RAWDATA_H_ */
