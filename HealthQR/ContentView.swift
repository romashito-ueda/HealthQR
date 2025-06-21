import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var parsedData: [(MeasureInfo, String)] = []
    @State private var showResultView = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                QRScannerView(scannedCode: $scannedCode)
                    .frame(height: 400)

                Text("QRコードをタップで読み取ってください")
                    .foregroundColor(.gray)
            }
            .onChange(of: scannedCode) { _, newValue in
                guard let code = newValue else { return }

                // 1) パース
                parsedData = parsePayload(code)

                // 2) HealthKit 保存（非同期）
                let dict = Dictionary(uniqueKeysWithValues:
                                      parsedData.map { ($0.0.label, $0.1) })
                Task {
                    try? await HealthKitManager.shared.save(dict: dict)
                }

                // 3) 遷移
                alertMessage  = "読み取り成功: \(code.prefix(30))..."
                showResultView = true
            }
            .navigationDestination(isPresented: $showResultView) {
                ResultView(rows: parsedData)
            }
            .alert("Scan",
                   isPresented: .constant(alertMessage != nil),
                   actions: { Button("OK") { alertMessage = nil } },
                   message: { Text(alertMessage ?? "") })
        }
        // 権限ダイアログは画面初回表示時に1回だけ
        .task {
            HealthKitManager.shared.requestAuth()
        }
    }

    private func parsePayload(_ payload: String) -> [(MeasureInfo, String)] {
        payload
            .split(separator: "&")
            .compactMap { pair -> (MeasureInfo, String)? in
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard parts.count == 2,
                      let keyEnum = MeasureKey(rawValue: parts[0]),
                      let info    = measureMap[keyEnum] else { return nil }
                return (info, parts[1])
            }
    }
}
