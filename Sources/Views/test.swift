//import ComposableArchitecture
//import SwiftUI
//
//@Reducer
//struct ContentFeature {
//    @Reducer
//    enum Path {
//        case settings(SettingsFeature)
//    }
//
//    @ObservableState
//    struct State {
//        var path = StackState<Path.State>()
//        @Shared var settings: SettingsFeature.State
//    }
//
//    enum Action {
//        case path(StackAction<Path.State, Path.Action>)
//    }
//
//    var body: some ReducerOf<Self> {
//        
//        
//        Reduce { state, action in
//            switch action {
//            default:
//                return .none
//            }
//        }
//        .forEach(\.path, action: \.path)
//    }
//}
//
//struct ContentView: View {
//    @Bindable var store: StoreOf<ContentFeature>
//
//    var body: some View {
//        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
//            NavigationLink(
//                "Go to settings",
//                state: ContentFeature.Path.State.settings(store.settings)
//            )
//        } destination: { store in
//            switch store.case {
//            case .settings(let store):
//                SettingsView(store: store)
//            }
//        }
//    }
//}
//
////MARK: Settings
//@Reducer
//struct SettingsFeature {
//    @ObservableState
//    struct State {
//        var isDebugModeEnabled = false
//        var isAppReadyForProd = false
//    }
//    enum Action {
//        case debugModeToggleChanged(Bool)
//        case appReadyToggleChanged(Bool)
//        case closeButtonTapped
//    }
//
//    @Dependency(\.dismiss) private var dismiss
//
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .debugModeToggleChanged(let isEnabled):
//                state.isDebugModeEnabled = isEnabled
//                return .none
//            case .appReadyToggleChanged(let isEnabled):
//                state.isAppReadyForProd = isEnabled
//                return .none
//            case .closeButtonTapped:
//                return .run { _ in
//                    await self.dismiss()
//                }
//            }
//        }
//    }
//}
//
//struct SettingsView: View {
//    @Bindable var store: StoreOf<SettingsFeature>
//
//    var body: some View {
//        List {
//            Toggle(isOn: $store.isDebugModeEnabled.sending(\.debugModeToggleChanged)) {
//                Text("Enable Debug Mode")
//            }
//            .toggleStyle(.switch)
//
//            Toggle(isOn: $store.isAppReadyForProd.sending(\.appReadyToggleChanged)) {
//                Text("Is App Ready For Production?")
//            }
//            .toggleStyle(.switch)
//
//            Button("Close") {
//                store.send(.closeButtonTapped)
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView(
//        store: Store(
//            initialState: ContentFeature.State.init(settings: Shared<SettingsFeature.State>.init(SettingsFeature.State()))
//        ) {
//            ContentFeature()
//        }
//    )
//}
