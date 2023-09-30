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
            .receive(on: DispatchQueue.main)
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
