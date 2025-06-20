import SwiftUI
import SwiftUICore   // ※Xcode 16 なら SwiftUI だけでOK（SwiftUICore は不要）

struct ContentView: View {
    @State private var scannedCode: String?          // QR の生文字列
    @State private var parsedData: [(MeasureInfo, String)] = [] // 次画面に渡す
    @State private var showResultView = false        // ナビゲーション用トリガ
    @State private var alertMessage: String?         // デバッグ用アラート

    var body: some View {
        NavigationStack {
            VStack {
                QRScannerView(scannedCode: $scannedCode)
                    .frame(height: 400)

                Text("QRコードをタップで読み取ってください")
                    .foregroundColor(.gray)
            }
            // QR が更新されたらパースして遷移用データを格納
            .onChange(of: scannedCode) { _, newValue in
                // newValue が最新の文字列。nil ならまだ読み取れていない
                guard let code = newValue else { return }

                parsedData  = parsePayload(code)                // パース
                alertMessage = "読み取り成功: \(code.prefix(30))..."
                showResultView = true                           // 結果画面へ遷移
            }
            // ナビゲーション遷移
            .navigationDestination(isPresented: $showResultView) {
                ResultView(rows: parsedData)
            }
            // デバッグアラート（不要なら削除）
            .alert("Scan", isPresented: .constant(alertMessage != nil), actions: {
                Button("OK") { alertMessage = nil }
            }, message: {
                Text(alertMessage ?? "")
            })
        }
    }

    /// QR文字列を "&" で分解し、マッピングに沿って (MeasureInfo, 値) の配列で返す
    private func parsePayload(_ payload: String) -> [(MeasureInfo, String)] {
        payload
            .split(separator: "&")
            .compactMap { pair -> (MeasureInfo, String)? in
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard parts.count == 2,
                      let keyEnum = MeasureKey(rawValue: parts[0]),
                      let info = measureMap[keyEnum] else { return nil }
                return (info, parts[1])
            }
            // 表示順を揃えたいならここで sort してもOK
    }
}
