//
//  TatooView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/18.
//

import SwiftUI
struct TatooView: View {
    var tatooImage: UIImage
    var blackPoint: Double
    var body: some View {
        ARViewContainer(tatooImage: tatooImage, blackPoint: blackPoint).ignoresSafeArea(.all)
    }
}
