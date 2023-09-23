//
//  NavigationDTO.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import Foundation

typealias NavigationDTO = [MetaTagDTO]

struct MetaTagDTO: Codable {
    let name: String
    let urlName: String
    let metaTags: [MetaTagDTO]
    
    enum CodingKeys: String, CodingKey {
        case name
        case urlName = "url-name"
        case metaTags = "meta-tags"
    }
}
