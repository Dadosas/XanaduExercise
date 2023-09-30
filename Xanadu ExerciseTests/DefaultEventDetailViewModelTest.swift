//
//  DefaultEventDetailViewModelTest.swift
//  Xanadu ExerciseTests
//
//  Created by Davide Dallan on 30/09/23.
//

import XCTest
import Combine

final class DefaultEventDetailViewModelTest: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = []
    }
    
    func testSuccess() throws {
        let navigationItem = NavigationItem(name: "Navigation Item Name", tag: "navigationItemTag", isNavigableTo: true)
        
        let runner = MatchRunner(name: "Runner", backOdds: nil, layOdds: nil)
        let market = MatchMarket(name: "Market",
                                 runners: [runner])
        let matchEvents = [MatchEvent(name: "Event",
                                      startDate: Date(),
                                      markets: [market])]
        let matchRepository: MatchRepository = TestMatchRepository(fetchedMatchEvents: matchEvents)
        
        let viewModel = DefaultEventDetailViewModel(navigationItem: navigationItem, matchRepository: matchRepository)
        
        var isExpectedItemsFound = false
        let expectation = self.expectation(description: "viewModel exposes matchEvents")
        
        viewModel.publishEventDetailState()
            .sink { eventDetailState in
                switch eventDetailState {
                case .loaded(let rows):
                    // checking only count for lazyness
                    let expectedRowsCount = 3 // 1 event, 1 market, 1 runner
                    if rows.count == expectedRowsCount {
                        isExpectedItemsFound = true
                        expectation.fulfill()
                    }
                default:
                    break
                }
            }.store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedItemsFound)
    }
}

private class TestMatchRepository: MatchRepository {
    private let fetchedMatchEvents: [MatchEvent]
    
    init(fetchedMatchEvents: [MatchEvent]) {
        self.fetchedMatchEvents = fetchedMatchEvents
    }
    
    func set(matchQueryIdentifier: MatchQueryIdentifier?) {
    }
    
    func publishMatchEventsResult() -> AnyPublisher<Result<[MatchEvent]?, XanaduError>, Never> {
        return Just(Result.success(fetchedMatchEvents))
            .eraseToAnyPublisher()
    }
    
    func requestMatchEventsResult() {
    }
    
    func clearMatchEventsResult() {
    }
}
