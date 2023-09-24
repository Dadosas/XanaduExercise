//
//  MockMatchService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation
import Combine

class MockMatchService: MatchService {
    private let mockEventsJSON = """
{
    "events": [{
            "name": "Turkey vs Italy",
            "start": "2021-06-11T19:00:00.000Z",
            "markets": [{
                "name": "Match Odds",
                "runners": [{
                        "withdrawn": false,
                        "prices": [{
                                "odds": 8.80000,
                                "side": "back"
                            },
                            {
                                "odds": 9.60000,
                                "side": "lay"
                            }
                        ],
                        "name": "Turkey"
                    },
                    {
                        "withdrawn": false,
                        "prices": [{
                                "odds": 1.54054,
                                "side": "back"
                            },
                            {
                                "odds": 1.57143,
                                "side": "lay"
                            }
                        ],
                        "name": "Italy"
                    },

                    {
                        "withdrawn": false,
                        "prices": [{
                                "odds": 3.96000,
                                "side": "back"
                            },
                            {
                                "odds": 4.15000,
                                "side": "lay"
                            }
                        ],
                        "name": "DRAW (Tur/Ita)"
                    }
                ]
            }]
        },
        {
            "name": "UEFA Euro 2020 - Winner",
            "start": "2021-06-11T19:00:00.000Z",
            "markets": [{
                "name": "Winner",
                "start": "2021-06-11T19:00:00.000Z",
                "runners": [{
                        "withdrawn": false,
                        "prices": [{
                                "odds": 5.80000,
                                "side": "back"
                            },
                            {
                                "odds": 6.20000,
                                "side": "lay"
                            }
                        ],
                        "name": "France"
                    },
                    {
                        "withdrawn": false,
                        "prices": [{
                                "odds": 6.80000,
                                "side": "back"
                            },
                            {
                                "odds": 7.50000,
                                "side": "lay"
                            }
                        ],
                        "name": "England"
                    },
                    {
                        "withdrawn": false,
                        "prices": [{
                                "odds": 7.10000,
                                "side": "back"
                            },
                            {
                                "odds": 8.60000,
                                "side": "lay"
                            }
                        ],
                        "name": "Belgium"
                    }
                ]
            }]
        }
    ]
}
"""
    
    func getEvents(queryTag: String) -> AnyPublisher<[MatchEvent], Error> {
        return Future { [weak self] promise in
            print("Start timer")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                guard let data = self?.mockEventsJSON.data(using: .utf8) else {
                    return promise(.failure(RESTError.loadingFailure))
                }
                guard let mockEventsDTO = try? JSONDecoder().decode(MatchEventsDTO.self, from: data) else {
                    return promise(.failure(RESTError.parsingFailure))
                }
                guard let mockMatchEvents = try? mockEventsDTO.toMatchEvents() else {
                    return promise(.failure(RESTError.parsingFailure))
                }
                print("Returning mock data")
                promise(.success(mockMatchEvents))
            }
        }
        .eraseToAnyPublisher()
    }
}
