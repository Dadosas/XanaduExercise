//
//  MatchRepository.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation
import Combine

protocol MatchRepository {
    func set(matchQueryIdentifier: MatchQueryIdentifier?)
    func publishMatchEventsResult() -> AnyPublisher<Result<[MatchEvent]?, XanaduError>, Never>
    func requestMatchEventsResult()
    func clearMatchEventsResult()
}

struct MatchQueryIdentifier: Equatable {
    let currentTag: String
    let fullTag: String
}
