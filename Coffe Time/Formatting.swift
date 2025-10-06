//
//  Formatting.swift
//  Coffe Time
//
//  Shared formatters and helpers
//

import Foundation

enum AppFormatting {
    static let ruLocale = Locale(identifier: "ru_RU")

    static func monthTitle(for date: Date) -> String {
        let df = DateFormatter()
        df.locale = ruLocale
        df.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        let s = df.string(from: date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    static func mediumDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = ruLocale
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    static func rubles(_ amount: Double, noFractions: Bool = true) -> String {
        let nf = NumberFormatter()
        nf.locale = ruLocale
        nf.numberStyle = .currency
        nf.currencyCode = "RUB"
        nf.maximumFractionDigits = noFractions ? 0 : 2
        return nf.string(from: NSNumber(value: amount)) ?? "₽\(Int(amount))"
    }
}



