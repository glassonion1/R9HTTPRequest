//
//  R9HTTPRequest.m
//
//  Created by 藤田 泰介 on 12/02/25.
//  Copyright (c) 2012 Revolution 9. All rights reserved.
//

#import "R9HTTPRequest.h"

static NSString *boundary = @"----------0xKhTmLbOuNdArY";

@interface R9HTTPRequest(private)

- (NSData *)createMultipartBodyData;
- (NSData *)createBodyData;

@end

@implementation R9HTTPRequest {
    NSURL *_url;
    NSHTTPURLResponse *_responseHeader;
    NSMutableData *_responseData;
    NSMutableDictionary *_headers;
    NSMutableDictionary *_bodies;
    NSMutableDictionary *_fileInfo;
    NSOperationQueue *_queue;
    BOOL _isExecuting, _isFinished;
}

@synthesize completionHandler = _completionHandler;
@synthesize uploadProgressHandler = _uploadProgressHandler;
@synthesize failedHandler = _failedHandler;
@synthesize HTTPMethod = _HTTPMethod;
@synthesize shouldRedirect = _shouldRedirect;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)key
{
    if ([key isEqualToString:@"isExecuting"] || 
        [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (id)initWithURL:(NSURL *)targetUrl
{
    self = [super init];
    if (self) {
        _url = targetUrl;
        _queue = [[NSOperationQueue alloc] init];
        _headers = [[NSMutableDictionary alloc] init];
        _bodies = [[NSMutableDictionary alloc] init];
        _fileInfo = [[NSMutableDictionary alloc] init];
        _shouldRedirect = YES;
        _HTTPMethod = @"GET";
    }  
    return self;
}

- (void)startRequest
{
    [_queue addOperation:self];
}

- (void)start
{
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    if ([_headers count] > 0) {
        [request setAllHTTPHeaderFields:_headers];
    }
    [request setHTTPMethod:self.HTTPMethod];
    if ([_fileInfo count] > 0) {
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self createMultipartBodyData]];
    } else {
        [request setHTTPBody:[self createBodyData]];
    }
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    if (conn != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (_isExecuting);
    }
}

- (void)addHeader:(NSString *)value forKey:(NSString *)key
{
    [_headers setObject:value forKey:key];
}

- (void)addBody:(NSString *)value forKey:(NSString *)key
{
    [_bodies setObject:value forKey:key];
}

- (void)setData:(NSData *)data withFileName:(NSString *)fileName andContentType:(NSString *)contentType forKey:(NSString *)key
{
	[_fileInfo setValue:key forKey:@"key"];
	[_fileInfo setValue:fileName forKey:@"fileName"];
	[_fileInfo setValue:contentType forKey:@"contentType"];
	[_fileInfo setValue:data forKey:@"data"];
}

#pragma mark - Private methods

- (NSData *)createMultipartBodyData
{
    NSMutableString *bodyString = [NSMutableString string];
    [bodyString appendFormat:@"--%@\r\n",boundary ];
    [_bodies enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [bodyString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
        [bodyString appendFormat:@"%@", obj];
        [bodyString appendFormat:@"\r\n--%@\r\n",boundary];
    }];
    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"%@\";"
                                @" filename=\"%@\"\r\n", [_fileInfo objectForKey:@"key"], [_fileInfo objectForKey:@"fileName"]];
    [bodyString appendFormat:@"Content-Type: %@\r\n\r\n", [_fileInfo objectForKey:@"contentType"]];
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [bodyData appendData:[_fileInfo objectForKey:@"data"]];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}

- (NSData *)createBodyData
{
    NSMutableString *content = [NSMutableString string];
    [_bodies enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![content isEqualToString:@""]) {
            [content appendString:@"&"];
        }
        if (![key isEqualToString:@""]) {
            [content appendFormat:[NSString stringWithFormat:@"%@=%@", key, obj]];
        } else {
            [content appendString:obj];
        }
    }];
    return [content dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - NSURLConnectionDelegate and NSURLConnectionDataDelegate methods

// リダイレクトの処理
- (NSURLRequest *)connection:(NSURLConnection *)connection 
             willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response && self.shouldRedirect == NO) {
        return nil;
    } 
    return request;
}

// レスポンスヘッダの受け取り
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseHeader = [(NSHTTPURLResponse *)response copy];
    _responseData = [[NSMutableData alloc] init];
}

// データの受け取り
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

// Progress
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
    totalBytesWritten:(NSInteger)totalBytesWritten
    totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (totalBytesExpectedToWrite == 0) return;
    if (self.uploadProgressHandler) {
        float progress = [[NSNumber numberWithInteger:totalBytesWritten] floatValue];
        float total = [[NSNumber numberWithInteger: totalBytesExpectedToWrite] floatValue];
        self.uploadProgressHandler(progress / total);
    }
}

// 通信エラー
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.failedHandler) {
        self.failedHandler(error);
    }
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}

// 通信終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = nil;
    if (_responseData) {
        responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    }
    self.completionHandler(_responseHeader, responseString);
    [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
}

@end
