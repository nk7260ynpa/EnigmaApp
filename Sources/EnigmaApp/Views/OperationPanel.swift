import SwiftUI
import EnigmaCore

/// 操作面板（底部）
struct OperationPanel: View {
    @Bindable var viewModel: SceneViewModel
    @State private var batchInput: String = ""

    var body: some View {
        HStack(spacing: 16) {
            // MARK: - 文字輸入/輸出
            VStack(alignment: .leading, spacing: 8) {
                Text("文字加密")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("輸入")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("輸入明文...", text: $batchInput)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                encryptBatch()
                            }
                    }

                    Button("加密") {
                        encryptBatch()
                    }
                    .buttonStyle(.borderedProminent)
                }

                HStack(spacing: 4) {
                    Text("輸出：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.outputText)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)

            Divider()

            // MARK: - 歷史記錄
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("操作歷程")
                        .font(.headline)
                    Spacer()
                    Button("重置") {
                        viewModel.resetPositions()
                        batchInput = ""
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }

                ScrollView(.horizontal) {
                    HStack(spacing: 2) {
                        ForEach(viewModel.history.suffix(50)) { entry in
                            VStack(spacing: 2) {
                                Text(String(entry.input))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Text("↓")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(String(entry.output))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .fontWeight(.bold)
                            }
                            .frame(width: 18)
                        }
                    }
                }
                .frame(maxHeight: 60)
            }
            .frame(width: 300)
        }
        .padding()
        .background(.bar)
    }

    /// 批次加密輸入文字
    private func encryptBatch() {
        for char in batchInput {
            viewModel.pressKey(char)
        }
        batchInput = ""
    }
}
