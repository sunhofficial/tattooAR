//
//  ARViewRepresentable.swift
//  tattoAR
//
//  Created by 235 on 10/8/23.
//

import ARKit
import SwiftUI

struct ARViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = FaceARController
    var tatooImage: UIImage
    func makeUIViewController(context: Context) -> FaceARController {
        return FaceARController(tattooImage: tatooImage)
    }
    
    func updateUIViewController(_ uiViewController: FaceARController, context: Context) {
    
    }
    


}


