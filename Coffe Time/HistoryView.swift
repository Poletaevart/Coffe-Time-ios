import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: DrinkStore
    @State private var selectedMonth: Date = Date()
    @State private var showAllTime: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text(showAllTime ? "За всё время" : AppFormatting.monthTitle(for: selectedMonth))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    HStack(spacing: 8) {
                        Menu {
                            ForEach(last12Months, id: \.self) { month in
                                Button(AppFormatting.monthTitle(for: month)) {
                                    selectedMonth = month
                                    showAllTime = false
                                }
                            }
                        } label: {
                            Label("Выбрать месяц", systemImage: "calendar")
                        }
                        Button(showAllTime ? "Месяц" : "За всё время") {
                            showAllTime.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                // Stats
                HStack(spacing: 12) {
                    if showAllTime {
                        StatTile(title: "Чашек", value: "\(store.allTimeCupsCount)")
                        StatTile(title: "мл", value: "\(store.allTimeTotalMilliliters)")
                        StatTile(title: "₽", value: String(format: "%.0f", store.allTimeTotalPriceRub))
                    } else {
                        StatTile(title: "Чашек", value: "\(store.cupsCount(for: selectedMonth))")
                        StatTile(title: "мл", value: "\(store.totalMilliliters(for: selectedMonth))")
                        StatTile(title: "₽", value: String(format: "%.0f", store.totalPriceRub(for: selectedMonth)))
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                // List
                if (showAllTime ? store.drinks.isEmpty : store.drinks(for: selectedMonth).isEmpty) {
                    HStack(spacing: 10) {
                        Image(systemName: "tray")
                            .foregroundStyle(.secondary)
                        Text(showAllTime ? "Пока пусто за всё время" : "Пока пусто за этот месяц")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(showAllTime ? store.drinks : store.drinks(for: selectedMonth)) { drink in
                                DrinkRow(drink: drink, onEdit: { item in
                                    editingDrink = item
                                    // route edit via sheet below
                                    prefillFrom(item)
                                }, onDelete: { item in
                                    store.deleteDrink(item)
                                })
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .sheet(item: $editingDrink) { editing in
            AddDrinkSheet(milliliters: $editMilliliters, priceRub: $editPriceRub, place: $editPlace, date: $editDate, onSave: {
                let ml = Int(editMilliliters.filter { $0.isNumber }) ?? 0
                let price = Double(editPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                store.updateDrink(editing, date: editDate, milliliters: ml, priceRub: price, place: editPlace)
                clearEdit()
            }, onDelete: {
                store.deleteDrink(editing)
                clearEdit()
            }, isEditing: true)
        }
    }

    private var last12Months: [Date] {
        let calendar = Calendar.current
        return (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: beginningOfMonth(for: Date()))
        }
    }

    private func beginningOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    // Edit state
    @State private var editingDrink: Drink? = nil
    @State private var editMilliliters: String = ""
    @State private var editPriceRub: String = ""
    @State private var editPlace: String = ""
    @State private var editDate: Date = Date()

    private func prefillFrom(_ drink: Drink) {
        editMilliliters = String(drink.milliliters)
        editPriceRub = String(Int(drink.priceRub))
        editPlace = drink.place
        editDate = drink.date
    }

    private func clearEdit() {
        editMilliliters = ""
        editPriceRub = ""
        editPlace = ""
        editDate = Date()
        editingDrink = nil
    }
}


