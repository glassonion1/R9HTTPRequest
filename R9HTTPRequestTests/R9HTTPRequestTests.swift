//
//  R9HTTPRequestTests.swift
//  R9HTTPRequestTests
//
//  Created by taisuke fujita on 2017/10/03.
//  Copyright © 2017年 Revolution9. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import R9HTTPRequest

class R9HTTPRequestTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGet() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/get")!
        
        client.get(url: url, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTAssert(response.url == "http://httpbin.org/get")
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testMultipleGet() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/get")!
        let url2 = URL(string: "http://httpbin.org/get")!
        
        var count = 0
        Observable.of(client.get(url: url, headers: nil), client.get(url: url2, headers: nil))
            .merge()
            .subscribe(onNext: { value -> Void in
                print(value)
                count += 1
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                XCTAssert(count == 2)
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPost() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/post")!
        
        client.post(url: url, requestBody: nil, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTAssert(response.url == "http://httpbin.org/post")
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPut() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/put")!
        
        client.put(url: url, requestBody: nil, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTAssert(response.url == "http://httpbin.org/put")
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPatch() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/patch")!
        
        client.patch(url: url, requestBody: nil, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTAssert(response.url == "http://httpbin.org/patch")
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDelete() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/delete")!
        
        client.delete(url: url, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTAssert(response.url == "http://httpbin.org/delete")
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testError() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpJsonClient<HttpbinResponse>()
        let url = URL(string: "http://httpbin.org/status/500")!
        
        client.get(url: url, headers: nil)
            .subscribe(onNext: { response -> Void in
                XCTFail()
            }, onError: { error in
                if let rxerror = error as? RxCocoaURLError,
                    case .httpRequestFailed(let response, _) = rxerror {
                    XCTAssert(response.statusCode == 500)
                } else {
                    XCTFail()
                }
                promiseToCallBack.fulfill()
            }, onCompleted: {
                XCTFail()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testHtmlPage() {
        let promiseToCallBack = expectation(description: "calls back")
        
        let client = HttpDataClient()
        let url = URL(string: "http://httpbin.org/html")!
        
        client.get(url: url, headers: nil)
            .subscribe(onNext: { response -> Void in
                if let html = String(data: response, encoding: .utf8) {
                    print(html)
                    XCTAssert(html != "")
                } else {
                    XCTFail()
                }
                XCTAssert(!Thread.isMainThread)
            }, onCompleted: {
                promiseToCallBack.fulfill()
            }).disposed(by: disposeBag)
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
}
