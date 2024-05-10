//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 10-04-2024.
//

import Foundation
import Output

extension Output {
    @Sendable public init (input: Application.Input) async throws {
        self = .init(
            calculation: input.bool == true ? true : nil
        )
    }
}
