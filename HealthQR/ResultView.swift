import SwiftUI

struct ResultView: View {
    let rows: [(MeasureInfo,String)]
    let parsedDict: [String:String]

    @Environment(\.dismiss) private var dismiss
    @State private var toast = false

    var body: some View {
        VStack {
            List {
                ForEach(Array(rows.enumerated()), id:\.0) { _, row in
                    HStack {
                        Text(row.0.label)
                        Spacer()
                        Text("\(row.1) \(row.0.unit)").bold()
                    }
                }
            }

            HStack {
                Button("もう一度スキャン") { dismiss() }
                    .buttonStyle(.bordered)

                Spacer()

                Button("連携する") {
                    Task {
                        try? await HealthKitManager.shared.save(dict: parsedDict)
                        toast = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
        }
        .navigationTitle("測定結果")
        .overlay(alignment: .top) {
            if toast {
                Text("HealthKit に保存しました 🎉")
                    .padding(10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline:.now()+1.5){ toast = false }
                    }
                    .transition(.move(edge:.top).combined(with:.opacity))
            }
        }
        .animation(.easeInOut, value: toast)
    }
}
