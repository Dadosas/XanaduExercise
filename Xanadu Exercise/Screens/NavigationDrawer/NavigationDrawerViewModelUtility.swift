//
//  NavigationDrawerViewModelUtility.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation

extension DefaultNavigationDrawerViewModel {
    convenience init(appDependencies: AppDependencies) {
        self.init(navigationRepository: appDependencies.navigationRepository)
    }
}
