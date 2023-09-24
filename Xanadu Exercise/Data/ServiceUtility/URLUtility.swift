//
//  URLUtility.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

extension URL {
    init?(string: String, urlQueryItems: [URLQueryItem]) {
        self.init(string: string) {
            $0.append(queryItems: urlQueryItems)
        }
    }
    
    init?(string: String, configure: (inout URL) -> Void) {
        self.init(string: string)
        configure(&self)
    }
    
    func toXanaduURLRequest()  -> URLRequest {
        var urlRequest = URLRequest(url: self)
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-type")
        urlRequest.addValue("mb-client-type=mb-mobile-ios", forHTTPHeaderField: "Cookie")
        return urlRequest
    }
}
