//
//  Xanadu_ExerciseTests.swift
//  Xanadu ExerciseTests
//
//  Created by Davide Dallan on 23/09/23.
//

import XCTest
import Combine
@testable import Xanadu_Exercise

final class DefaultNavigationRepositoryTest: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = []
    }

    func testSuccess() throws {
        let items = [NavigationItem(name: "name", tag: "tag", isNavigableTo: true)]
        let giveBackService = MockTestNavigationService(items: items)
        let defaultNavigationRepository = DefaultNavigationRepository(navigationService: giveBackService)
        
        var isExpectedItemsFound = false
        let expectation = self.expectation(description: "NavigationRepository exposes resultItems equal to items passed to MockNavigationService")
        
        defaultNavigationRepository.publishNavigationItemsResult()
            .sink(receiveValue: { result in
                switch result {
                case .success(let resultItems):
                    if items == resultItems {
                        isExpectedItemsFound = true
                        expectation.fulfill()
                    }
                case .failure:
                    break
                }
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedItemsFound)
    }
    
    func testFailure() throws {
        let failureService: NavigationService = FailureTestNavigationService()
        let defaultNavigationRepository = DefaultNavigationRepository(navigationService: failureService)
        
        var isExpectedErrorFound = false
        let expectation = self.expectation(description: "NavigationRepository exposes parsingFailure RESTError")
        
        defaultNavigationRepository.publishNavigationItemsResult()
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    break
                case .failure:
                    isExpectedErrorFound = true
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0.5)
        XCTAssertTrue(isExpectedErrorFound)
    }
}

private struct MockTestNavigationService: NavigationService {
    
    let items: [NavigationItem]
    
    func getNavigationItems() -> AnyPublisher<[NavigationItem], XanaduError> {
        return Future<[NavigationItem], XanaduError> { promise in
            promise(.success(items))
        }.eraseToAnyPublisher()
    }
}

private struct FailureTestNavigationService: NavigationService {
    func getNavigationItems() -> AnyPublisher<[NavigationItem], XanaduError> {
        return Future<[NavigationItem], XanaduError> { promise in
            promise(.failure(XanaduError.restError))
        }.eraseToAnyPublisher()
    }
}
