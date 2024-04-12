//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 11-04-2024.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Output: Codable, Hashable {
    @Init(default: nil)
    public let bool: Bool?
    @Init(default: "")
    public let string:String
}

extension Output {
    public var calculation:Bool {
        bool ?? false
    }
}
