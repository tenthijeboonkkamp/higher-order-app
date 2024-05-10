//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 10-04-2024.
//

import Foundation
import MemberwiseInit

//@MemberwiseInit(.public)
public struct Input: Sendable, Hashable, Codable {
    @Init(default: nil)
    public var bool: Bool?
    @Init(default: "")
    public var string:String
    
    @Sendable public init(bool: Bool? = nil, string: String = "") {
        self.bool = bool
        self.string = string
    }
}

