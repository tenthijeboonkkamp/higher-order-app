//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 07-05-2024.
//

import Foundation
import HigherOrderApp
import ComposableArchitecture
import SwiftUI

extension StoreOf<Application> {
    public static let `default`:StoreOf<Application> = Store(
        initialState: Application.State.init(
            tint: Shared(
                wrappedValue: Color.green,
                .fileStorage(.documentsDirectory.appending(path: "color.json"))
            ),
            elements: Shared(
                wrappedValue: .init(uniqueElements: []),
                .fileStorage(.documentsDirectory.appending(path: "elements.json"))
            )
        ),
        reducer: { Application.default }
    )
}
