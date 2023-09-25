//
//  MatchServiceImpl.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

class MatchServiceImpl: MatchService {
    
    private var cancellables: [AnyCancellable] = []
    
    func getEvents(queryTag: String) -> AnyPublisher<[MatchEvent], XanaduError> {
        let urlQueryParameters = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "currency", value: "EUR"),
            URLQueryItem(name: "exchange-type", value: "back-lay"),
            URLQueryItem(name: "odds-type", value: "DECIMAL"),
            URLQueryItem(name: "price-depth", value: "1"),
            URLQueryItem(name: "per-page", value: "100"),
            URLQueryItem(name: "market-states", value: "open"),
            URLQueryItem(name: "runner-states", value: "open"),
            URLQueryItem(name: "market-auto-sequence", value: "true"),
            URLQueryItem(name: "tag-url-names", value: queryTag)
        ]
        let url = URL(string: "https://www.matchbook.com/edge/rest/events", urlQueryItems: urlQueryParameters)
        let urlRequest = url?.toXanaduURLRequest()
        return Future<MatchEventsDTO, XanaduError>.startURLRequest(urlRequest: urlRequest) { [weak self] publisher in
            guard let this = self else { return }
            publisher.store(in: &this.cancellables)
        }
        .tryMap({ (matchEventsDTO: MatchEventsDTO) -> [MatchEvent] in try matchEventsDTO.toMatchEvents() })
        .mapError({ _ in XanaduError.restError })
        .eraseToAnyPublisher()
    }
}
