//
//  NavigationRepository.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

protocol NavigationRepository {
    func publishNavigationItems() -> AnyPublisher<Result<[NavigationItem]?, RESTError>, Never>
    func requestNavigationItems()
}
