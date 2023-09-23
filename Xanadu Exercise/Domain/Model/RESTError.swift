//
//  RESTError.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import Foundation

enum RESTError: Error {
    case loadingFailure
    case parsingFailure
    case unknownFailure
}
