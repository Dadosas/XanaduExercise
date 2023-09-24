//
//  FutureUtility.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

extension Future {
    static func startURLRequest<ReturnType: Decodable>(urlRequest: URLRequest?, onPublisher: @escaping (AnyCancellable) -> Void) -> Future<ReturnType, any Error> {
        return Future<ReturnType, Error> { promise in
            guard let urlRequest = urlRequest else {
                return promise(.failure(RESTError.loadingFailure))
            }
            let publisher = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw RESTError.loadingFailure
                    }
                    return data
                }
                .decode(type: ReturnType.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { error in
                    switch error {
                    case let restError as RESTError:
                        promise(.failure(restError))
                    default:
                        promise(.failure(RESTError.loadingFailure))
                    }
                },
                      receiveValue: { promise(.success($0)) })
            onPublisher(publisher)
        }
    }
}
