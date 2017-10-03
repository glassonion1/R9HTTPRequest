# R9HTTPRequest

[![Version](https://img.shields.io/cocoapods/v/R9HTTPRequest.svg?style=flat)](http://cocoapods.org/pods/R9HTTPRequest)
[![License](https://img.shields.io/cocoapods/l/R9HTTPRequest.svg?style=flat)](http://cocoapods.org/pods/R9HTTPRequest)
[![Platform](https://img.shields.io/cocoapods/p/R9HTTPRequest.svg?style=flat)](http://cocoapods.org/pods/R9HTTPRequest)


R9HTTPRequest is an easy to use wrapper around the URLSession(a.k.a NSURLSession) API that makes some of the more tedious aspects of communicating with web servers easier.
It's backed by RxSwift and RxCocoa.

# Feature

## REST API Client

It is suitable performing basic HTTP requests and interacting with REST-based services (GET / POST / PUT / DELETE).

```
let disposeBag = DisposeBag()

let client = HttpJsonClient<HttpResponse>()
let url = URL(string: "http://httpbin.org/get")!

client.get(url: url, headers: nil)
    .subscribe(onNext: { response -> Void in
        //
    }).disposed(by: disposeBag)

struct HttpResponse: Codable {
    var id = ""
    var name = ""

    // ... //
}
```

# Installation

## CocoaPods

You can install R9HTTPRequest via CocoaPods by adding it to your Podfile:

```
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

pod 'R9HTTPRequest'
```
