//
//  TatooView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/18.
//

import SwiftUI
struct TatooView: View {
    var tatooImage: UIImage
    var handtattooMode: Bool
    var body: some View {
        if(handtattooMode) {
            ARViewContainer(tatooImage: tatooImage).ignoresSafeArea(.all)
        }
        else {
            ARViewRepresentable( tatooImage: tatooImage)
                .ignoresSafeArea(.all)
        }

          
    }
}
