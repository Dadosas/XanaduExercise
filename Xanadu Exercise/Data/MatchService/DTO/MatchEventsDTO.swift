//
//  MatchEventsDTO.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

struct MatchEventsDTO: Codable {
    
    let events: [MatchEventDTO]
}

struct MatchEventDTO: Codable {
    
    let name: String
    let startTimestamp: String
    let markets: [MatchMarketDTO]
    
    enum CodingKeys: String, CodingKey {
        case name
        case startTimestamp = "start"
        case markets
    }
}

struct MatchMarketDTO: Codable {
    
    let name: String
    let runners: [MatchRunnerDTO]
}

struct MatchRunnerDTO: Codable {
    
    let name: String
    let prices: [Price]
    
    struct Price: Codable {
        
        let odds: Double
        let side: Side
        
        enum Side: String, Codable {
            case back
            case lay
        }
    }
}
