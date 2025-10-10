//
//  HistoryItemView.swift
//  Coffe Time
//
//  Created by Artem Poletaev on 09.10.2025.
//

import SwiftUI

struct HistoryItemView: View {
    let title: String
    let subtitle: String
    let amount: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(amount)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    HistoryItemView(
        title: "Бразилия феникс",
        subtitle: "250 г",
        amount: "580 ₽",
        date: "8 октября 2025 г."
    )
}
