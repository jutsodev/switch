import SwiftUI

class GestureHandlerService: NSObject, ObservableObject {
    @Published var lastGestureRecognized: GestureType? = nil
    @Published var gestureVelocity: CGFloat = 0
    @Published var gestureLocation: CGPoint = .zero
    
    enum GestureType {
        case tap
        case doubleTap
        case longPress
        case swipeUp
        case swipeDown
        case swipeLeft
        case swipeRight
        case pinch
        case rotation
        case drag
    }
}

struct ComplexListView: View {
    @State private var items: [ListItem] = (0..<50).map { index in
        ListItem(
            id: "\(index)",
            title: "Item \(index)",
            description: "Description for item \(index)",
            icon: ["star.fill", "heart.fill", "bolt.fill", "flame.fill"][index % 4]
        )
    }
    
    @State private var selectedItem: String? = nil
    @State private var searchText = ""
    
    var filteredItems: [ListItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { 
            $0.title.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(12)
                
                List {
                    ForEach(filteredItems) { item in
                        ListItemRow(
                            item: item,
                            isSelected: selectedItem == item.id,
                            onSelect: {
                                withAnimation {
                                    selectedItem = item.id
                                }
                            }
                        )
                        .listRowBackground(Color(white: 0.09))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct ListItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

struct ListItemRow: View {
    let item: ListItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 40, height: 40)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            } else {
                Circle()
                    .stroke(Color(white: 0.2), lineWidth: 1.5)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(12)
        .background(Color(white: isSelected ? 0.12 : 0.09))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Поиск...")
                        .foregroundColor(.white.opacity(0.5))
                }
                .foregroundColor(.white)
                .font(.system(size: 16))
                .focused($isFocused)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 12)
        .background(Color(white: 0.15))
        .cornerRadius(8)
    }
}

class ValidationService: NSObject, ObservableObject {
    func validateUsername(_ username: String) -> ValidationResult {
        if username.isEmpty {
            return ValidationResult(isValid: false, message: "Username не может быть пусто")
        }
        if username.count < 3 {
            return ValidationResult(isValid: false, message: "Username должен содержать минимум 3 символа")
        }
        if username.count > 20 {
            return ValidationResult(isValid: false, message: "Username не может быть более 20 символов")
        }
        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        if !username.unicodeScalars.allSatisfy({ validCharacters.contains($0) }) {
            return ValidationResult(isValid: false, message: "Username может содержать только буквы, цифры, _ и -")
        }
        return ValidationResult(isValid: true, message: "OK")
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return ValidationResult(isValid: false, message: "Пароль не может быть пусто")
        }
        if password.count < 8 {
            return ValidationResult(isValid: false, message: "Пароль должен содержать минимум 8 символов")
        }
        if !password.contains(where: { $0.isUppercase }) {
            return ValidationResult(isValid: false, message: "Пароль должен содержать заглавные буквы")
        }
        if !password.contains(where: { $0.isLowercase }) {
            return ValidationResult(isValid: false, message: "Пароль должен содержать строчные буквы")
        }
        if !password.contains(where: { $0.isNumber }) {
            return ValidationResult(isValid: false, message: "Пароль должен содержать цифры")
        }
        return ValidationResult(isValid: true, message: "OK")
    }
}

struct ValidationResult {
    let isValid: Bool
    let message: String
}

struct FormValidationView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @StateObject private var validator = ValidationService()
    
    var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Регистрация")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    ValidatedTextField(
                        label: "Username",
                        text: $username,
                        validator: { validator.validateUsername($0) }
                    )
                    
                    ValidatedTextField(
                        label: "Пароль",
                        text: $password,
                        isSecure: true,
                        validator: { validator.validatePassword($0) }
                    )
                    
                    ValidatedTextField(
                        label: "Подтвердить пароль",
                        text: $confirmPassword,
                        isSecure: true,
                        validator: { _ in
                            if confirmPassword == password {
                                return ValidationResult(isValid: true, message: "OK")
                            }
                            return ValidationResult(isValid: false, message: "Пароли не совпадают")
                        }
                    )
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("Зарегистрироваться")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            isFormValid ? 
                            Color(red: 0.0, green: 0.4, blue: 0.8) : 
                            Color(white: 0.2)
                        )
                        .cornerRadius(8)
                }
                .disabled(!isFormValid)
            }
            .padding(16)
        }
    }
}

struct ValidatedTextField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false
    let validator: (String) -> ValidationResult
    
    @State private var validationResult: ValidationResult?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .foregroundColor(.white)
            .frame(height: 40)
            .padding(.horizontal, 12)
            .background(Color(white: 0.15))
            .cornerRadius(8)
            .onChange(of: text) { newValue in
                validationResult = validator(newValue)
            }
            
            if let result = validationResult {
                HStack(spacing: 4) {
                    Image(systemName: result.isValid ? "checkmark.circle" : "exclamationmark.circle")
                        .font(.system(size: 12))
                        .foregroundColor(result.isValid ? .green : .red)
                    
                    Text(result.message)
                        .font(.system(size: 12))
                        .foregroundColor(result.isValid ? .green : .red)
                }
            }
        }
    }
}

struct ActivityIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Загрузка...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    CircularProgressView(progress: 0.6)
                    
                    DottedProgressView(
                        animating: $isAnimating,
                        color: Color(red: 0.0, green: 0.4, blue: 0.8)
                    )
                    
                    BarProgressView(progress: 0.75)
                    
                    PulsingCircleView()
                }
                
                Spacer()
            }
            .padding(16)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(white: 0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.0, green: 0.4, blue: 0.8),
                            Color(red: 0.8, green: 0.2, blue: 0.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 100)
    }
}

struct DottedProgressView: View {
    @Binding var animating: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .opacity(animating && index % 2 == 0 ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .delay(Double(index) * 0.1)
                            .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
    }
}

struct BarProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Прогресс")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text(String(format: "%.0f%%", progress * 100))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(white: 0.2))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.0, green: 0.4, blue: 0.8),
                                    Color(red: 0.2, green: 0.8, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}

struct PulsingCircleView: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.0, green: 0.4, blue: 0.8))
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0 : 1)
                .animation(
                    .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isPulsing
                )
            
            Circle()
                .fill(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 16, height: 16)
        }
        .frame(width: 60, height: 60)
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    ComplexListView()
}
