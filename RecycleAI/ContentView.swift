//
//  ContentView.swift
//  RecycleAI
//
//  Created by Swarit Narang on 8/5/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var showCamera = false
    @State private var image: UIImage? = nil

    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                }
                Button(action: {
                    showCamera = true
                }) {
                    Label("Open Camera", systemImage: "camera")
                        .font(.title2)
                        .padding()
                }
                .sheet(isPresented: $showCamera) {
                    CameraView(image: $image, isShown: $showCamera)
                }
            }
            .navigationTitle("RecycleAI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("RecycleAI")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isShown: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.isShown = false
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isShown = false
        }
    }
}

#Preview {
    ContentView()
}
