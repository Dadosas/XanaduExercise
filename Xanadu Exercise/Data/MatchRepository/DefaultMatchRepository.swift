//
//  DefaultMatchRepository.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 30/09/23.
//

import Foundation
import Combine

class DefaultMatchRepository: MatchRepository {
    
    private static let isMockSocketActive = true
    
    typealias MatchEventsResult = Result<[MatchEvent]?, XanaduError>
    
    private let matchService: MatchService
    private let socket: Socket
    private let matchEventsResult: CurrentValueSubject<MatchEventsResult, Never> = .init(.success(nil))
    
    private var matchQueryIdentifier: MatchQueryIdentifier?
    
    private var cancellables: [AnyCancellable] = []
    
    init(matchService: MatchService,
         socket: Socket) {
        self.matchService = matchService
        self.socket = socket
        subscribeToSocket()
    }
    
    func set(matchQueryIdentifier: MatchQueryIdentifier?) {
        guard let matchQueryIdentifier = matchQueryIdentifier else {
            MockSocket.mockMatchIdentifier = nil
            socket.requestDisconnection()
            return
        }
        guard matchQueryIdentifier != self.matchQueryIdentifier else { return }
        clearMatchEventsResult()
        self.matchQueryIdentifier = matchQueryIdentifier
        socket.requestConnection()
    }
    
    func publishMatchEventsResult() -> AnyPublisher<MatchEventsResult, Never> {
        return matchEventsResult.eraseToAnyPublisher()
    }
    
    func requestMatchEventsResult() {
        guard let queryTag = matchQueryIdentifier?.fullTag else {
            send(result: .failure(XanaduError.invalidParameters))
            return
        }
        matchService.getMatchEvents(queryTag: queryTag)
            .sink { [weak self] completion in
                switch completion {
                case .failure:
                    self?.send(result: .failure(XanaduError.restError))
                case .finished:
                    break
                }
            } receiveValue: { [weak self] matchEvents in
                self?.send(result: .success(matchEvents))
            }
            .store(in: &cancellables)
    }
    
    func clearMatchEventsResult() {
        send(result: .success(nil))
    }
    
    private func subscribeToSocket() {
        socket.publishSocketEvents()
            .sink { [weak self] socketEvent in
                guard let this = self else { return }
                switch socketEvent {
                case .matchMarketUpdate(let relevantTag, let matchMarkerUpdate):
                    matchMarkerUpdate.matchRunnerUpdates.forEach {
                        this.consumeMatchRunnerUpdate(relevantTag: relevantTag, matchRunnerUpdate: $0)
                    }
                case .matchRunnerUpdate(let relevantTag, let matchRunnerUpdate):
                    this.consumeMatchRunnerUpdate(relevantTag: relevantTag, matchRunnerUpdate: matchRunnerUpdate)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func send(result: MatchEventsResult) {
        matchEventsResult.send(result)
        if Self.isMockSocketActive {
            updateMockSocketData()
        }
    }
    
    private func updateMockSocketData() {
        if let currentTag = matchQueryIdentifier?.currentTag {
            let events: [MatchEvent]
            switch matchEventsResult.value {
            case .success(let eventsResult):
                events = eventsResult ?? []
            default:
                events = []
            }
            MockSocket.mockMatchIdentifier = MockMatchIdentifier(tag: currentTag, events: events)
        } else {
            MockSocket.mockMatchIdentifier = nil
        }
    }
    
    private func consumeMatchRunnerUpdate(relevantTag: String,
                                          matchRunnerUpdate: SocketMatchRunnerUpdate) {
        guard matchQueryIdentifier?.currentTag == relevantTag else { return }
        switch matchEventsResult.value {
        case .success(let matchEvents):
            guard
                var matchEvents = matchEvents,
                let eventIndex = matchEvents.getIndex(byName: matchRunnerUpdate.eventName)
            else { return }
            let event = matchEvents[eventIndex]
            guard let marketIndex = matchEvents[eventIndex].getMarketIndex(byName: matchRunnerUpdate.marketName) else {
                return
            }
            let market = event.markets[marketIndex]
            let runnerName = matchRunnerUpdate.runnerName
            guard let runnerIndex = market.getRunnerIndex(byName: runnerName) else {
                return
            }
            let newRunner = MatchRunner(name: runnerName,
                                        backOdds: matchRunnerUpdate.backOdds,
                                        layOdds: matchRunnerUpdate.layOdds)
            let newMarker = market.copy(withNewRunner: newRunner, atIndex: runnerIndex)
            let newEvent = event.copy(withNewMarket: newMarker, atIndex: marketIndex)
            let newMatchEvents = matchEvents.replacing(withNewItem: newEvent, atIndex: eventIndex)
            send(result: .success(newMatchEvents))
        default:
            break
        }
    }
}

private extension [MatchEvent] {
    func getIndex(byName name: String) -> Int? {
        return firstIndex { $0.name == name }
    }
}

private extension MatchEvent {
    func getMarketIndex(byName name: String) -> Int? {
        return markets.firstIndex { $0.name == name }
    }
    
    func copy(withNewMarket newMarket: MatchMarket, atIndex index: Int) -> MatchEvent {
        guard (0..<markets.count).contains(index) else { return self }
        let newMarkets: [MatchMarket] = markets.replacing(withNewItem: newMarket, atIndex: index)
        return MatchEvent(name: name,
                          startDate: startDate,
                          markets: newMarkets)
    }
}

private extension MatchMarket {
    func getRunnerIndex(byName name: String) -> Int? {
        return runners.firstIndex { $0.name == name }
    }
    
    func copy(withNewRunner newRunner: MatchRunner, atIndex index: Int) -> MatchMarket {
        guard (0..<runners.count).contains(index) else { return self }
        let newRunners: [MatchRunner] = runners.replacing(withNewItem: newRunner, atIndex: index)
        return MatchMarket(name: name, runners: newRunners)
    }
}

private extension Array {
    func replacing(withNewItem newItem: Element, atIndex index: Int) -> [Element] {
        return enumerated().map { (itemIndex, item) in
            if itemIndex == index {
                    return newItem
                } else {
                    return item
                }
            }
    }
}
