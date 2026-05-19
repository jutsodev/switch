import Foundation
import SwiftUI
import Combine

final class FileRemovalService: ObservableObject {
    @Published var animatingFile: FileItem?
    @Published var animationPhase: AnimationPhase = .idle

    enum AnimationPhase {
        case idle
        case enrichment
        case focus
        case liquidation
        case completed
    }

    private var animationTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var currentProgress: Double = 0.0

    init() {}

    func animateFileRemoval(_ file: FileItem, completion: @escaping (FileItem) -> Void) {
        animatingFile = file
        currentProgress = 0.0
        startAnimationSequence(completion: completion)
    }

    private func startAnimationSequence(completion: @escaping (FileItem) -> Void) {
        let totalDuration: Double = 0.8
        let steps: [AnimationPhase] = [.enrichment, .focus, .liquidation]
        let stepDuration = totalDuration / Double(steps.count)
        var currentStep = 0

        animationPhase = .enrichment

        Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            currentStep += 1
            if currentStep >= steps.count {
                timer.invalidate()
                self?.animationPhase = .completed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    completion(self?.animatingFile ?? FileItem(name: ""))
                    self?.reset()
                }
            } else {
                self?.animationPhase = steps[currentStep]
            }
        }
    }

    func reset() {
        animatingFile = nil
        animationPhase = .idle
        currentProgress = 0.0
    }

    var toastBackgroundColor: Color {
        switch animationPhase {
        case .idle, .completed:
            return .clear
        case .enrichment:
            return Color(red: 0.2, green: 0.2, blue: 0.25).opacity(0.9)
        case .focus:
            return Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.95)
        case .liquidation:
            return Color(red: 0.1, green: 0.08, blue: 0.12).opacity(0.3)
        }
    }

    var toastScale: CGFloat {
        switch animationPhase {
        case .idle, .completed:
            return 0.0
        case .enrichment:
            return 1.3
        case .focus:
            return 1.5
        case .liquidation:
            return 0.4
        }
    }

    var blurRadius: CGFloat {
        switch animationPhase {
        case .idle, .enrichment:
            return 0.0
        case .focus:
            return 2.0
        case .liquidation:
            return 15.0
        case .completed:
            return 30.0
        }
    }

    var eyeOpacity: Double {
        switch animationPhase {
        case .idle, .enrichment, .liquidation, .completed:
            return 0.0
        case .focus:
            return 0.7
        }
    }

    var particleCount: Int {
        switch animationPhase {
        case .liquidation:
            return 12
        default:
            return 0
        }
    }
}