//
//  NavigationItem.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

class NavigationItem {
    
    let name: String
    let urlTag: String
    let isNavigableTo: Bool
    private weak var parent: NavigationItem?
    
    private lazy var urlTags: [String] = {
        let parentTags = parent?.getUrlTags() ?? []
        return parentTags + [urlTag]
    }()
    
    init(name: String, tag: String, isNavigableTo: Bool) {
        self.name = name
        self.urlTag = tag
        self.isNavigableTo = isNavigableTo
    }
    
    func set(parent: NavigationItem) {
        self.parent = parent
    }
    
    func getUrlTags() -> [String] {
        return urlTags
    }
    
    func getUrlTagsForQuery() -> String {
        return getUrlTags().joined(separator: ",")
    }
    
    func getDepth() -> Int {
        return getUrlTags().count
    }
}

extension NavigationItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(urlTag)
        hasher.combine(isNavigableTo)
    }
    
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        return lhs.name == rhs.name && lhs.urlTag == rhs.urlTag && lhs.isNavigableTo == rhs.isNavigableTo
    }
}
