import SwiftUI
import AVFoundation

class AudioRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var recordedAudioURL: URL? = nil
    
    private var audioRecorder: AVAudioRecorder? = nil
    private var audioSession: AVAudioSession? = nil
    private var displayLink: CADisplayLink? = nil
    private var recordingStartTime: Date? = nil
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.audioSession = audioSession
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        let audioURL = getAudioFileURL()
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            
            if audioRecorder?.record() ?? false {
                DispatchQueue.main.async {
                    self.isRecording = true
                    self.recordingStartTime = Date()
                    self.recordingDuration = 0
                    self.startMetering()
                }
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        displayLink?.invalidate()
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.recordedAudioURL = self.getAudioFileURL()
        }
    }
    
    private func startMetering() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateMetering)
        )
        displayLink?.preferredFramesPerSecond = 30
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateMetering() {
        audioRecorder?.updateMeters()
        
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let normalizedPower = max(0, min(1, (averagePower + 160) / 160))
        
        DispatchQueue.main.async {
            self.audioLevel = normalizedPower
            if let startTime = self.recordingStartTime {
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func getAudioFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        return documentsDirectory.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
    }
}

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var recognizedText = ""
    @Published var isListening = false
    @Published var confidence: Float = 0
    
    func startListening() {
        DispatchQueue.main.async {
            self.isListening = true
        }
    }
    
    func stopListening() {
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
}

class TextToSpeechService: NSObject, ObservableObject {
    @Published var isSpeaking = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String, rate: Float = 0.5) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = rate
        
        speechSynthesizer.speak(utterance)
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func stop() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

class ImageProcessingService: NSObject, ObservableObject {
    @Published var processedImage: UIImage? = nil
    @Published var isProcessing = false
    
    func processImage(_ image: UIImage, filter: ImageFilter) {
        DispatchQueue.global(qos: .userInitiated).async {
            var processedImage = image
            
            switch filter {
            case .blur:
                processedImage = self.applyBlurFilter(to: image)
            case .grayscale:
                processedImage = self.applyGrayscaleFilter(to: image)
            case .sepia:
                processedImage = self.applySepiaFilter(to: image)
            case .highContrast:
                processedImage = self.applyHighContrastFilter(to: image)
            }
            
            DispatchQueue.main.async {
                self.processedImage = processedImage
                self.isProcessing = false
            }
        }
    }
    
    private func applyBlurFilter(to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: 5.0), forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        
        let context = CIContext()
        guard let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImageResult)
    }
    
    private func applyGrayscaleFilter(to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: 0.0), forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        
        let context = CIContext()
        guard let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImageResult)
    }
    
    private func applySepiaFilter(to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: 0.8), forKey: kCIInputIntensityKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        
        let context = CIContext()
        guard let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImageResult)
    }
    
    private func applyHighContrastFilter(to image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(NSNumber(value: 1.5), forKey: kCIInputContrastKey)
        
        guard let outputImage = filter?.outputImage else { return image }
        
        let context = CIContext()
        guard let cgImageResult = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }
        
        return UIImage(cgImage: cgImageResult)
    }
}

enum ImageFilter: String, CaseIterable {
    case blur = "Размытие"
    case grayscale = "Черно-белое"
    case sepia = "Сепия"
    case highContrast = "Высокий контраст"
}

class NetworkService: NSObject, ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    override init() {
        super.init()
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        
    }
}

enum ConnectionType: String {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case none = "None"
}

class CacheService: NSObject, ObservableObject {
    static let shared = CacheService()
    
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    private var dataCache: NSCache<NSString, NSData> = NSCache()
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func cachedImage(forKey key: String) -> UIImage? {
        imageCache.object(forKey: key as NSString)
    }
    
    func cacheData(_ data: Data, forKey key: String) {
        dataCache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func cachedData(forKey key: String) -> Data? {
        dataCache.object(forKey: key as NSString) as Data?
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
        dataCache.removeAllObjects()
    }
}
