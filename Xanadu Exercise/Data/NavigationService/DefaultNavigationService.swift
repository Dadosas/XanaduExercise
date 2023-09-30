//
//  DefaultNavigationService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

class DefaultNavigationService: NavigationService {
    
    private var cancellables: [AnyCancellable] = []
    
    func getNavigationItems() -> AnyPublisher<[NavigationItem], XanaduError> {
        let url = URL(string: "https://www.matchbook.com/edge/rest/navigation",
                      urlQueryItems: [URLQueryItem(name: "include-tags", value: "\(true)")])
        let urlRequest = url?.toXanaduURLRequest()
        return Future<NavigationDTO, XanaduError>.startURLRequest(urlRequest: urlRequest) { [weak self] publisher in
            guard let this = self else { return }
            publisher.store(in: &this.cancellables)
        }
        .flatMap({ (navigationDTO: NavigationDTO) -> AnyPublisher<[NavigationItem], XanaduError> in
            guard let navigationItems = navigationDTO.toNavigationItems() else {
                return Fail(error: XanaduError.restError)
                    .eraseToAnyPublisher()
            }
            return Just(navigationItems)
                .setFailureType(to: XanaduError.self)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
