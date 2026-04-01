import SwiftUI
import EnigmaCore

/// EnigmaApp 應用程式入口
@main
struct EnigmaAppMain: App {
    @State private var viewModel = SceneViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 1024, minHeight: 768)
        }
        .commands {
            EnigmaCommands(viewModel: viewModel)
        }
    }
}
