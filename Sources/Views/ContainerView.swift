//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 14-03-2024.
//

import Foundation
import SwiftUI
import MemberwiseInit

public struct Container<Header:SwiftUI.View, Body:SwiftUI.View, Label:SwiftUI.View>: SwiftUI.View {
    //    <Header: SwiftUI.View, Body: SwiftUI.View>
    //    let header:()->Header
    //    let body:()->Body
    
    let header_view: ()->Header
    let body_view: ()->Body
    let action: ()->Void
    let label: ()-> Label
    
    var buttonBackground: SwiftUI.Color
    @Environment(\.dismiss) var dismiss
    
    public init(
        buttonBackground: SwiftUI.Color = Color.purple,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder body: @escaping () -> Body,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.buttonBackground = buttonBackground
        self.header_view = header
        self.body_view = body
        self.action = action
        self.label = label
    }
    
    public var body: some SwiftUI.View {
        
        ZStack(alignment: .topLeading) {
            
            ScrollView {
                VStack(alignment: .leading) {
                    ZStack {
                        // Blue background
                        header_view()
                            .edgesIgnoringSafeArea(.top)
                            .frame(height: 200)
                    }

                    body_view()
                        .padding(.horizontal, 24)
                    
                    Spacer()
                }

            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    
                    Button(
                        action: action,
                        label: {
                            label().padding(.vertical, 8)
                        }
                    )
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(buttonBackground)
                    .cornerRadius(8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: 360) 
                    .padding(.horizontal, max(0, (UIScreen.main.bounds.width - 360) / 2))
                }
            }
            
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .accessibilityLabel(Text("Close"))
                        .imageScale(.large)
                        .foregroundStyle(Color.secondary)
                        .fontWeight(.semibold)
                        .padding()
                }
            }
        }
    }
}

public struct Card<Content: SwiftUI.View>: SwiftUI.View {
    
    let variant:Variant
    let content: ()-> Content
    
    public enum Variant {
        case systemGroupedBackground
        case shadow
    }
    
    public init(
        _ variant: Variant = .systemGroupedBackground,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.variant = variant
        self.content = content
    }
    
    var background: Color {
        switch variant {
        case .systemGroupedBackground:
            return Color(.systemGroupedBackground)
        case .shadow:
            return .clear
        }
    }
    
    public var body: some SwiftUI.View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(background)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        
        .cornerRadius(8)
    }
}

public struct Source: SwiftUI.View, Hashable {
    public let title: String
    public let source: String
    
    public init(title: String, source: String) {
        self.title = title
        self.source = source
    }
    
    public var body: some SwiftUI.View {
        Card {
            Text(title)
                .font(.subheadline)
            Text(source)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

extension [Source] {
    
    public struct View:SwiftUI.View {
    
        
        public let sources:[Source]
        
        public init(sources: [Source]) {
            self.sources = sources
        }
        
        public var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sources")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    
                    ForEach(sources, id: \.self) { source in
                        source
                    }
                }
            }
        }
    }
}


#Preview {
    NavigationStack {
        //        Container(body: action: { print("hello") }) {
        //            Text("Next")
        //        }
        
        Container(buttonBackground: .brown) {
            Rectangle()
                .fill(Color.orange)
        } body: {
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Catch procrastination early")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("PRACTICE • 3 min")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Procrastination starts small but it can prevent us from being our best self over time. Let’s learn how to turn away from it early, and get back to work on all the most important things in our lives.")
                        .font(.body)
                }
                .padding(.top)
                
                [Source].View(
                    sources: [
                        Source(
                            title: "Toward a Holistic Approach to Reducing Academic Procrastination With Classroom Interventions",
                            source: "2022, lorem ipsum"
                        ),
                        
                        Source(
                            title: "Toward a Holistic Approach to Reducing Academic Procrastination With Classroom Interventions",
                            source: "2022, lorem ipsum"
                        )
                    ]
                )
                
                // Sources
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sources")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        
                        
                    }
                }
            }
            
            
        } action: {
            print("poop")
        } label: {
            Text("Next")
        }
        
        
        
        
    }
}
