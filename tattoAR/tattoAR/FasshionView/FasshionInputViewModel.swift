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
    @Published var topImage : UIImage? = nil
    @Published private(set) var bottomImage : UIImage? = nil
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
