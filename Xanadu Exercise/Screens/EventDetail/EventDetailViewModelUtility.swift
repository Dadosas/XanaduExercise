//
//  EventDetailViewModelUtility.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation

extension DefaultEventDetailViewModel {
    convenience init(navigationItem: NavigationItem, appDependencies: AppDependencies) {
        self.init(navigationItem: navigationItem, matchRepository: appDependencies.matchRepository)
    }
}
