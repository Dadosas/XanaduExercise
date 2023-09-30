//
//  Socket.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation
import Combine

protocol Socket {
    var status: SocketStatus { get }
    func requestConnection()
    func requestDisconnection()
    func publishSocketEvents() -> AnyPublisher<SocketEvent, Never>
}

enum SocketStatus {
    case connected
    case disconnected
    case connecting
}

enum SocketEvent {
    case matchRunnerUpdate(relevantTag: String, matchRunnerUpdate: SocketMatchRunnerUpdate)
    case matchMarketUpdate(relevantTag: String, matchMarketUpdate: SocketMatchMarketUpdate)
    
    case uselessUpdateForExercise
}

struct SocketMatchMarketUpdate {
    let matchRunnerUpdates: [SocketMatchRunnerUpdate]
}

struct SocketMatchRunnerUpdate {
    let eventName: String
    let marketName: String
    let runnerName: String
    let backOdds: Double?
    let layOdds: Double?
}
