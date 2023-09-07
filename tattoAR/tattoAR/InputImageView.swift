//
//  InputImageView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/08.
//

import SwiftUI
struct InputImageView: View {
    var inputimage = UIImage(named: "SidePerson")
    @ObservedObject var bgRemover = RemoveBackground()
    var body: some View {
        VStack {
            Image(uiImage: inputimage!)
                .resizable()
                .scaledToFit()
            if bgRemover.outputImage != nil {
                Image(uiImage: bgRemover.outputImage!)
                    .resizable()
                    .scaledToFit()
            } else {
                Button("segment") {
                    bgRemover.inputImage = inputimage!
                    bgRemover.segmentImage()
                }
            }
        }.padding()
    }
}
