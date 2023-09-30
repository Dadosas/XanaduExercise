//
//  NavigationService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

protocol NavigationService {
    func getNavigationItems() -> AnyPublisher<[NavigationItem], XanaduError>
}
