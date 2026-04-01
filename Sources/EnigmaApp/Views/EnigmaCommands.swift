import SwiftUI
import UniformTypeIdentifiers
import EnigmaCore

/// macOS 選單列命令
struct EnigmaCommands: Commands {
    @Bindable var viewModel: SceneViewModel

    var body: some Commands {
        // MARK: - 檔案選單
        CommandGroup(after: .newItem) {
            Button("匯出設定...") {
                exportConfiguration()
            }
            .keyboardShortcut("e", modifiers: .command)

            Button("匯入設定...") {
                importConfiguration()
            }
            .keyboardShortcut("i", modifiers: .command)
        }

        // MARK: - 編輯選單
        CommandGroup(after: .pasteboard) {
            Button("複製加密結果") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(viewModel.outputText, forType: .string)
            }
            .disabled(viewModel.outputText.isEmpty)
        }

        // MARK: - 檢視選單
        CommandGroup(after: .toolbar) {
            Button("重置轉子位置") {
                viewModel.resetPositions()
            }
            .keyboardShortcut("r", modifiers: .command)
        }

        // MARK: - 說明選單
        CommandGroup(replacing: .help) {
            Button("Enigma 密碼機介紹") {
                showAboutEnigma()
            }
            Button("操作說明") {
                showHelp()
            }
        }
    }

    // MARK: - 匯出設定

    private func exportConfiguration() {
        let config = viewModel.currentConfiguration()
        guard let data = try? config.toJSON() else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "enigma-config.json"
        panel.title = "匯出 Enigma 設定"

        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url)
        }
    }

    // MARK: - 匯入設定

    private func importConfiguration() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.title = "匯入 Enigma 設定"
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            guard let data = try? Data(contentsOf: url),
                  let config = try? MachineConfiguration.fromJSON(data) else {
                showError("無法讀取設定檔案")
                return
            }

            let errors = config.validate()
            if !errors.isEmpty {
                showError("設定檔案無效：\n\(errors.joined(separator: "\n"))")
                return
            }

            viewModel.applyConfiguration(config)
        }
    }

    // MARK: - 說明視窗

    private func showAboutEnigma() {
        let alert = NSAlert()
        alert.messageText = "Enigma 密碼機"
        alert.informativeText = """
        Enigma 是二戰期間德軍廣泛使用的電動機械式加密裝置。

        本應用程式模擬標準三轉子 Wehrmacht Enigma 機器，\
        包含 5 種可選轉子（I–V）、2 種反射器（B、C）以及接線板。

        加密流程：
        訊號通過接線板 → 轉子（右→左）→ 反射器 → 轉子（左→右）→ 接線板

        相同設定下，加密與解密使用相同操作。
        """
        alert.alertStyle = .informational
        alert.runModal()
    }

    private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "操作說明"
        alert.informativeText = """
        鍵盤操作：
        • 直接輸入 A–Z 字母進行加密
        • 點擊 3D 鍵盤按鍵

        快捷鍵：
        • ⌘R — 重置轉子位置
        • ⌘E — 匯出設定
        • ⌘I — 匯入設定

        3D 互動：
        • 點擊按鍵 — 加密字母
        • 拖曳轉子 — 設定位置
        • 拖曳/縮放 — 控制視角
        """
        alert.alertStyle = .informational
        alert.runModal()
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "錯誤"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
