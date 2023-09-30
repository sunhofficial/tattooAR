//
//  InputImageView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/08.
//

import SwiftUI
import PhotosUI
struct InputImageView: View {
    @ObservedObject var vm = InputImageViewModel()
    @State private var isFullScreenCoverPresented = false
    @State private var sliderValue = 0.0
    var body: some View {
        NavigationStack {
            ZStack{
                Color.backGround
                VStack {
                    PhotoPikerView
                        .padding(.horizontal, 10)
                        .padding(.top, 80)
                    BlackSlider
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    NavigationBtn
                        .padding(.horizontal, 10)
                        .padding(.top, 70)
                }
                .padding()
            }
            .ignoresSafeArea()
        }
    }
}
extension InputImageView {
    var PhotoPikerView: some View {
        PhotosPicker(selection: $vm.imageSelection, matching: .images) {
            Rectangle()
                .fill(vm.objectImage != nil ? Color.white : Color.gray)
                .opacity(0.7)
                .frame(maxHeight: UIScreen.main.bounds.height/2)
                .aspectRatio(1,contentMode: .fit)
                .overlay(
                    Group{
                        if let objectImage = vm.objectImage {
                            Image(uiImage: objectImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .saturation(1.0 - sliderValue / 10 )
                        } else{
                            Image(systemName: "photo.fill")
                                .resizable()
                            .frame(width: 40,height: 40)}
                    }
                )
        }
    }
    var BlackSlider: some View {
        Slider(value: $sliderValue, in: 0...10, step: 1)
            .tint(.black)
            .padding(.top,30)
            .overlay(GeometryReader{ geo in
                Text("\(sliderValue, specifier: "%.f")")
                    .foregroundStyle(.black)
                    .font(.system(size: 18, weight: .semibold))
                    .alignmentGuide(HorizontalAlignment.leading){
                        return $0[HorizontalAlignment.leading] - (geo.size.width - $0.width * 2) * sliderValue / 10  - 5
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }, alignment: .top)
    }
    var NavigationBtn: some View {
        NavigationLink(destination: TatooView(tatooImage: vm.objectImage ?? UIImage(), blackPoint: sliderValue)) {
            HStack {
                Image("TatooBtn")
                Text("타투하러가기")
                    .foregroundStyle(Color.black)
                    .font(.system(size: 30, weight: .bold))
            }
            .padding(.horizontal, 58)
            .padding(.vertical, 10)
            .background(LinearGradient(colors: [Color.graidentBtnColor, Color.mainColor], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.mainColor ,radius: 10)
        }
    }
}

struct InputImageView_Previews: PreviewProvider {
    static var previews: some View {
        InputImageView()
    }
}
