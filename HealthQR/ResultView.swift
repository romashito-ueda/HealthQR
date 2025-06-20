//
//  ResultView.swift
//  HealthQR
//
//  Created by r0n on 2025/06/21.
//


import SwiftUI

struct ResultView: View {
    let rows: [(MeasureInfo, String)]

    var body: some View {
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
        .navigationTitle("測定結果")
    }
}
