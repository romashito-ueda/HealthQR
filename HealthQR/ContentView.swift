import SwiftUICore
struct ContentView: View {
    @State private var scannedCode: String?

    var body: some View {
        VStack {
            QRScannerView(scannedCode: $scannedCode)
                .frame(height: 400)

            if let code = scannedCode {
                Text("読み取った内容: \(code)")
                    .padding()
                    .foregroundColor(.green)
            } else {
                Text("QRコードを読み取ってください")
                    .padding()
                    .foregroundColor(.gray)
            }
        }
    }
}
