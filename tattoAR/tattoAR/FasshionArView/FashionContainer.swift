//
//  FashionContainer.swift
//  tattoAR
//
//  Created by 235 on 10/29/23.
//

import SwiftUI
import RealityKit
import SceneKit
import ARKit
import FocusEntity

struct FashionContainer: UIViewControllerRepresentable {
    var clothesImage: UIImage
    typealias UIViewControllerType = FasshionARViewController
    func makeUIViewController(context: Context) -> FasshionARViewController {
        let viewController = FasshionARViewController(clothesImage: clothesImage)
        return viewController
    }

    func updateUIViewController(_ uiViewController: FasshionARViewController, context: Context) {

    }
}
