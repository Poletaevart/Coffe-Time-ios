import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: DrinkStore
    @State private var selectedMonth: Date = Date()
    @State private var showAllTime: Bool = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showYearOnly: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text(showAllTime ? "За всё время" : (showYearOnly ? "\(selectedYear) год" : AppFormatting.monthTitle(for: selectedMonth)))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    HStack(spacing: 8) {
                        Menu {
                            Section("Выбрать месяц") {
                                ForEach(last12Months, id: \.self) { month in
                                    Button {
                                        selectedMonth = month
                                        showAllTime = false
                                        showYearOnly = false
                                    } label: {
                                        Label {
                                            Text(AppFormatting.monthTitle(for: month))
                                        } icon: {
                                            if Calendar.current.isDate(month, equalTo: selectedMonth, toGranularity: .month) && !showYearOnly {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }

                            Section("Выбрать год") {
                                ForEach(availableYears, id: \.self) { year in
                                    Button {
                                        selectedYear = year
                                        showYearOnly = true
                                        showAllTime = false
                                    } label: {
                                        Label {
                                            Text("\(String(format: "%d", year)) год")
                                        } icon: {
                                            if selectedYear == year && showYearOnly {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Выбрать", systemImage: "calendar")
                        }

                        Button {
                            if showAllTime {
                                showAllTime = false
                                showYearOnly = false
                            } else {
                                showAllTime.toggle()
                            }
                        } label: {
                            Text(showAllTime ? "Месяц" : "За всё время")
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
                    } else if showYearOnly {
                        StatTile(title: "Чашек", value: "\(cupsCount(forYear: selectedYear))")
                        StatTile(title: "мл", value: "\(totalMilliliters(forYear: selectedYear))")
                        StatTile(title: "₽", value: String(format: "%.0f", totalPriceRub(forYear: selectedYear)))
                    } else {
                        StatTile(title: "Чашек", value: "\(store.cupsCount(for: selectedMonth))")
                        StatTile(title: "мл", value: "\(store.totalMilliliters(for: selectedMonth))")
                        StatTile(title: "₽", value: String(format: "%.0f", store.totalPriceRub(for: selectedMonth)))
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                // List
                if (showAllTime ? store.drinks.isEmpty : (showYearOnly ? drinks(forYear: selectedYear).isEmpty : store.drinks(for: selectedMonth).isEmpty)) {
                    HStack(spacing: 10) {
                        Image(systemName: "tray")
                            .foregroundStyle(.secondary)
                        Text(showAllTime ? "Пока пусто за всё время" : (showYearOnly ? "Пока пусто за этот год" : "Пока пусто за этот месяц"))
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(showAllTime ? store.drinks : (showYearOnly ? drinks(forYear: selectedYear) : store.drinks(for: selectedMonth))) { drink in
                                HomeView.DrinkRow(drink: drink, onEdit: { item in
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
            NavigationStack {
                Form {
                    DatePicker("Дата", selection: $editDate, displayedComponents: [.date, .hourAndMinute])

                    Picker("Тип", selection: $editSelectedType) {
                        ForEach(CoffeeType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    if editSelectedType == .other {
                        TextField("Название напитка", text: $editOtherName)
                    }

                    TextField("Миллилитры", text: $editMilliliters)
                        .keyboardType(.numberPad)
                    TextField("Цена (₽)", text: $editPriceRub)
                        .keyboardType(.decimalPad)
                    TextField("Где пил", text: $editPlace)
                }
                .navigationTitle("Редактировать напиток")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { clearEdit() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            let ml = Int(editMilliliters.filter { $0.isNumber }) ?? 0
                            let price = Double(editPriceRub.replacingOccurrences(of: ",", with: ".")) ?? 0
                            store.updateDrink(
                                editing,
                                date: editDate,
                                milliliters: ml,
                                priceRub: price,
                                place: editPlace,
                                type: editSelectedType,
                                customTypeName: editSelectedType == .other ? editOtherName : nil
                            )
                            clearEdit()
                        }
                        .disabled(!isEditValid)
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            store.deleteDrink(editing)
                            clearEdit()
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
    }

    private var last12Months: [Date] {
        let calendar = Calendar.current
        return (0..<12).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: beginningOfMonth(for: Date()))
        }
    }

    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0..<5).map { currentYear - $0 }
    }

    private func drinks(forYear year: Int) -> [Drink] {
        store.drinks.filter { Calendar.current.component(.year, from: $0.date) == year }
    }

    private func totalMilliliters(forYear year: Int) -> Int {
        drinks(forYear: year).reduce(0) { $0 + $1.milliliters }
    }

    private func totalPriceRub(forYear year: Int) -> Double {
        drinks(forYear: year).reduce(0) { $0 + $1.priceRub }
    }

    private func cupsCount(forYear year: Int) -> Int {
        drinks(forYear: year).count
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
    @State private var editSelectedType: CoffeeType = .espresso
    @State private var editOtherName: String = ""

    private func prefillFrom(_ drink: Drink) {
        editMilliliters = String(drink.milliliters)
        editPriceRub = String(Int(drink.priceRub))
        editPlace = drink.place
        editDate = drink.date
        editSelectedType = drink.type
        editOtherName = (drink.type == .other) ? (drink.customTypeName ?? "") : ""
    }

    private func clearEdit() {
        editMilliliters = ""
        editPriceRub = ""
        editPlace = ""
        editDate = Date()
        editSelectedType = .espresso
        editOtherName = ""
        editingDrink = nil
    }
}

private extension HistoryView {
    var isEditValid: Bool {
        let hasML = Int(editMilliliters) ?? 0 > 0
        let hasType = (editSelectedType != .other) || !editOtherName.trimmingCharacters(in: .whitespaces).isEmpty
        return hasML && hasType
    }
}
