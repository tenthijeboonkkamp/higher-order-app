//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 11-04-2024.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Output: Codable, Hashable, Sendable {
    @Init(default: nil)
    public var calculation:Bool?
}

