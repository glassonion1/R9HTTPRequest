//
//  NSData+Base64.h
//
//  Created by Takeshi Yamane on 06/07/03.
//  Copyright 2006 Takeshi Yamane. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Base64)

//
// 公開メソッド
//
// Base64文字列をデコードし、NSDataオブジェクトを生成する(ASCII文字列より)
+ (NSData *)dataWithBase64CString:(const char *)pcBase64 length:(long)lLength;

// Base64文字列をデコードし、NSDataオブジェクトを生成する(NSStringより)
+ (NSData *)dataWithBase64String:(NSString *)pstrBase64;

// Base64にエンコードした文字列を生成する
- (NSString *)stringEncodedWithBase64;

//
// 内部メソッド
//
// Base64の文字から変換テーブルのインデックスを求める
+ (int)indexOfBase64Char:(char)cBase64Char;

@end
