import Foundation

enum MeasureKey: String, CaseIterable {
    // 全身
    case WT, BI, BP, WX, WV, BL, VF
    // 部位別体脂肪率
    case CP, DP, EP, FP
    // 部位別筋量
    case WK, WL, WM, WN
    // 身長・測定日
    case HI, SY, SM, SD
}

struct MeasureInfo { let label: String; let unit: String }

let measureMap: [MeasureKey: MeasureInfo] = [
    .WT: .init(label: "体重", unit: "kg"),
    .BI: .init(label: "BMI", unit: ""),
    .BP: .init(label: "体脂肪率", unit: "%"),
    .WX: .init(label: "骨格筋量", unit: "kg"),
    .WV: .init(label: "体水分量", unit: "kg"),
    .BL: .init(label: "基礎代謝量", unit: "kcal"),
    .VF: .init(label: "内臓脂肪指数", unit: ""),
    .CP: .init(label: "右腕脂肪率", unit: "%"),
    .DP: .init(label: "左腕脂肪率", unit: "%"),
    .EP: .init(label: "右脚脂肪率", unit: "%"),
    .FP: .init(label: "左脚脂肪率", unit: "%"),
    .WK: .init(label: "右腕筋量", unit: "kg"),
    .WL: .init(label: "左腕筋量", unit: "kg"),
    .WM: .init(label: "右脚筋量", unit: "kg"),
    .WN: .init(label: "左脚筋量", unit: "kg"),
    .HI: .init(label: "身長", unit: "cm"),
    .SY: .init(label: "測定年", unit: ""),
    .SM: .init(label: "測定月", unit: ""),
    .SD: .init(label: "測定日", unit: "")
]
