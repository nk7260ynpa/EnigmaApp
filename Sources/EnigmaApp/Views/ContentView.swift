import SwiftUI
import SceneKit

/// 主視窗內容
struct ContentView: View {
    @Bindable var viewModel: SceneViewModel
    @State private var showSettings = true

    var body: some View {
        NavigationSplitView {
            if showSettings {
                SettingsPanel(viewModel: viewModel)
                    .frame(minWidth: 250)
            }
        } detail: {
            VStack(spacing: 0) {
                EnigmaSceneView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                OperationPanel(viewModel: viewModel)
                    .frame(height: 200)
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation {
                        showSettings.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.left")
                }
                .help("切換設定面板")
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                return viewModel.handleKeyEvent(event)
            }
        }
    }
}
