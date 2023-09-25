//
//  FutureUtility.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

extension Future {
    static func startURLRequest<ReturnType: Decodable>(urlRequest: URLRequest?, onPublisher: @escaping (AnyCancellable) -> Void) -> Future<ReturnType, XanaduError> {
        return Future<ReturnType, XanaduError> { promise in
            guard let urlRequest = urlRequest else {
                return promise(.failure(XanaduError.restError))
            }
            let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw XanaduError.restError
                    }
                    return data
                }
                .decode(type: ReturnType.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in promise(.failure(XanaduError.restError)) },
                      receiveValue: { promise(.success($0)) })
            onPublisher(publisher)
        }
    }
}
