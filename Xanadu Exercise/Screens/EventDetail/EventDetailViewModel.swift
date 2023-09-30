//
//  EventDetailViewModel.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

protocol EventDetailViewModel {
    var navigationItem: NavigationItem { get }
    func publishEventDetailState() -> AnyPublisher<EventDetailState, Never>
    func retry()
}

enum EventDetailState {
    case loading
    case error
    case loaded(rows: [EventDetailRow])
}

enum EventDetailRow: Hashable {
    case event(Event)
    case market(Market)
    case runner(Runner)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .event(let item):
            hasher.combine("\(item.id)_event")
        case .market(let item):
            hasher.combine("\(item.id)_market")
        case .runner(let item):
            hasher.combine("\(item.id)_runner")
        }
    }
    
    static func == (lhs: EventDetailRow, rhs: EventDetailRow) -> Bool {
        switch (lhs, rhs) {
        case (.event(let leftEvent), .event(let rightEvent)):
            return leftEvent == rightEvent
        case (.market(let leftMarket), .market(let rightMarket)):
            return leftMarket == rightMarket
        case (.runner(let leftRunner), .runner(let rightRunner)):
            return leftRunner == rightRunner
        default:
            return false
        }
    }
    
    struct Event: Hashable {
        let id: String
        let name: String
        let dateText: String
        
        func asRow() -> EventDetailRow {
            return .event(self)
        }
    }
    
    struct Market: Hashable {
        let id: String
        let name: String
        
        func asRow() -> EventDetailRow {
            return .market(self)
        }
    }
    
    struct Runner: Hashable {
        let id: String
        let name: String
        let backOddsText: String
        let layOddsText: String
        
        func asRow() -> EventDetailRow {
            return .runner(self)
        }
    }
}

class DefaultEventDetailViewModel: EventDetailViewModel {
    
    let navigationItem: NavigationItem
    private let matchRepository: MatchRepository
    
    private let eventDetailState: CurrentValueSubject<EventDetailState, Never> = .init(.loading)
    private var cancellables: [AnyCancellable] = []
    
    init(navigationItem: NavigationItem, matchRepository: MatchRepository) {
        self.navigationItem = navigationItem
        self.matchRepository = matchRepository
        
        let matchQueryIdentifier = MatchQueryIdentifier(currentTag: navigationItem.urlTag, fullTag: navigationItem.getUrlTagsForQuery())
        matchRepository.set(matchQueryIdentifier: matchQueryIdentifier)
        subscribeToRepository()
        matchRepository.requestMatchEventsResult()
        
        startPolling()
    }
    
    convenience init(navigationItem: NavigationItem, appDependencies: AppDependencies) {
        self.init(navigationItem: navigationItem, matchRepository: appDependencies.matchRepository)
    }
    
    deinit {
        matchRepository.set(matchQueryIdentifier: nil)
    }
    
    private func subscribeToRepository() {
        matchRepository.publishMatchEventsResult()
            .map { (matchEventsResult) in
                switch matchEventsResult {
                case .success(let matchEvents):
                    guard let matchEvents = matchEvents else {
                        return EventDetailState.loading
                    }
                    let sortedEvents = matchEvents.sorted { lhs, rhs in lhs.startDate < rhs.startDate }
                    let rows = sortedEvents.getRows()
                    return EventDetailState.loaded(rows: rows)
                case .failure:
                    return EventDetailState.error
                }
            }
            .sink { [weak eventDetailState] in eventDetailState?.send($0) }
            .store(in: &cancellables)
    }
    
    func publishEventDetailState() -> AnyPublisher<EventDetailState, Never> {
        return eventDetailState.eraseToAnyPublisher()
    }
    
    func retry() {
        guard case .error = eventDetailState.value else { return }
        matchRepository.requestMatchEventsResult()
        eventDetailState.send(.loading)
    }
    
    private func startPolling() {
        Timer.publish(every: 5, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let this = self else { return }
                switch this.eventDetailState.value {
                case .loaded:
                    print("Polling time!")
                    this.matchRepository.requestMatchEventsResult()
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

// index passed to these methods is needed to disambiguate between items with the same id
// this edge case (which I didn't originally consider) was happening for Markets and causing crashes
private extension [MatchEvent] {
    func getRows() -> [EventDetailRow] {
        return enumerated().reduce(into: [EventDetailRow]()) { partialResult, arg in
            let (index, currentEvent) = arg
            partialResult += currentEvent.getRows(index: index)
        }
    }
}

private extension MatchEvent {
    func getRows(index: Int) -> [EventDetailRow] {
        let id = "\(self.name)\(index)"
        let dateLabel = self.startDate.formatted(date: .abbreviated, time: .shortened)
        let event = EventDetailRow.Event(id: id, name: self.name, dateText: dateLabel)

        return [event.asRow()] + self.markets.enumerated().flatMap({ (index, market) in
            market.getRows(eventId: event.id, index: index)
        })
    }
}

private extension MatchMarket {
    func getRows(eventId: String, index: Int) -> [EventDetailRow] {
        let id = "\(eventId)_\(self.name)\(index)"
        let market = EventDetailRow.Market(id: id, name: self.name)
        return [market.asRow()] + self.runners.enumerated().map({ (index, runner) in
            runner.getRow(marketId: market.id, index: index)
        })
    }
}

private extension MatchRunner {
    func getRow(marketId: String, index: Int) -> EventDetailRow {
        let roundToTwoDecimals: (Double) -> String = { String(format: "%.2f", $0) }
        let backOddsText: String
        if let backOdds = self.backOdds {
            backOddsText = roundToTwoDecimals(backOdds)
        } else {
            backOddsText = "NO BACK"
        }
        
        let layOddsText: String
        if let layOdds = self.layOdds {
            layOddsText = roundToTwoDecimals(layOdds)
        } else {
            layOddsText = "NO LAY"
        }
        
        let id = "\(marketId)_\(self.name)\(index)"
        return EventDetailRow.Runner(id: id,
                                     name: self.name,
                                     backOddsText: backOddsText,
                                     layOddsText: layOddsText).asRow()
    }
}
