//
//  InputImageView.swift
//  tattoAR
//
//  Created by 235 on 2023/09/08.
//

import SwiftUI
import PhotosUI
struct InputImageView: View {
//    @State private var selectedItem: PhotosPickerItem?
//    @ObservedObject var bgRemover = RemoveBackground()
    @ObservedObject var vm = InputImageViewModel()
    @State private var isFullScreenCoverPresented = false
    var body: some View {
        VStack {
            PhotosPicker(selection: $vm.imageSelection, matching: .images) {
                Rectangle()
                    .fill(Color.gray)
                    .opacity(0.3)
                    .frame(maxHeight: UIScreen.main.bounds.height/2)
                    .background(
                        Group{
                            if let objectImage = vm.objectImage {
                                Image(uiImage: objectImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }else{
                                Image(systemName: "photo.fill")
                                    .resizable()
                                .frame(width: 40,height: 40)}
                        }
                    )
                    .padding(.horizontal,20)
                    .padding(.top,10)
                    .aspectRatio(1,contentMode: .fit)

            }
            Spacer()
        }
        .padding()
//        .onReceive(vm.$selectedImage, perform: { newImage in
//                // selectedImage가 변경될 때 isFullScreenCoverPresented를 조절
//                isFullScreenCoverPresented = newImage != nil
//            })
//        .fullScreenCover(isPresented: $isFullScreenCoverPresented, content: {
//            ImageLiftView(selectImage: vm.selectedImage!)
//        })
    }
}
