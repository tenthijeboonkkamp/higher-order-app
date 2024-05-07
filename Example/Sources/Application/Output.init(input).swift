//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 10-04-2024.
//

import Foundation
import Output

extension Output {
    @Sendable public init (input: Input) async throws {
        self = .init(
            bool: input.bool,
            string: input.string
        )
    }
}
