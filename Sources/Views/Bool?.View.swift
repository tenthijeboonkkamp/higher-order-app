//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 14-03-2024.
//

import Foundation
import SwiftUI
import MemberwiseInit

extension Bool? {
    public struct View: SwiftUI.View {
        public let variant: Variant
        let question:String
        @Binding var answer: Bool?
        
        public enum Variant {
            case form
            case fullscreen
            
            @MemberwiseInit(.public)
            public struct Fullscreen {}
        }
        
        public init(
            variant: Variant = .form,
            question: String,
            answer: Binding<Bool?>
        ) {
            self.variant = variant
            self.question = question
            self._answer = answer
        }
        
        public var body: some SwiftUI.View {
            switch variant {
            case .form:
                Section {
                    Text(question)
                    

                    GenericPicker(
                        selection: $answer,
                        cases: [true, false]
                    ) {
                        Text($0.description)
                    } label: {
                        Text("Answer")
                    }
                    
//                    Picker(selection: $answer.animation()) {
//                        ForEach([true, false], id: \.self) { option in
//                            Text(option.description)
//                                .tag(Optional(option))
//                        }
//                    } label: {
//                        Text("Answer")
//                    }
//                    .pickerStyle(.segmented)

                } footer: {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                self.answer = nil
                            }
                        } label: {
                            if answer != nil {
                                Text("clear")
                                    .font(.callout)
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }
            case .fullscreen:
                ZStack {
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
                    }
                    .padding()
                    
                    Spacer()
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            Text("No")
                            Spacer()
                            Text("Yes")
                        }
                    }
                }
            }
        }
    }
}

#Preview("Form"){
    
    struct PreviewWrapper: SwiftUI.View {
        @SwiftUI.State var answer:Bool? = nil
        
        var body: some View {
            NavigationStack {
                Form {
                    Bool?.View(
                        question: "hello?",
                        answer: $answer
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
    
    
}


#Preview("Fullscreen"){
    
    struct PreviewWrapper: SwiftUI.View {
        @SwiftUI.State var answer:Bool? = nil
        
        var body: some View {
            NavigationStack {
                Form {
                    Bool?.View(
                        variant: .fullscreen,
                        question: "hello?",
                        answer: $answer
                    )
                }
            }
        }
    }
    
    return PreviewWrapper()
    
    
}




struct SurveyView: View {
    @State private var answer: Bool? = nil

    var body: some View {
        ZStack {
            // Background design elements
            VStack {
                Color.clear // Transparent layer, could be used for spacing or background color
                Spacer()
            }

            VStack {
                // Header with progress indicator and close button
                HStack {
                    Text("08:01")
                    Spacer()
                    Text("Question 1 of 9")
                    Spacer()
                    Button(action: {
                        // Action to close or dismiss
                    }) {
                        Image(systemName: "xmark.circle") // System icon for close button
                            .imageScale(.large)
                    }
                }
                .padding()

                // Question content area
                VStack(alignment: .leading, spacing: 20) {
                    Text("In moments when I'm procrastinating I'm so...")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Doing other work")
                        .font(.title2)
                    Text("As in: Doing a different, less important task from the one I should be doing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()

                // Yes and No buttons at the bottom
                HStack {
                    Button {
                        answer = false
                    } label: {
                        Card(.shadow) {
                            HStack(alignment: .center) {
                                Spacer()
                                VStack(alignment: .center, spacing: 0) {
                                    Image(systemName: "checkmark.circle")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.red)
                                    Text("No")
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.primary)
                                }
                                Spacer()
                            }
                            .padding(.vertical)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    Button {
                        answer = true
                    } label: {
                        Card(.shadow) {
                            HStack(alignment: .center) {
                                Spacer()
                                VStack(alignment: .center, spacing: 0) {
                                    Image(systemName: "checkmark.circle")
                                        .imageScale(.large)
                                        .foregroundStyle(Color.green)
                                    Text("Yes")
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.primary)
                                }
                                Spacer()
                            }
                            .padding(.vertical)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                    }
                    
                }
//                .padding(.horizontal)
            }
        }
    }
}

#Preview("SurveryView") {
    SurveyView()
}
