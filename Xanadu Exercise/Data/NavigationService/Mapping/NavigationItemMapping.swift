//
//  NavigationItemMapping.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

extension NavigationDTO {
    func toNavigationItems() -> [NavigationItem]? {
        guard let sportMetaTag = self.first else { return nil }
        let rootNavigationItem = sportMetaTag.toNavigationItem()
        return sportMetaTag.metaTags
            .map { $0.toNavigationItem() }
            .flatMap({ $0.getSelfAndAllChildren() })
    }
}

private extension MetaTagDTO {
    func toNavigationItem() -> NavigationItem {
        return NavigationItem(name: self.name, tag: self.urlName, children: metaTags.compactMap { $0.toNavigationItem() })
    }
}
