//
//  NavigationRepositoryImpl.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

class NavigationRepositoryImpl: NavigationRepository {
    
    typealias NavigationResult = Result<[NavigationItem]?, RESTError>
    
    private let navigationService: NavigationService
    private let navigationItems: CurrentValueSubject<NavigationResult, Never> = .init(.success(nil))
    
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

private extension NavigationDTO {
    func toNavigationItems() -> [NavigationItem]? {
        guard let sportMetaTag = self.first else { return nil }
        let rootNavigationItem = sportMetaTag.toNavigationItem()
        return sportMetaTag.metaTags
            .map { $0.toNavigationItem() }
            .flatMap({ $0.getSelfAndAllChildren() })
    }
}

private extension MetaTagDTO {
    func toNavigationItem() -> NavigationItem {
        return NavigationItem(name: self.name, tag: self.urlName, children: metaTags.compactMap { $0.toNavigationItem() })
    }
}
