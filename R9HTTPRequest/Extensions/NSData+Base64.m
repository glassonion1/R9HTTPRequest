//
//  NSData+Base64.m
//
//  Created by Takeshi Yamane on 06/07/03.
//  Copyright 2006 Takeshi Yamane. All rights reserved.
//

#import "NSData+Base64.h"

//! 符号化／復号化時の変換テーブル
static const char	s_cBase64Tbl[] = {
						'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
						'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
						'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
						'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
						'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
						'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
						'w', 'x', 'y', 'z', '0', '1', '2', '3',
						'4', '5', '6', '7', '8', '9', '+', '/'
						// '='
				};

// CR/LF
static NSString		*s_pstrCRLF = @"\r\n";

// '-'
static NSString		*s_pstrEqual = @"=";


@implementation NSData (Base64EncDec)

//
// 公開メソッド
//
// Base64文字列をデコードし、NSDataオブジェクトを生成する(ASCII文字列より)
+ (NSData *)dataWithBase64CString:(const char *)pcBase64 length:(long)lLength
{
	long	lCnt;
	int		nState, nVal;
	unsigned char	cNewData;
	NSMutableData	*pdatResult = [NSMutableData data];

	// 復号化
	nState	= 0;

	for ( lCnt = 0; lCnt < lLength && pcBase64[lCnt] != '='; lCnt++ ) {
		// Base64文字をインデックス番号に変換
		nVal = [NSData indexOfBase64Char:pcBase64[lCnt]];
		if ( nVal < 0 || nVal > (64 - 1) ) {
			// 未定義文字はスキップ
			continue;
		}

		switch ( nState ) {
		case 0:
			// 先頭6bitの値の場合
			cNewData = nVal << 2;
			break;

		case 1:
			// 既にある6bitに次の2bit追加の場合
			cNewData |= (nVal & 0x30) >> 4;
			[pdatResult appendBytes:&cNewData length:1];

			// 次の位置の先頭4bit設定
			cNewData = (nVal & 0x0F) << 4;
			break;

		case 2:
			// 既にある4bitに次の4bit追加の場合
			cNewData |= (nVal >> 2) & 0x0F;
			[pdatResult appendBytes:&cNewData length:1];

			// 次の位置の先頭2bit設定
			cNewData = (nVal & 0x03) << 6;
			break;

		case 3:
			// 既にある2bitに次の6bit追加の場合
			cNewData |= nVal & 0x3F;
			[pdatResult appendBytes:&cNewData length:1];
			break;
		}

		// 状態更新
		nState++;
		if ( nState > 3 ) {
			// 3byte区切りで元に戻る
			nState = 0;
		}
	}

	return pdatResult;
}

// Base64文字列をデコードし、NSDataオブジェクトを生成する(NSStringより)
+ (NSData *)dataWithBase64String:(NSString *)pstrBase64
{
	const char *pcBase64 = [pstrBase64 cStringUsingEncoding:NSASCIIStringEncoding];
	if ( pcBase64 == nil ) {
		return nil;
	}

	return [NSData dataWithBase64CString:pcBase64 length:[pstrBase64 lengthOfBytesUsingEncoding:NSASCIIStringEncoding]];
}

// Base64にエンコードした文字列を生成する
- (NSString *)stringEncodedWithBase64
{
	int			nState, nIndex, nLineCharCnt;
	unsigned	unCnt;
	const unsigned char	*pcRawData = [self bytes];
	unsigned	unLength   = [self length];

	NSMutableString *pstrResult = [NSMutableString string];
	nState		 = 0;
	nLineCharCnt = 0;
	unCnt		 = 0;
	while ( unCnt < unLength ) {
		switch ( nState ) {
		case 0:
			// バイトの先頭位置の場合
			// →先頭6bitを処理
			nIndex = (pcRawData[unCnt] >> 2) & 0x3F;
			break;

		case 1:
			// バイトの残り2bitと次のバイトの先頭4bitの場合
			nIndex = (pcRawData[unCnt] & 0x03) << 4;
			unCnt++;
			if ( unCnt < unLength ) {
				// 次のバイトがある場合のみ
				nIndex |= (pcRawData[unCnt] >> 4) & 0x0F;
			}
			break;

		case 2:
			// バイトの残り4bitと次のバイトの先頭2bitの場合
			nIndex = (pcRawData[unCnt] & 0x0F) << 2;
			unCnt++;
			if ( unCnt < unLength ) {
				// 次のバイトがある場合のみ
				nIndex |= (pcRawData[unCnt] >> 6) & 0x03;
			}
			break;

		case 3:
			// バイトの残り6bitの場合
			nIndex = pcRawData[unCnt] & 0x03F;
			unCnt++;
			break;
		}

		// 変換文字を符号化結果格納領域に設定
		char	cConvChar[2];
		cConvChar[0] = s_cBase64Tbl[nIndex];
		cConvChar[1] = '\0';
		[pstrResult appendString:[NSString stringWithCString:cConvChar encoding:NSASCIIStringEncoding]];
		nLineCharCnt++;
		if ( (nLineCharCnt % 76) == 0 ) {
			// 76文字毎の改行コード挿入
			[pstrResult appendString:s_pstrCRLF];
			nLineCharCnt = 0;
		}

		// 状態更新
		nState++;
		if ( nState > 3 ) {
			// 3byte区切りで元に戻る
			nState = 0;
		}
	}

	// Padding文字決定
	int	nPadCnt = 0;
	int	i;
	switch ( nState ) {
	case 1:
	case 2:
		// 1バイト目で終わった場合
		nPadCnt = 2;
		break;
	case 3:
		// 2バイト目で終わった場合
		nPadCnt = 1;
		break;
	}
	for ( i = 0; i < nPadCnt; i++ ) {
		[pstrResult appendString:s_pstrEqual];
		nLineCharCnt++;
		if ( (nLineCharCnt % 76) == 0 && i+1 < nPadCnt ) {
			// 76文字毎の改行コード挿入
			[pstrResult appendString:s_pstrCRLF];
			nLineCharCnt = 0;
		}
	}

	return pstrResult;
}

//
// 内部メソッド
//
+ (int)indexOfBase64Char:(char)cBase64Char
{
	// Base64文字テーブル検索
	int	i;
	for ( i = 0; i < 64; i++ ) {
		if ( cBase64Char == s_cBase64Tbl[i] ) {
			//! 該当インデックスを通知
			return i;
		}
	}

	// 未定義文字
	return -1;
}

@end
