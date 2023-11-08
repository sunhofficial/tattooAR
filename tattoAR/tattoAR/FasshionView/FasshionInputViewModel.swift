//
//  FasshionInputViewModel.swift
//  tattoAR
//
//  Created by 235 on 10/28/23.
//

import SwiftUI
import PhotosUI
import VisionKit
import Observation

enum FasshionType {
    case top, bottom
}

@MainActor
class FasshionInputViewModel: ObservableObject {
    @Published private(set) var imageView = FashionImageView()
    @Published var topImage : UIImage? = nil {
        didSet {
            updateCombineImage()
        }
    }
    @Published private(set) var bottomImage : UIImage? = nil {
        didSet {
            updateCombineImage()
        }
    }
    @Published var combineImage: UIImage?
    @Published var topImageSelection: UIImage? = nil {
        didSet {
            setImage(from: topImageSelection, .top)
        }
    }

    @Published var bottomImageSelection: UIImage? = nil {
        didSet {
            setImage(from: bottomImageSelection, .bottom)
        }
    }
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()

    private func updateCombineImage() {
        if let topImage = topImage, let bottomImage = bottomImage {
            combineImage = combineVertically(bottomImage, topImage)
        }
    }

    func saveCombineImage() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask) [0]
        if let combineImage = combineImage, let data = combineImage.pngData() {
            let filePath = documentDirectory.appendingPathComponent("\(combineImage.hashValue).png")
            try? data.write(to: filePath)
//            DispatchQueue.main.async {
//                var texture = try? TextureResource.load(contentsOf: filePath)
//            }
        }
    }
    private func combineVertically(_ image1: UIImage, _ image2: UIImage) -> UIImage {
        var size = CGSize.zero
        var scale = CGFloat.zero
        scale = max(image1.scale, image2.scale)
        size = CGSize(width: image2.size.width + image1.size.width, height: image1.size.height + image2.size.height)
        var postion = CGPoint.zero
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image2.draw(at: postion)
            postion.y += image2.size.height
            postion.x += (image2.size.width - image1.size.width) / 2
            image1.draw(at: postion)
        }
    }

    private func setImage(from selection: UIImage?, _ type: FasshionType) {
        guard let selection else{return}
        Task {
            do {
                imageView.image = selection
                imageView.addInteraction(interaction)
                try await analyzeImage(type)
            } catch {
                print(error)
            }
        }
    }

    private func analyzeImage(_ type: FasshionType) async throws {
        Task{
            do{
                if let image = imageView.image {
                    let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
                    let analysis = try? await analyzer.analyze(image, configuration: configuration)
                    if let analysis = analysis {
                        interaction.analysis = analysis
                        interaction.preferredInteractionTypes = .imageSubject
                        switch type {
                        case .top:
                            topImage = try await interaction.image(for: interaction.subjects)
                        case .bottom:
                            bottomImage =  try await interaction.image(for: interaction.subjects)
                        }
                    }
                }
            } catch {
                print("\(error)")
            }
        }
    }
}



class FashionImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        .zero
    }
}
