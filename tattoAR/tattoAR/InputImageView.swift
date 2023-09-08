//
//  InputImageView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/08.
//

import SwiftUI
import PhotosUI
struct InputImageView: View {
    @State private var selectedItem: PhotosPickerItem?
    var inputimage = UIImage(named: "SidePerson")
    @ObservedObject var bgRemover = RemoveBackground()
    var body: some View {
        VStack {
            PhotosPicker(selection: $bgRemover.imageSelection, matching: .images) {
                Label("Select a photo", systemImage: "photo")
            }
            .tint(.black)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            
            if let image = bgRemover.selectedImage {
                         Image(uiImage: image)
                             .resizable()
                             .scaledToFit()

                             .cornerRadius(10)
                if bgRemover.outputImage != nil {
                    Image(uiImage: bgRemover.outputImage!)
                        .resizable()
                        .scaledToFit()
                } else {
                    Button("segment") {
                        bgRemover.inputImage = image
                        bgRemover.segmentImage()
                    }
                }
                     }

        }.padding()
    }
}
