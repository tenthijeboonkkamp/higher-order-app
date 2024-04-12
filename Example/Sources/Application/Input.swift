//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 10-04-2024.
//

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Input: Hashable, Codable {
    public var bool: Bool? = nil
    public var string:String = ""
}

