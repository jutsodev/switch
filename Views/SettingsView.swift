import SwiftUI

struct SettingsView: View {
    @StateObject private var userPreferences = UserPreferencesService.shared
    @StateObject private var analyticsService = AnalyticsService.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Настройки")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        SettingsSectionView(title: "Внешний вид") {
                            SettingsToggleView(
                                icon: "moon.stars",
                                title: "Темный режим",
                                isOn: $userPreferences.darkModeEnabled
                            )
                            
                            SettingsPickerView(
                                icon: "textformat.size",
                                title: "Размер текста",
                                items: TextSize.allCases,
                                selection: $userPreferences.textSize,
                                displayValue: { $0.rawValue.capitalized }
                            )
                        }
                        
                        SettingsSectionView(title: "Звук и вибрация") {
                            SettingsToggleView(
                                icon: "speaker.wave.2",
                                title: "Звук",
                                isOn: $userPreferences.soundEnabled
                            )
                            
                            SettingsToggleView(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Вибрация",
                                isOn: $userPreferences.hapticFeedbackEnabled
                            )
                        }
                        
                        SettingsSectionView(title: "Язык") {
                            SettingsPickerView(
                                icon: "globe",
                                title: "Язык приложения",
                                items: ["ru", "en"],
                                selection: $userPreferences.selectedLanguage,
                                displayValue: { $0 == "ru" ? "Русский" : "English" }
                            )
                        }
                        
                        SettingsSectionView(title: "О приложении") {
                            SettingsInfoRowView(
                                icon: "app",
                                title: "Версия",
                                value: "1.0.0"
                            )
                            
                            SettingsInfoRowView(
                                icon: "doc.text",
                                title: "Build",
                                value: "2024.05.19"
                            )
                        }
                        
                        VStack(spacing: 8) {
                            Button(action: {
                                analyticsService.trackUserAction("export_logs", on: "settings")
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                                    
                                    Text("Экспортировать логи")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(white: 0.12))
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                NotificationService.shared.showWarning("Кэш очищен")
                                CacheService.shared.clearCache()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                                    
                                    Text("Очистить кэш")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(white: 0.12))
                                .cornerRadius(8)
                            }
                        }
                        .padding(12)
                    }
                    .padding(12)
                }
            }
        }
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 12)
                .padding(.top, 8)
            
            content()
                .background(Color(white: 0.09))
                .cornerRadius(12)
        }
    }
}

struct SettingsToggleView: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 0.0, green: 0.4, blue: 0.8))
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

struct SettingsPickerView<T: CaseIterable & Equatable>: View {
    let icon: String
    let title: String
    let items: [T]
    @Binding var selection: T
    let displayValue: (T) -> String
    
    @State private var showPicker = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(displayValue(selection))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showPicker.toggle()
        }
        .sheet(isPresented: $showPicker) {
            PickerSheetView(
                items: items,
                selection: $selection,
                displayValue: displayValue
            )
        }
    }
}

struct PickerSheetView<T: CaseIterable & Equatable>: View {
    let items: [T]
    @Binding var selection: T
    let displayValue: (T) -> String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Выбрать")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                
                Picker("", selection: $selection) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Text(displayValue(items[index]))
                            .tag(items[index])
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxHeight: 300)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Готово")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(red: 0.0, green: 0.4, blue: 0.8))
                        .cornerRadius(8)
                }
                .padding(16)
            }
        }
    }
}

struct SettingsInfoRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}
