//
//  Xanadu_ExerciseTests.swift
//  Xanadu ExerciseTests
//
//  Created by Davide Dallan on 23/09/23.
//

import XCTest
import Combine
@testable import Xanadu_Exercise

final class NavigationRepositoryImplTest: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = []
    }

    func testSuccess() throws {
        let items = [NavigationItem(name: "name", tag: "tag", children: [])]
        let giveBackService = MockTestNavigationService(items: items)
        let navigationRepositoryImpl = NavigationRepositoryImpl(navigationService: giveBackService)
        
        var isExpectedItemsFound = false
        let expectation = self.expectation(description: "NavigationRepository exposes parsingFailure RESTError")
        
        navigationRepositoryImpl.publishNavigationItems()
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    isExpectedItemsFound = true
                case .failure:
                    isExpectedItemsFound = false
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedItemsFound)
    }
    
    func testFailure() throws {
        let failureService: NavigationService = FailureTestNavigationService()
        let navigationRepositoryImpl = NavigationRepositoryImpl(navigationService: failureService)
        
        var isExpectedErrorFound = false
        let expectation = self.expectation(description: "NavigationRepository exposes parsingFailure RESTError")
        
        navigationRepositoryImpl.publishNavigationItems()
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    isExpectedErrorFound = false
                case .failure(let error):
                    switch error {
                    case RESTError.loadingFailure:
                        isExpectedErrorFound = true
                    default:
                        isExpectedErrorFound = false
                    }
                }
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedErrorFound)
    }
}

private struct MockTestNavigationService: NavigationService {
    
    let items: [NavigationItem]
    
    func getNavigationTree() -> AnyPublisher<[NavigationItem], RESTError> {
        return Future<[NavigationItem], RESTError> { promise in
            promise(.success(items))
        }.eraseToAnyPublisher()
    }
}

private struct FailureTestNavigationService: NavigationService {
    
    func getNavigationTree() -> AnyPublisher<[NavigationItem], RESTError> {
        return Future<[NavigationItem], RESTError> { promise in
            promise(.failure(RESTError.loadingFailure))
        }.eraseToAnyPublisher()
    }
}
