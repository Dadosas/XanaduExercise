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
        return sportMetaTag.metaTags
            .flatMap({ $0.toNavigationItems() })
    }
}

private extension MetaTagDTO {
    func toNavigationItem() -> NavigationItem {
        return NavigationItem(name: self.name, tag: self.urlName, isNavigableTo: metaTags.isEmpty)
    }
    
    func toNavigationItems() -> [NavigationItem] {
        return [self.toNavigationItem()] + self.metaTags.flatMap({ $0.toNavigationItems() })
    }
}
