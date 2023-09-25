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

enum EventDetailRow {
    case event(name: String,
               dateLabel: String)
    case market(name: String)
    case runner(name: String,
                backOddsLabel: String,
                layOddsLabel: String)
}

class EventDetailViewModelImpl: EventDetailViewModel {
    
    let navigationItem: NavigationItem
    private let matchService: MatchService
    
    private let eventDetailState: CurrentValueSubject<EventDetailState, Never> = .init(.loading)
    private var cancellables: [AnyCancellable] = []
    
    init(navigationItem: NavigationItem, matchService: MatchService) {
        self.navigationItem = navigationItem
        self.matchService = matchService
        requestDataFromREST()
        
        Timer.TimerPublisher(interval: 5, runLoop: RunLoop.main, mode: .default)
            .autoconnect()
            .sink { [weak self] _ in
                print("Polling time!")
                self?.requestDataFromREST()
            }
            .store(in: &cancellables)
    }
    
    convenience init(navigationItem: NavigationItem, appDependencies: AppDependencies) {
        self.init(navigationItem: navigationItem, matchService: appDependencies.matchService)
    }
    
    private func requestDataFromREST() {
        matchService
            .getEvents(queryTag: navigationItem.getUrlTagsForQuery())
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map { (matchEvents) in
                let sortedEvents = matchEvents.sorted { lhs, rhs in lhs.startDate < rhs.startDate }
                let rows = sortedEvents.getRows()
                return EventDetailState.loaded(rows: rows)
            }
            .replaceError(with: EventDetailState.error)
            .receive(on: DispatchQueue.main)
            .sink { [weak eventDetailState] in eventDetailState?.send($0) }
            .store(in: &cancellables)
    }
    
    func publishEventDetailState() -> AnyPublisher<EventDetailState, Never> {
        return eventDetailState.eraseToAnyPublisher()
    }
    
    func retry() {
        guard case .error = eventDetailState.value else { return }
        requestDataFromREST()
        eventDetailState.send(.loading)
    }
}

private extension [MatchEvent] {
    func getRows() -> [EventDetailRow] {
        return reduce(into: [EventDetailRow]()) { partialResult, currentEvent in
            partialResult += currentEvent.getRows()
        }
    }
}

private extension MatchEvent {
    func getRows() -> [EventDetailRow] {
        let dateLabel = self.startDate.formatted(date: .abbreviated, time: .shortened)
        let eventRow = EventDetailRow.event(name: self.name, dateLabel: dateLabel)
        
        return [eventRow] + self.markets.flatMap({ $0.getRows() })
    }
}

private extension MatchMarket {
    func getRows() -> [EventDetailRow] {
        let marketRow = EventDetailRow.market(name: self.name)
        
        return [marketRow] + self.runners.map({ $0.getRow() })
    }
}

private extension MatchRunner {
    func getRow() -> EventDetailRow {
        let roundToTwoDecimals: (Double) -> String = { String(format: "%.2f", $0) }
        let backOddsLabel: String
        if let backOdds = self.backOdds {
            backOddsLabel = roundToTwoDecimals(backOdds)
        } else {
            backOddsLabel = "NO BACK"
        }
        
        let layOddsLabel: String
        if let layOdds = self.layOdds {
            layOddsLabel = roundToTwoDecimals(layOdds)
        } else {
            layOddsLabel = "NO LAY"
        }
        
        return EventDetailRow.runner(name: self.name,
                                     backOddsLabel: backOddsLabel,
                                     layOddsLabel: layOddsLabel)
    }
}
