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
    
    init(navigationItem: NavigationItem) {
        self.navigationItem = navigationItem
    }
}
