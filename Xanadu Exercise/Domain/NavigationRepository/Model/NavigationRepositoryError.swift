//
//  NavigationRepositoryError.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

enum NavigationRepositoryError: Error {
    case loadingFailure
    case parsingFailure
    case unknownFailure
}
