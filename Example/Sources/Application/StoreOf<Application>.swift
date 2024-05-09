//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 07-05-2024.
//

import Foundation
import HigherOrderAppWithCollection
import ComposableArchitecture
import SwiftUI

extension StoreOf<Application> {
    public static var `default`:StoreOf<Application> {
        Store(
            initialState: Application.State.init(
                higherOrder: .init(
                    tint: Shared(
                        wrappedValue: Color.green,
                        .fileStorage(.documentsDirectory.appending(path: "color.json"))
                    ),
                    destination: .collectionFeature(.init(elements: Shared(
                        wrappedValue: .init(uniqueElements: []),
                        .fileStorage(.documentsDirectory.appending(path: "elements.json"))
                    )))
                ),
                elements: Shared(
                    wrappedValue: .init(uniqueElements: []),
                    .fileStorage(.documentsDirectory.appending(path: "elements.json"))
                )
            ),
            reducer: {
                Application.default
            }
        )
    }
}
//tint: Shared(
//    wrappedValue: Color.green,
//    .fileStorage(.documentsDirectory.appending(path: "color.json"))
//)
