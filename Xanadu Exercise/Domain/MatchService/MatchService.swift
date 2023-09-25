//
//  MatchService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

protocol MatchService {
    func getEvents(queryTag: String) -> AnyPublisher<[MatchEvent], XanaduError>
}
