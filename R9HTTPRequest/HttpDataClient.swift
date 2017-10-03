//
//  HttpDataClient.swift
//  R9HTTPRequest
//
//  Created by taisuke fujita on 2017/10/03.
//  Copyright © 2017年 Revolution9. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class HttpDataClient: HttpClient {

    public typealias ResponseType = Data
    
    public init() {
        
    }
    
    public func action(method: HttpClientMethodType, url: URL, requestBody: Data?, headers: HTTPHeaders?) -> Observable<Data> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        return URLSession.shared.rx.data(request: request).timeout(30, scheduler: scheduler)
    }
}
