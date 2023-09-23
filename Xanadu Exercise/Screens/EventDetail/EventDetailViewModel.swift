//
//  EventDetailViewModel.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

protocol EventDetailViewModel {
    var navigationItem: NavigationItem { get }
}

class EventDetailViewModelImpl: EventDetailViewModel {
    
    let navigationItem: NavigationItem
    let matchService: MatchService
    
    init(navigationItem: NavigationItem, matchService: MatchService) {
        self.navigationItem = navigationItem
        self.matchService = matchService
    }
    
    convenience init(navigationItem: NavigationItem, appDependencies: AppDependencies) {
        self.init(navigationItem: navigationItem, matchService: appDependencies.matchService)
    }
}
