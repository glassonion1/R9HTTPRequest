//
//  HttpJsonClient.swift
//  R9HTTPRequest
//
//  Created by taisuke fujita on 2017/10/03.
//  Copyright © 2017年 Revolution9. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class HttpJsonClient<T: Codable>: HttpClient {
    
    public typealias ResponseType = T
    
    public init() {
        
    }
    
    public func action(method: HttpClientMethodType, url: URL, requestBody: Data?, headers: HTTPHeaders?) -> Observable<T> {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        return URLSession.shared.rx.data(request: request).timeout(30, scheduler: scheduler).map { data -> T in
            let jsonDecoder = JSONDecoder()
            let response = try! jsonDecoder.decode(T.self, from: data)
            return response
        }
    }
}
