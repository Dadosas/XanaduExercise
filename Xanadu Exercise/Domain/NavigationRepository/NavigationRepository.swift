//
//  NavigationRepository.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

protocol NavigationRepository {
    func publishNavigationItemsResult() -> AnyPublisher<Result<[NavigationItem]?, XanaduError>, Never>
    func requestNavigationItemsResult()
}
