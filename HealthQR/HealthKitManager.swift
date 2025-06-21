import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private init() {}

    /// 追加タイプをすべて権限リクエスト
    func requestAuth() {
        let identifiers: [HKQuantityTypeIdentifier] = [
            .bodyMass, .bodyFatPercentage, .bodyMassIndex,
            .height, .leanBodyMass, .basalEnergyBurned
        ]
        let types = Set(identifiers.compactMap { HKObjectType.quantityType(forIdentifier: $0) })
        store.requestAuthorization(toShare: types, read: []) { _, _ in }
    }

    /// QR辞書を全項目保存 (存在する値だけ)
    func save(dict: [String:String]) async throws {
        let date = makeDate(dict)   // 測定 SY/SM/SD → Date
        try await withThrowingTaskGroup(of: Void.self) { g in

            // 体重 WT
            if let v = double(dict["WT"]) {
                g.addTask { try await self.saveQuantity(.bodyMass, v, .gramUnit(with: .kilo), date) }
            }
            // 体脂肪率 BP
            if let v = double(dict["BP"]) {
                g.addTask { try await self.saveQuantity(.bodyFatPercentage, v/100, .percent(), date) }
            }
            // BMI
            if let v = double(dict["BI"]) {
                g.addTask { try await self.saveQuantity(.bodyMassIndex, v, .count(), date) }
            }
            // 身長 HI
            if let v = double(dict["HI"]) {
                g.addTask { try await self.saveQuantity(.height, v/100, .meter(), date) }
            }
            // 骨格筋量 WX → LeanBodyMass
            if let v = double(dict["WX"]) {
                g.addTask { try await self.saveQuantity(.leanBodyMass, v, .gramUnit(with: .kilo), date) }
            }
            // 体水分量 WV

            // 基礎代謝量 BL (kcal)
            if let v = double(dict["BL"]) {
                g.addTask { try await self.saveQuantity(.basalEnergyBurned, v, .kilocalorie(), date) }
            }
            try await g.waitForAll()
        }
    }

    // ---------- private helpers ----------
    private func saveQuantity(_ id: HKQuantityTypeIdentifier,
                              _ value: Double,
                              _ unit: HKUnit,
                              _ date: Date) async throws {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else { return }
        let qty = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: type, quantity: qty, start: date, end: date)
        try await store.save(sample)
    }

    private func double(_ str: String?) -> Double? { str.flatMap(Double.init) }

    private func makeDate(_ dict:[String:String]) -> Date {
        guard
            let y = Int(dict["SY"] ?? ""),
            let m = Int(dict["SM"] ?? ""),
            let d = Int(dict["SD"] ?? "")
        else { return Date() }
        var c = DateComponents(); c.calendar = .current
        c.year = y; c.month = m; c.day = d; c.hour = 12
        return c.date ?? Date()
    }
}
