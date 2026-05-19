import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Tiny wrapper that lets ViewModels and SwiftUI views fire haptics
/// without sprinkling UIKit imports everywhere.
enum Haptics {

    static func tap() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    static func medium() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    static func success() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    static func error() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}
