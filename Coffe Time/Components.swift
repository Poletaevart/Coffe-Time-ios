import SwiftUI
import Foundation

enum CoffeeType: String, CaseIterable, Identifiable, Codable {
    case espresso = "Эспрессо"
    case doppio = "Доппио"
    case americano = "Американо"
    case latte = "Латте"
    case cappuccino = "Капучино"
    case flatWhite = "Флэт уайт"
    case mocha = "Мокко"
    case macchiato = "Маккиато"
    case ristretto = "Ристретто"
    case filter = "Фильтр"
    case aeropress = "Аэропресс"
    case v60 = "V60"
    case chemex = "Кемекс"
    case cezve = "Турка"
    case capsule = "Капсульный"
    case coldBrew = "Холодный"
    case matcha = "Матча"
    case other = "Другое"

    var id: String { rawValue }
}

struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct DrinkRow: View {
    let drink: Drink
    var onEdit: ((Drink) -> Void)? = nil
    var onDelete: ((Drink) -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(drink.milliliters) мл • \(AppFormatting.rubles(drink.priceRub))")
                    .font(.subheadline).bold()
                    .foregroundStyle(.primary)
                Text(drink.place)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(AppFormatting.mediumDate(drink.date))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit?(drink)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let onEdit {
                Button {
                    onEdit(drink)
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
                .tint(.indigo)
            }
            if let onDelete {
                Button(role: .destructive) {
                    onDelete(drink)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
    }
}

struct AddDrinkSheet: View {
    @Binding var selectedType: CoffeeType
    @Binding var milliliters: String
    @Binding var priceRub: String
    @Binding var place: String
    @Binding var date: Date
    var onSave: () -> Void
    var onDelete: (() -> Void)? = nil
    var isEditing: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Тип напитка") {
                    Picker("Выберите тип", selection: $selectedType) {
                        ForEach(CoffeeType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                Section("Объем") {
                    TextField("Миллилитры", text: $milliliters)
                        .keyboardType(.numberPad)
                }
                Section("Цена") {
                    TextField("Цена в ₽", text: $priceRub)
                        .keyboardType(.decimalPad)
                }
                Section("Место покупки") {
                    TextField("Где купили", text: $place)
                        .textInputAutocapitalization(.sentences)
                }
                Section("Дата") {
                    DatePicker("Дата", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle(isEditing ? "Редактировать кофе" : "Новый кофе")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
                if let onDelete {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive, action: {
                            onDelete()
                            dismiss()
                        }) {
                            Text("Удалить")
                        }
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(.ultraThinMaterial)
        .scrollDismissesKeyboard(.interactively)
    }

    private var isValid: Bool {
        let hasML = !milliliters.trimmingCharacters(in: .whitespaces).isEmpty
        let hasPrice = !priceRub.trimmingCharacters(in: .whitespaces).isEmpty
        let hasPlace = !place.trimmingCharacters(in: .whitespaces).isEmpty
        return hasML || hasPrice || hasPlace
    }
}
