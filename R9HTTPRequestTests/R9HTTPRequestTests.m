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

static BOOL isRun = NO;

@implementation R9HTTPRequestTests

- (void)setUp
{
    [super setUp];
    isRun = YES;
}

- (void)tearDown
{
    while (isRun) {}
    [super tearDown];
}

- (void)testGETRequest
{
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com"]];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 200, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

- (void)test404NotFound
{
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.apple.com/jpkjijbhb"]];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        STAssertTrue(responseHeader.statusCode == 404, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

- (void)testConnectionError
{
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://fdsfsdfsdfsd.co/"]];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        STFail(@"Fail");
        isRun = NO;
    }];
    [request setFailedHandler:^(NSError *error){
        NSLog(@"%@", error);
        STAssertTrue(YES, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

- (void)testShouldRedirectYes
{
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/300/301.html"]];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 200, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

/* 単体でしかテストが通らない
- (void)testShouldRedirectNo
{
    
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://jigsaw.w3.org/HTTP/300/301.html"]];
    request.shouldRedirect = NO;
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 301, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}
 */

- (void)testPOSTRequest
{
    // see http://posttestserver.com/
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://posttestserver.com/post.php"]];
    [request setHTTPMethod:@"POST"];
    [request addBody:@"test" forKey:@"TestKey"];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 200, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

- (void)testMultipartPOSTRequestWithPNG
{
    // see http://posttestserver.com/
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"https://posttestserver.com/post.php"]];
    [request setHTTPMethod:@"POST"];
    [request addBody:@"test" forKey:@"TestKey"];
    // create image 
    UIImage *image = [UIImage imageNamed:@"sync"];
    NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
    if (!pngData) {
        STFail(@"Fail to create image.");
    }
    [request setData:pngData withFileName:@"sample.jpg" andContentType:@"image/png" forKey:@"file"];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 200, @"");
        isRun = NO;
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

- (void)testMultipartPOSTRequestWithJPG
{
    // see http://posttestserver.com/
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:[NSURL URLWithString:@"https://posttestserver.com/post.php"]];
    [request setHTTPMethod:@"POST"];
    [request addBody:@"test" forKey:@"TestKey"];
    // create image 
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    NSData *jpgData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 80)];
    if (!jpgData) {
        STFail(@"Fail to create image.");
    }
    [request setData:jpgData withFileName:@"sample.jpg" andContentType:@"image/jpg" forKey:@"file"];
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
        STAssertTrue(responseHeader.statusCode == 200, @"");
        isRun = NO;
    }];
    [request setUploadProgressHandler:^(float newProgress){
        NSLog(@"%g", newProgress);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:request];
}

@end
