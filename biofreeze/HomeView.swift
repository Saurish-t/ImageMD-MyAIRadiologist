import SwiftUI
import AVFoundation
import Vision
import UIKit

struct HomeView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("hasSetFontPreferences") private var hasSetFontPreferences: Bool = false
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            Untitled()
                .tabItem {
                    Label("Text to Speech", systemImage: "waveform")
                }
            
            //VisionView()
                .tabItem {
                    Label("Adaptive Reading", systemImage: "eye.fill")
                }
        }
        .accentColor(.white)
    }
}

struct MainView: View {
    @State private var showSettings = false
    @State private var showAdaptiveTutorial = false
    @State private var showTTS_Tutorial = false
    @State private var extractedText: String = "Take a photo to extract text..."
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showImageSelector = false
    @State private var usingCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary


    
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome to imageMD!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    
                
                Text("Upload your image below:")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                ScrollView {
                    Text(extractedText)
                        .font(.custom(selectedFont, size: CGFloat(selectedFontSize)))
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .foregroundStyle(.white)
                        .bold()
                }
                .frame(maxHeight: 400)
                .padding(.top, 30)
                HStack {
                    Button(action: {
                        sourceType = .camera
                        showImagePicker = true }) {
                        Label("Take Photo", systemImage: "camera")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        sourceType = .photoLibrary
                        showImageSelector = true
                    }) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                
                Spacer()
            }
            .padding()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                }
                Spacer()
            }
            .padding()
            
            if showSettings {
                SettingsView(isPresented: $showSettings)
            }
        }
        .sheet(isPresented: $showImageSelector) {
            ImagePicker(image: $selectedImage, sourceType: usingCamera ? .camera : .photoLibrary)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker3(image: $selectedImage, completion: processImage)
        }

    }
    private func processImage(_ image: UIImage?) {
        guard let image = image else { return }
        self.selectedImage = image
        sendImageToServer(image)
    }
    
    func sendImageToServer(_ image: UIImage) {
        guard let url = URL(string: "http://127.0.0.1:5000/predict") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")

        let boundary = UUID().uuidString
        let fullData = createMultipartData(image: image, boundary: boundary)

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = fullData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let extractedText = jsonResponse["text"] as? String {
                DispatchQueue.main.async {
                    self.extractedText = extractedText
                }
            }
        }
        task.resume()
    }
    
    func createMultipartData(image: UIImage, boundary: String) -> Data {
        var body = Data()
        
        let imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
        let filename = "image.jpg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }


    private func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }

    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }

        extractedText = recognizedStrings.joined(separator: " ")
    }
    
}


struct AdaptiveReadingTutorialView: View {
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    
    var body: some View {
        VStack {
            Text("Adaptive Reading Tutorial")
                .font(.custom(selectedFont, size: selectedFontSize + 5))
                .fontWeight(.bold)
                .padding()
            
            Text("First, made a CNN that detects different diseases based on the X-ray input. And then I used pytorch to save that as a .pth file. From that We have a flask server, whenever It recieves a request, it will return information about what the patient has.")
                .font(.custom(selectedFont, size: selectedFontSize))
                .padding()
            
            Spacer()
        }
    }
}

struct TTSTutorialView: View {
    @AppStorage("selectedFont") private var selectedFont: String = "Arial"
    @AppStorage("selectedFontSize") private var selectedFontSize: Double = 20
    
    var body: some View {
        VStack {
            Text("Text-to-Speech Tutorial")
                .font(.custom(selectedFont, size: selectedFontSize + 5))
                .fontWeight(.bold)
                .padding()
            
            Text("HoloRead can read text aloud using advanced text-to-speech technology. Simply input an image, and press the play button to hear it read in a natural voice. You can adjust the speed and voice in settings.")
                .font(.custom(selectedFont, size: selectedFontSize))
                .padding()
            
            Spacer()
        }
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var showAdaptiveTutorial = false
    @State private var showTTS_Tutorial = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                
                Button(action: { showAdaptiveTutorial.toggle() }) {
                    Text("How imageMD Works")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 40)
                .sheet(isPresented: $showAdaptiveTutorial) {
                    AdaptiveReadingTutorialView()
                }
                
                
                
                Button("Reset App", action: resetApp)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 40)
                
                Button("Close") {
                    isPresented = false
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                

            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    func resetApp() {
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        UserDefaults.standard.set(false, forKey: "hasSetFontPreferences")
        UserDefaults.standard.set("Arial", forKey: "selectedFont")
        UserDefaults.standard.set(20.0, forKey: "selectedFontSize")
    }
    
}

struct ImagePicker3: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var completion: (UIImage?) -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker3
        init(parent: ImagePicker3) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.completion(uiImage)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


