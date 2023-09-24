//
//  MockNavigationService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

class MockNavigationService: NavigationService {
    
    static var simulateErrorOnFirstCall = false
    
    private let mockNavigationJSON = """
[
{
"name": "Sport",
"url-name": "sport",
"meta-tags": [
{
"name": "Soccer",
"url-name": "soccer",
"meta-tags": [
{
"name": "FIFA International Friendlies",
"url-name": "fifa-international-friendlies",
"meta-tags": []
},
{
"name": "UEFA Euro 2020 ",
"url-name": "uefa-euro-2020",
"meta-tags": [
{
"name": "Group A",
"url-name": "group-a",
"meta-tags": []
},
{
"name": "Group B",
"url-name": "group-b",
"meta-tags": []
}
]
},
{
"name": "Australia",
"url-name": "australia",
"meta-tags": [
{
"name": "Hyundai A-League",
"url-name": "hyundai-a-league",
"meta-tags": []
}
]
}
]
},
{
"name": "Tennis",
"url-name": "tennis",
"meta-tags": [
{
"name": "ATP French Open",
"url-name": "atp-french-open",
"meta-tags": [
{
"name": "Outrights",
"url-name": "outrights",
"meta-tags": []
}
]
},

{
"name": "ATP Stuttgart",
"url-name": "atp-stuttgart",
"meta-tags": []
} ]
}
]
}
]
"""
    
    func getNavigationTree() -> AnyPublisher<NavigationDTO, Error> {
        return Future { [weak self] promise in
            guard var mockNavigationJSON = self?.mockNavigationJSON else {
                return promise(.failure(RESTError.loadingFailure))
            }
            if Self.simulateErrorOnFirstCall {
                Self.simulateErrorOnFirstCall = false
                mockNavigationJSON.insert(";", at: String.Index(utf16Offset: 123, in: mockNavigationJSON))
            }
            print("Start timer")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                guard let data = mockNavigationJSON.data(using: .utf8) else {
                    return promise(.failure(RESTError.loadingFailure))
                }
                guard let mockNavigationDTO = try? JSONDecoder().decode(NavigationDTO.self, from: data) else {
                    return promise(.failure(RESTError.parsingFailure))
                }
                print("Returning mock DTO")
                promise(.success(mockNavigationDTO))
            }
        }
        .eraseToAnyPublisher()
    }
}
