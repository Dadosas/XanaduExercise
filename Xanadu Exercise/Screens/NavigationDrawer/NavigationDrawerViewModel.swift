//
//  NavigationDrawerViewModel.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

protocol NavigationDrawerViewModel {
    func publishState() -> AnyPublisher<NavigationDrawerState, Never>
    func canNavigate(to navigationItem: NavigationItem) -> Bool
    func retry()
}

enum NavigationDrawerState {
    case loading
    case error
    case loaded(navigationItems: [NavigationItem])
}

class NavigationDrawerViewModelImpl: NavigationDrawerViewModel {
    
    private let navigationRepository: NavigationRepository
    private let state: CurrentValueSubject<NavigationDrawerState, Never> = CurrentValueSubject(.loading)
    
    private var cancellables: [AnyCancellable] = []
    
    init(navigationRepository: NavigationRepository) {
        self.navigationRepository = navigationRepository
    }
    
    convenience init(appDependencies: AppDependencies) {
        self.init(navigationRepository: appDependencies.navigationRepository)
        navigationRepository.publishNavigationItems()
            .receive(on: DispatchQueue.main)
            .map({ result in
                switch result {
                case .success(let items):
                    if let items = items {
                        return NavigationDrawerState.loaded(navigationItems: items)
                    } else {
                        return NavigationDrawerState.loading
                    }
                case .failure:
                    return NavigationDrawerState.error
                }
            })
            .sink(receiveValue: { [weak state] navigationDrawerState in state?.send(navigationDrawerState) })
            .store(in: &cancellables)
    }
    
    func requestDataFromREST() {
        navigationRepository.requestNavigationItems()
    }
    
    func publishState() -> AnyPublisher<NavigationDrawerState, Never> {
        return state.eraseToAnyPublisher()
    }
    
    func canNavigate(to navigationItem: NavigationItem) -> Bool {
        return navigationItem.isAccessibleEvent()
    }
    
    func retry() {
        guard case .error = state.value else { return }
        navigationRepository.requestNavigationItems()
        state.send(.loading)
    }
}
