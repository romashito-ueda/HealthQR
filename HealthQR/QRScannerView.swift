import SwiftUI
import VisionKit

struct QRScannerView: UIViewControllerRepresentable {
    // スキャン結果を親Viewに渡すためのバインディング
    @Binding var scannedCode: String?

    // UIViewController（ここではDataScannerViewController）を生成
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])], // QRコードのみ
            qualityLevel: .accurate, // 精度を高める
            isHighlightingEnabled: true // QRコードの検出範囲をハイライト
        )
        scanner.delegate = context.coordinator // デリゲートにCoordinatorを設定
        try? scanner.startScanning() // スキャンを開始
        return scanner
    }

    // Viewの更新時に特別な処理はなし
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    // デリゲートのハンドラを生成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // スキャン結果を処理するクラス
        class Coordinator: NSObject, DataScannerViewControllerDelegate {
            let parent: QRScannerView
            var hasScanned = false // スキャン済みかどうか（複数回呼ばれないようにする）

            init(_ parent: QRScannerView) {
                self.parent = parent
            }

            // QRコードがタップされたときに呼ばれる
            func dataScanner(_ scanner: DataScannerViewController, didTapOn item: RecognizedItem) {
                // すでに読み取っていたら処理しない（1回だけ反応させる）
                guard !hasScanned else { return }

                if case let .barcode(code) = item,
                   let payload = code.payloadStringValue {
                    print("✅ QRコード検出: \(payload)") // コンソールに出力
                    parent.scannedCode = payload // バインディング経由で結果を渡す
                    hasScanned = true

                    // スキャンを止める（必要があれば）
                    scanner.stopScanning()
                }
            }
        }
}
