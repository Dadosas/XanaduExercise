//
//  MockSocket.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation
import Combine

class MockSocket: Socket {
    
    static var mockMatchIdentifier: MockMatchIdentifier? = nil
    
    private(set) var status: SocketStatus = .disconnected
    private lazy var publisher: AnyPublisher<SocketEvent, Never> = {
        return Timer.publish(every: 0.7, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .filter { [weak self] _ in
                switch self?.status {
                case .connected:
                    return true
                default:
                    return false
                }
            }
            .map { _ in
                let randomEvent = SocketEvent.getRandom()
                switch randomEvent {
                case .matchMarketUpdate:
                    print("matchMarketUpdate")
                case .matchRunnerUpdate:
                    print("matchRunnerUpdate")
                case .uselessUpdateForExercise:
                    print("uselessUpdateForExercise")
                }
                return randomEvent
            }
            .eraseToAnyPublisher()
    }()
    
    func requestConnection() {
        status = .connecting
        status = .connected
    }
    
    func requestDisconnection() {
        status = .disconnected
    }
    
    func publishSocketEvents() -> AnyPublisher<SocketEvent, Never> {
        return publisher
    }
}

struct MockMatchIdentifier {
    let tag: String
    let events: [MatchEvent]
}

private extension SocketEvent {
    static func getRandom() -> SocketEvent {
        guard let mockMatchIdentifier = MockSocket.mockMatchIdentifier else { return .uselessUpdateForExercise }
        let socketEventsCount = 3
        let randomInt = Int.random(in: (0..<socketEventsCount))
        switch randomInt {
        case 0:
            guard
                let event = mockMatchIdentifier.events.randomElement(),
                let market = event.markets.randomElement()
            else {
                return .uselessUpdateForExercise
            }
            let runnerUpdates = market.runners.map { runner in
                SocketMatchRunnerUpdate(eventName: event.name,
                                        marketName: market.name,
                                        runnerName: runner.name,
                                        backOdds: 222,
                                        layOdds: 888)
            }
            return .matchMarketUpdate(relevantTag: mockMatchIdentifier.tag,
                                      matchMarketUpdate: SocketMatchMarketUpdate(matchRunnerUpdates: runnerUpdates))
        case 1:
            guard
                let event = mockMatchIdentifier.events.randomElement(),
                let market = event.markets.randomElement(),
                let runner = market.runners.randomElement()
            else {
                return .uselessUpdateForExercise
            }
            let runnerUpdate = SocketMatchRunnerUpdate(eventName: event.name,
                                                       marketName: market.name,
                                                       runnerName: runner.name,
                                                       backOdds: Double.random(in: 0...1000),
                                                       layOdds: Double.random(in: 0...1000))
            return .matchRunnerUpdate(relevantTag: mockMatchIdentifier.tag,
                                      matchRunnerUpdate: runnerUpdate)
        case 2:
            return .uselessUpdateForExercise
        default:
            fatalError()
        }
    }
}
