import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let store = HKHealthStore()
    private init() {}

    func requestAuth() {
        let types: Set = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!
        ]
        store.requestAuthorization(toShare: types, read: []) { _, _ in }
    }

    /// dict は QR からパースした [Key:Value] そのまま
    func save(dict: [String:String]) async throws {
        // 1️⃣ 測定日時を組み立てる（失敗したら now）
        let measurementDate: Date = {
            guard
                let yStr = dict["SY"], let mStr = dict["SM"], let dStr = dict["SD"],
                let y = Int(yStr), let m = Int(mStr), let d = Int(dStr)
            else { return Date() }

            var comps = DateComponents()
            comps.calendar = Calendar.current
            comps.year  = y
            comps.month = m
            comps.day   = d
            comps.hour  = 12   // 時刻がないので正午で固定（任意）
            return comps.date ?? Date()
        }()

        // 2️⃣ 保存タスクをグループで並列に
        try await withThrowingTaskGroup(of: Void.self) { group in
            if let v = Double(dict["WT"] ?? "") {
                let qty = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: v)
                let sample = HKQuantitySample(
                    type: .quantityType(forIdentifier: .bodyMass)!,
                    quantity: qty, start: measurementDate, end: measurementDate)
                group.addTask { try await self.store.save(sample) }
            }

            if let v = Double(dict["BP"] ?? "") {
                let qty = HKQuantity(unit: .percent(), doubleValue: v / 100.0)
                let sample = HKQuantitySample(
                    type: .quantityType(forIdentifier: .bodyFatPercentage)!,
                    quantity: qty, start: measurementDate, end: measurementDate)
                group.addTask { try await self.store.save(sample) }
            }

            try await group.waitForAll()
        }
    }
}
