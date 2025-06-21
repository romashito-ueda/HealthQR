import SwiftUI

struct ResultView: View {
    let rows: [(MeasureInfo, String)]

    // 親画面からバインディングで受け取る「再スキャン要求」
    @Environment(\.dismiss) private var dismiss   // ← NavigationStack を閉じるだけならこれで十分

    var body: some View {
        VStack {
            // ---- 既存の一覧 ----
            List {
                ForEach(Array(rows.enumerated()), id: \.0) { _, row in
                    HStack {
                        Text(row.0.label)
                        Spacer()
                        Text("\(row.1) \(row.0.unit)")
                            .bold()
                    }
                }
            }

            // ---- 追加した再スキャンボタン ----
            Button("もう一度スキャン") {
                dismiss()   // NavigationStack の前の画面に戻る
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 16)
        }
        .navigationTitle("測定結果")
    }
}
