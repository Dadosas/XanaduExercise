//
//  MockNavigationService.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation
import Combine

class MockNavigationService: NavigationService {
    
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
    
    func getNavigationTree() -> Future<NavigationDTO, Error> {
        return Future { promise in
            print("Start timer")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                guard let data = self.mockNavigationJSON.data(using: .utf8) else {
                    return promise(.failure(NavigationRepositoryError.loadingFailure))
                }
                guard let mockNavigationDTO = try? JSONDecoder().decode(NavigationDTO.self, from: data) else {
                    return promise(.failure(NavigationRepositoryError.parsingFailure))
                }
                print("Returning mock DTO")
                promise(.success(mockNavigationDTO))
            }
        }
    }
}
