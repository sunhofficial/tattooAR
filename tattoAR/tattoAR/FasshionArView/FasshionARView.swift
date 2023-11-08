//
//  FasshionARView.swift
//  tattoAR
//
//  Created by 235 on 10/29/23.
//
//
import SwiftUI
struct FasshionARView: View {
    var clothesImage: UIImage
    var body: some View {
        FashionContainer(clothesImage: clothesImage)
            .ignoresSafeArea(.all)
    }
}
