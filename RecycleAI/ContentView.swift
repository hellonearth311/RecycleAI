//
//  ContentView.swift
//  RecycleAI
//
//  Created by Swarit Narang on 8/5/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var isScanning = false
    @State private var scanResult: ScanResult? = nil
    @State private var isFrozen = false

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 240)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                        if isScanning {
                            Color.black.opacity(0.3)
                                .cornerRadius(16)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                        }
                    } else if !isFrozen {
                        CameraLivePreview(image: $image, isFrozen: $isFrozen)
                            .frame(width: 320, height: 240)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                    }
                }
                Button(action: {
                    if scanResult != nil {
                        // Retake - clear everything and go back to camera preview
                        scanResult = nil
                        image = nil
                        isFrozen = false
                    } else if !isFrozen {
                        // Freeze preview and capture image
                        isFrozen = true
                        isScanning = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isScanning = false
                            scanResult = ScanResult(
                                isRecyclable: true,
                                kind: "Plastic Bottle",
                                location: "Blue Bin"
                            )
                        }
                    }
                }) {
                    Text(scanResult != nil ? "Retake" : (isFrozen ? (isScanning ? "Scanning..." : "Scan Trash") : "Scan Trash"))
                        .font(.title2)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: 200)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .disabled(isScanning)
                if let scanResult = scanResult {
                    ScanResultCard(result: scanResult)
                        .padding(.top)
                }
            }
            .navigationTitle("RecycleAI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("RecycleAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.green)
        }
        .accentColor(.white)
    }
}

// MARK: - CameraLivePreview
struct CameraLivePreview: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var isFrozen: Bool
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraLivePreview
        var session: AVCaptureSession?
        var output: AVCapturePhotoOutput?
        init(_ parent: CameraLivePreview) {
            self.parent = parent
        }
        func capturePhoto() {
            guard let output = output else { return }
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: self)
        }
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let data = photo.fileDataRepresentation(), let uiImage = UIImage(data: data) {
                parent.image = uiImage
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return view
        }
        session.addInput(input)
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 240)
        view.layer.addSublayer(previewLayer)
        session.startRunning()
        context.coordinator.session = session
        context.coordinator.output = output
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        if isFrozen, let session = context.coordinator.session, let output = context.coordinator.output, image == nil {
            // Only capture once
            context.coordinator.capturePhoto()
            session.stopRunning()
        }
    }
}

// MARK: - ScanResult
struct ScanResult {
    let isRecyclable: Bool
    let kind: String
    let location: String
}

// MARK: - ScanResultCard
struct ScanResultCard: View {
    let result: ScanResult
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.isRecyclable ? "Recyclable" : "Not Recyclable")
                .font(.headline)
                .foregroundColor(result.isRecyclable ? .green : .red)
            Text("Type: \(result.kind)")
                .font(.subheadline)
                .foregroundColor(.white)
            Text("Where: \(result.location)")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    ContentView()
}
