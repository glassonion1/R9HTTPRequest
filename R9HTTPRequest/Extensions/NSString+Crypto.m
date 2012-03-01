//
//  NSString+Crypto.m
//  HatenaNote
//
//  Created by 藤田 泰介 on 12/02/24.
//  Copyright (c) 2012 Commonsense. All rights reserved.
//

#import "NSString+Crypto.h"
#import "NSData+Crypto.h"


@implementation NSString (Crypto)

- (NSData *)md5Hash
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] md5Hash];
}

- (NSString *)md5HexHash
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] md5HexHash];
}

- (NSData *)sha1Hash
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] sha1Hash];
}

- (NSString *)sha1HexHash
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] sha1HexHash];
}

@end
