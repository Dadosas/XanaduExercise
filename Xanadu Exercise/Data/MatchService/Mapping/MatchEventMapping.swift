//
//  MatchEventMapping.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

extension MatchEventsDTO {
    func toMatchEvents() throws -> [MatchEvent] {
        return try events.map { try $0.toMatchEvent() }
    }
}

private extension MatchEventDTO {
    func toMatchEvent() throws -> MatchEvent {
        let dateFormatter = ISO8601DateFormatter()
        // allow millis in timestamp
        dateFormatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        guard let startDate = dateFormatter.date(from: startTimestamp) else {
            throw XanaduError.restError
        }
        return MatchEvent(name: self.name,
                          startDate: startDate,
                          markets: self.markets.map({ $0.toMatchMarket() }))
    }
}

private extension MatchMarketDTO {
    func toMatchMarket() -> MatchMarket {
        return MatchMarket(name: self.name,
                           runners: self.runners.map({ $0.toMatchRunner() }))
    }
}

private extension MatchRunnerDTO {
    func toMatchRunner() -> MatchRunner {
        let backOdds = prices.first { $0.side == .back }?.odds
        let layOdds = prices.first { $0.side == .lay }?.odds
        return MatchRunner(name: self.name,
                           backOdds: backOdds,
                           layOdds: layOdds)
    }
}
