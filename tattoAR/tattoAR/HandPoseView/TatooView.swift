//
//  TatooView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/18.
//

import SwiftUI
struct TatooView: View {
    var tatooImage: UIImage
    var body: some View {
        ARViewContainer(tatooImage: tatooImage).ignoresSafeArea(.all)
          
    }
}
