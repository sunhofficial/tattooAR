//
//  InputImageViewModel.swift
//  tattoAR
//
//  Created by 235 on 2023/09/10.
//

import SwiftUI
import PhotosUI
import VisionKit
@MainActor
class InputImageViewModel: ObservableObject {
    @Published private(set) var imageView = LiftImageView()
    @Published private(set) var objectImage : UIImage? = nil
//    @Published private(set) var isSucceedImage: Bool = false
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else{return}
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                imageView.image = uiImage
                imageView.addInteraction(interaction)
                try await analyzeImage()
            } catch {
                print(error)
            }
        }
    }
    private func analyzeImage() async throws {
        Task{
            do{
                if let image = imageView.image {
                    let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
                    let analysis = try? await analyzer.analyze(image, configuration: configuration)
                    if let analysis = analysis {
                        interaction.analysis = analysis
                        interaction.preferredInteractionTypes = .imageSubject
                        objectImage = try await interaction.image(for: interaction.subjects)
                    }
                }
            } catch {
                print("\(error)")
            }
        }
    }
    func applySaturationImage(to image: UIImage, slidervalue: Double) -> UIImage {
        let ciimage = CIImage(image: image)
          guard let filter = CIFilter(name: "CIColorControls") else { return image }
          filter.setValue(ciimage, forKey: kCIInputImageKey)
          filter.setValue(1.0 - slidervalue / 10 , forKey: kCIInputSaturationKey)
        guard let result = filter.outputImage else{ return image}
          guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return image }
          return UIImage(cgImage: newCgImage)
    }

}

