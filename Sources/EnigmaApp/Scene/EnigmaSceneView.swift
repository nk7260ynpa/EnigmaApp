import SwiftUI
import SceneKit

/// SceneKit 3D 場景的 SwiftUI 包裝
struct EnigmaSceneView: NSViewRepresentable {
    @Bindable var viewModel: SceneViewModel

    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero, options: [
            SCNView.Option.preferredRenderingAPI.rawValue: SCNRenderingAPI.metal.rawValue
        ])
        scnView.scene = viewModel.scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = .black
        scnView.antialiasingMode = .multisampling4X
        scnView.showsStatistics = false

        // 設定點擊手勢
        let clickGesture = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleClick(_:))
        )
        scnView.addGestureRecognizer(clickGesture)

        // 設定拖曳手勢
        let panGesture = NSPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        panGesture.buttonMask = 0x2  // 右鍵拖曳用於元件互動
        scnView.addGestureRecognizer(panGesture)

        context.coordinator.scnView = scnView

        return scnView
    }

    func updateNSView(_ scnView: SCNView, context: Context) {
        scnView.scene = viewModel.scene
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    @MainActor
    class Coordinator: NSObject {
        let viewModel: SceneViewModel
        weak var scnView: SCNView?

        init(viewModel: SceneViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleClick(_ gesture: NSClickGestureRecognizer) {
            guard let scnView = scnView else { return }
            let location = gesture.location(in: scnView)
            let hitResults = scnView.hitTest(location, options: [
                .searchMode: SCNHitTestSearchMode.closest.rawValue
            ])

            if let hit = hitResults.first {
                viewModel.handleHitTestResult(hit)
            }
        }

        @objc func handlePan(_ gesture: NSPanGestureRecognizer) {
            guard let scnView = scnView else { return }
            let location = gesture.location(in: scnView)
            let translation = gesture.translation(in: scnView)

            switch gesture.state {
            case .began:
                let hitResults = scnView.hitTest(location, options: [
                    .searchMode: SCNHitTestSearchMode.closest.rawValue
                ])
                if let hit = hitResults.first {
                    viewModel.handleDragBegan(hit, translation: translation)
                }
            case .changed:
                viewModel.handleDragChanged(translation: translation)
            case .ended, .cancelled:
                viewModel.handleDragEnded()
            default:
                break
            }
        }
    }
}
