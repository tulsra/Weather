//
//  ImageDownloaderView.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import SwiftUI

struct ImageDownloaderView: View {
    @State private var imageDownloader: ImageDownloader = ImageDownloader()
    var url: String
    
    var body: some View {
        Group {
            Image(uiImage: imageDownloader.image)
                .resizable()
                .scaledToFit()
        }
        .onAppear {
            imageDownloader.downloadImage(from: url)
        }
    }
}
