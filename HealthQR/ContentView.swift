import SwiftUI

struct ContentView: View {
    @State private var scannedCode: String?

    var body: some View {
        VStack {
            QRScannerView(scannedCode: $scannedCode)
                .frame(height: 400)

            if let code = scannedCode {
                Text("Scanned:\n\(code)")
                    .padding()
                    .foregroundColor(.green)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            } else {
                Text("QRコードを読み取ってください")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
