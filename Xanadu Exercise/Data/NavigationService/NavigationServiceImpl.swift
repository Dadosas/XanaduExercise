//
//  NavigationServiceImpl.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

class NavigationServiceImpl: NavigationService {
    
    private var cancellables: [AnyCancellable] = []
    
    func getNavigationTree() -> AnyPublisher<NavigationDTO, Error> {
        let url = URL(string: "https://www.matchbook.com/edge/rest/navigation",
                      urlQueryItems: [URLQueryItem(name: "include-tags", value: "\(true)")])
        let urlRequest = url?.toXanaduURLRequest()
        return Future<NavigationDTO, Error>.startURLRequest(urlRequest: urlRequest) { [weak self] publisher in
            guard let this = self else { return }
            publisher.store(in: &this.cancellables)
        }
        .eraseToAnyPublisher()
    }
}
