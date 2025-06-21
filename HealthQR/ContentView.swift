import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var scannedCode: String?
    @State private var parsedRows: [(MeasureInfo,String)] = []
    @State private var parsedDict: [String:String] = [:]
    @State private var showResult = false
    @State private var toast: String?

    var body: some View {
        NavigationStack {
            VStack {
                QRScannerView(scannedCode: $scannedCode)
                    .frame(height: 400)

                Text("QRコードをタップで読み取ってください")
                    .foregroundColor(.gray)
            }
            .onChange(of: scannedCode) { _, newVal in
                guard let code = newVal else { return }
                parsedDict  = parseDict(code)
                parsedRows  = convertToRows(parsedDict)
                showResult  = true
            }
            .navigationDestination(isPresented: $showResult) {
                ResultView(rows: parsedRows, parsedDict: parsedDict)
            }
            .overlay(alignment: .top) {
                if let t = toast {
                    Text(t)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now()+1.5) { toast = nil }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .task { HealthKitManager.shared.requestAuth() }
    }

    // ---------- Parser ----------
    private func parseDict(_ text: String) -> [String:String] {
        Dictionary(uniqueKeysWithValues:
            text.split(separator:"&").compactMap {
                let p = $0.split(separator:"=",maxSplits:1).map(String.init)
                return p.count == 2 ? (p[0], p[1]) : nil
            })
    }
    private func convertToRows(_ dict: [String:String]) -> [(MeasureInfo,String)] {
        dict.compactMap { k,v in
            guard let m = MeasureKey(rawValue: k), let info = measureMap[m] else { return nil }
            return (info, v)
        }
    }
}
