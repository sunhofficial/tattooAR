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
        ZStack{
            Color.backGround
            VStack {
                PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                    Rectangle()
                        .fill(Color.gray)
                        .opacity(0.3)
                        .frame(maxHeight: UIScreen.main.bounds.height/2)
                        .aspectRatio(1,contentMode: .fit)
                        .overlay(
                            Group{
                                if let objectImage = vm.objectImage {
                                    Image(uiImage: objectImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else{
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                    .frame(width: 40,height: 40)}
                            }
                        )
                }
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
            .padding()
        }
        .ignoresSafeArea()
    }
}

struct InputImageView_Previews: PreviewProvider {
    static var previews: some View {
        InputImageView()
    }
}
