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

    func applySketchEffect(to image: UIImage) -> UIImage {
        let ciimage = CIImage(image: image)

        // 채도를 낮춰 흑백으로 변환
        guard let blackAndWhiteImage = ciimage?.applyingFilter("CIPhotoEffectMono") else { return image }

        // 명암 대비를 높이기 위해 CIColorControls 필터 적용
        guard let filter = CIFilter(name: "CIColorControls") else { return image }
        filter.setValue(blackAndWhiteImage, forKey: kCIInputImageKey)
        filter.setValue(2.0, forKey: kCIInputContrastKey) // 명암 대비 조절

        guard let result = filter.outputImage else { return image }
        guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return image }

        return UIImage(cgImage: newCgImage)
    }

}

