//
//  NavigationDrawerViewModel.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

protocol NavigationDrawerViewModel {
    func publishNavigationDrawerState() -> AnyPublisher<NavigationDrawerState, Never>
    func getEventDetailViewModelIfNavigable(navigationItem: NavigationItem) -> EventDetailViewModel?
    func retry()
}

enum NavigationDrawerState {
    case loading
    case error
    case loaded(navigationItems: [NavigationItem])
}

class DefaultNavigationDrawerViewModel: NavigationDrawerViewModel {
    
    private let navigationRepository: NavigationRepository
    private let state: CurrentValueSubject<NavigationDrawerState, Never> = .init(.loading)
    
    private var cancellables: [AnyCancellable] = []
    
    init(navigationRepository: NavigationRepository) {
        self.navigationRepository = navigationRepository
    }
    
    convenience init(appDependencies: AppDependencies) {
        self.init(navigationRepository: appDependencies.navigationRepository)
        navigationRepository.publishNavigationItemsResult()
            .map({ result -> NavigationDrawerState in
                switch result {
                case .success(let items):
                    if let items = items {
                        return .loaded(navigationItems: items)
                    } else {
                        return .loading
                    }
                case .failure:
                    return .error
                }
            })
            .sink(receiveValue: { [weak state] navigationDrawerState in state?.send(navigationDrawerState) })
            .store(in: &cancellables)
    }

    func publishNavigationDrawerState() -> AnyPublisher<NavigationDrawerState, Never> {
        return state.eraseToAnyPublisher()
    }
    
    func getEventDetailViewModelIfNavigable(navigationItem: NavigationItem) -> EventDetailViewModel? {
        guard navigationItem.isNavigableTo() else { return nil }
        return DefaultEventDetailViewModel(navigationItem: navigationItem, appDependencies: AppDelegate.getAppDependencies())
    }
    
    func retry() {
        guard case .error = state.value else { return }
        navigationRepository.requestNavigationItemsResult()
        state.send(.loading)
    }
    
    private func requestDataFromREST() {
        navigationRepository.requestNavigationItemsResult()
    }
}
