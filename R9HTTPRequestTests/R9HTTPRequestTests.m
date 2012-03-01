//
//  R9HTTPRequestTests.m
//  R9HTTPRequestTests
//
//  Created by taisuke fujita on 12/03/02.
//  Copyright (c) 2012年 Revolution 9. All rights reserved.
//

#import "R9HTTPRequestTests.h"
#import "R9HTTPRequest.h"
#import "R9HTTPWSSERequest.h"

@implementation R9HTTPRequestTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testGetRequest
{
    __block BOOL isRun = YES;
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    [request setCompletionBlock:^(NSString *responseString){
        NSLog(@"%@", responseString);
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
    
    while (isRun) {
        ;
    }
}

- (void)testRedirect
{
    __block BOOL isRun = YES;
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/300/301.html"]];
    request.shouldRedirect = NO;
    [request setCompletionBlock:^(NSString *responseString){
        NSLog(@"%@", responseString);
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
    
    while (isRun) {
        ;
    }
}

@end
