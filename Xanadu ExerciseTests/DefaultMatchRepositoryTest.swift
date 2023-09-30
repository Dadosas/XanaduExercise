//
//  DefaultMatchRepositoryTest.swift
//  Xanadu ExerciseTests
//
//  Created by Davide Dallan on 30/09/23.
//

import XCTest
import Combine

final class DefaultMatchRepositoryTest: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = []
    }

    func testExample() throws {
        let relevantTag = "relevantTag"
        
        let runner = MatchRunner(name: "Runner", backOdds: nil, layOdds: nil)
        let market = MatchMarket(name: "Market",
                                 runners: [runner])
        let event = MatchEvent(name: "Event",
                               startDate: Date(),
                               markets: [market])
        let matchEvents = [event]
        let mockMatchService: MatchService = MockTestMatchService(matchEvents: matchEvents)
        
        let wantedBackOdds = 111.0
        let wantedLayOdds = 222.0
        let matchRunnerUpdate = SocketMatchRunnerUpdate(eventName: event.name,
                                                        marketName: market.name,
                                                        runnerName: runner.name,
                                                        backOdds: wantedBackOdds,
                                                        layOdds: wantedLayOdds)
        let mockTestSocket = MockTestSocket(outputEvent: SocketEvent.matchRunnerUpdate(relevantTag: "relevantTag", matchRunnerUpdate: matchRunnerUpdate))
        
        let matchRepository = DefaultMatchRepository(matchService: mockMatchService, socket: mockTestSocket)
        matchRepository.set(matchQueryIdentifier: .init(currentTag: relevantTag, fullTag: relevantTag))
        
        var isExpectedItemFound = false
        let expectation = self.expectation(description: "repository exposes updated match runner")
        
        matchRepository.publishMatchEventsResult()
            .sink { result in
                switch result {
                case .success(let events):
                    guard let events = events else {
                        break
                    }
                    let runner = events[0].markets[0].runners[0]
                    if runner.backOdds == wantedBackOdds && runner.layOdds == wantedLayOdds {
                        isExpectedItemFound = true
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
        matchRepository.requestMatchEventsResult()
        mockTestSocket.sendOutputEvent()
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedItemFound)
    }
}

private class MockTestMatchService: MatchService {
    private let matchEvents: [MatchEvent]
    
    init(matchEvents: [MatchEvent]) {
        self.matchEvents = matchEvents
    }
    
    func getMatchEvents(queryTag: String) -> AnyPublisher<[MatchEvent], XanaduError> {
        return Just(matchEvents)
            .setFailureType(to: XanaduError.self)
            .eraseToAnyPublisher()
    }
}

private class MockTestSocket: Socket {
    private let outputEvent: SocketEvent
    
    init(outputEvent: SocketEvent) {
        self.outputEvent = outputEvent
    }
    
    private let passthrough = PassthroughSubject<SocketEvent, Never>()
    
    var status: SocketStatus = .connected
    
    func requestConnection() {}
    
    func requestDisconnection() {}
    
    func publishSocketEvents() -> AnyPublisher<SocketEvent, Never> {
        return passthrough.eraseToAnyPublisher()
    }
    
    func sendOutputEvent() {
        passthrough.send(outputEvent)
    }
}
