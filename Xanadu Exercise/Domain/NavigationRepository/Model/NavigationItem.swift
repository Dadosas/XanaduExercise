//
//  NavigationItem.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

class NavigationItem {
    
    let name: String
    private let urlTag: String
    private let children: [NavigationItem]
    private weak var parent: NavigationItem?
    
    private lazy var urlTags: [String] = {
        let parentTags = parent?.getUrlTags() ?? []
        return parentTags + [urlTag]
    }()
    
    init(name: String, tag: String, children: [NavigationItem]) {
        self.name = name
        self.urlTag = tag
        self.children = children
        children.forEach { $0.set(parent: self) }
    }
    
    func set(parent: NavigationItem) {
        self.parent = parent
    }
    
    func getSelfAndAllChildren() -> [NavigationItem] {
        return [self] + children.flatMap({ $0.getSelfAndAllChildren() })
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
    
    func isAccessibleEvent() -> Bool {
        return children.isEmpty
    }
}
