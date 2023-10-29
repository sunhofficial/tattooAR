//
//  FasshionInputView.swift
//  tattoAR
//
//  Created by 235 on 10/28/23.
//

import SwiftUI
import PhotosUI

struct FasshionInputView: View {
    @ObservedObject var viewModel = FasshionInputViewModel()
    @State private var showTopPicker = false
    @State private var showBottomPicker = false
    @State private var croppedImage: UIImage?
    var body: some View {
        VStack {
            Text("상의")
                .modifier(TitleModifier())
            topView

            Text("하의")
                .modifier(TitleModifier())
            bottomView
            nextButton

        }
        .padding(.horizontal, 30)
    }
}

extension FasshionInputView {
    struct TitleModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.photoFontColor)
                .padding(.vertical, 10)
        }
    }
    var nextButton: some View {
        NavigationLink (destination: FasshionARView()) {
            HStack {
                Label("옷조합하기", systemImage: "tshirt.fill")
                    .foregroundStyle(Color.mainColor)
                    .font(.system(size: 24, weight: .medium))
                    .blur(radius: 8.0)
                    .overlay {
                        Label("옷조합하기", systemImage: "tshirt.fill")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 24, weight: .medium))
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .stroke(Color.mainColor,lineWidth: 4)
                    .blur(radius: 4)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20,style: .continuous)
                    .fill(.clear)
                    .stroke(Color.mainColor, lineWidth: 2)
                    .blur(radius: 0.52)
            }
            .overlay{
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.clear)
                    .stroke(Color.white, lineWidth: 1)
                    .blur(radius: 0.35)
            }
        }

    }
    @ViewBuilder
    func imageView(withImage image: UIImage?, showPicker: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        Rectangle()
            .fill(image != nil ? Color.white : Color.photoBackGround)
            .overlay(
                Group{
                    if let objectImage = image {
                        Image(uiImage:objectImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else{
                        VStack{
                            Image(systemName: "photo.fill")
                                .resizable()
                                .foregroundStyle(Color.photoFontColor)
                                .frame(width: 40,height: 40)
                                .padding(.bottom,10)
                            Text("Click here to add an Image")
                                .font(.body)
                                .foregroundStyle(Color.photoFontColor)
                        }
                    }

                }
            )
            .onTapGesture {
                showPicker.wrappedValue = true
            }
            .cropImagePicker(show: showPicker, croppedImage: croppedImage)
    }

    var topView: some View {
        imageView(withImage: viewModel.topImage, showPicker: $showTopPicker, croppedImage: $viewModel.topImageSelection)
    }

    var bottomView: some View {
        imageView(withImage: viewModel.bottomImage, showPicker: $showBottomPicker, croppedImage: $viewModel.bottomImageSelection)
    }

}
