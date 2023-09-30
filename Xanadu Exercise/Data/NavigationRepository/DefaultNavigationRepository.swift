//
//  DefaultNavigationRepository.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

class DefaultNavigationRepository: NavigationRepository {
    
    typealias NavigationResult = Result<[NavigationItem]?, XanaduError>
    
    private let navigationService: NavigationService
    private let navigationItemsResult: CurrentValueSubject<NavigationResult, Never> = .init(.success(nil))
    
    private var cancellables: [AnyCancellable] = []
    
    init(navigationService: NavigationService) {
        self.navigationService = navigationService
        requestNavigationItemsResult()
    }
    
    func publishNavigationItemsResult() -> AnyPublisher<NavigationResult, Never> {
        return navigationItemsResult.eraseToAnyPublisher()
    }
    
    func requestNavigationItemsResult() {
        navigationService
            .getNavigationItems()
            .map({ navigationItems -> NavigationResult in .success(navigationItems) })
            .replaceError(with: .failure(.restError))
            .sink { [weak navigationItemsResult] result in navigationItemsResult?.send(result) }
            .store(in: &cancellables)
    }
}
