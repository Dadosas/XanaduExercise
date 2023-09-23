//
//  NavigationRepositoryImpl.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

class NavigationRepositoryImpl: NavigationRepository {
    
    typealias NavigationResult = Result<[NavigationItem]?, NavigationRepositoryError>
    
    private let navigationService: NavigationService
    private let navigationItems: CurrentValueSubject<NavigationResult, Never> = CurrentValueSubject(.success(nil))
    
    private var cancellables: [AnyCancellable] = []
    
    init(navigationService: NavigationService) {
        self.navigationService = navigationService
        requestNavigationItems()
    }
    
    func publishNavigationItems() -> AnyPublisher<NavigationResult, Never> {
        return navigationItems.eraseToAnyPublisher()
    }
    
    func requestNavigationItems() {
        navigationService
            .getNavigationTree()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { (navigationDTO: NavigationDTO?) in NavigationResult.success(navigationDTO?.toNavigationItems()) }
            .replaceError(with: .failure(.loadingFailure))
            .sink { [weak navigationItems] result in navigationItems?.send(result) }
            .store(in: &cancellables)
    }
}

extension NavigationDTO {
    func toNavigationItems() -> [NavigationItem]? {
        guard let sportMetaTag = self.first else { return nil }
        let rootNavigationItem = sportMetaTag.toNavigationItem()
        return rootNavigationItem.getSelfAndAllChildren()
    }
}

extension MetaTagDTO {
    func toNavigationItem() -> NavigationItem {
        return NavigationItem(name: self.name, tag: self.urlName, children: metaTags.compactMap { $0.toNavigationItem() })
    }
}
