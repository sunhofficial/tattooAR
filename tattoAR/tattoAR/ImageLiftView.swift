//
//  ImageLiftView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/10.
//

import SwiftUI
struct ImageLiftView: View {
    @Environment(\.presentationMode) var presentationMode
    var selectImage: UIImage
    @State var chooseImage =  UIImage()
    var body: some View {
        NavigationView {
            VStack {
                ImageLift(selectImage: selectImage, objectImage: $chooseImage)
                    .padding(.top,40)
                    .padding(.horizontal,40)

                Image(uiImage:chooseImage ?? UIImage())
                    .resizable()
                    .frame(width: 200,height: 200)
                    .padding(.bottom,40)

            }

                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .interactiveDismissDisabled(true)
        }
    }
}
