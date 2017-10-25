//
//  HTTPClient.swift
//  R9HTTPRequest
//
//  Created by taisuke fujita on 2017/10/03.
//  Copyright © 2017年 Revolution9. All rights reserved.
//

import Foundation
import RxSwift

/// A dictionary of headers to apply to a `URLRequest`.
public typealias HTTPHeaders = [String: String]

public enum HttpClientMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol HttpClient {
    associatedtype ResponseType
    
    func get(url: URL, headers: HTTPHeaders?) -> Observable<ResponseType>
    func post(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType>
    func put(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType>
    func patch(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType>
    func delete(url: URL, headers: HTTPHeaders?) -> Observable<ResponseType>
    func action(method: HttpClientMethodType, url: URL, requestBody: Data?, headers: HTTPHeaders?) -> Observable<ResponseType>
}

public extension HttpClient {
    
    public func get(url: URL, headers: HTTPHeaders?) -> Observable<ResponseType> {
        return action(method: .get, url: url, requestBody: nil, headers: headers)
    }
    
    public func post(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType> {
        return action(method: .post, url: url, requestBody: requestBody?.data(using: .utf8), headers: headers)
    }
    
    public func put(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType> {
        return action(method: .put, url: url, requestBody: requestBody?.data(using: .utf8), headers: headers)
    }
    
    public func patch(url: URL, requestBody: String?, headers: HTTPHeaders?) -> Observable<ResponseType> {
        return action(method: .patch, url: url, requestBody: requestBody?.data(using: .utf8), headers: headers)
    }
    
    public func delete(url: URL, headers: HTTPHeaders?) -> Observable<ResponseType> {
        return action(method: .delete, url: url, requestBody: nil, headers: headers)
    }
    
}
