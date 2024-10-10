//
//  ImageDownloader.swift
//  Weatherman
//
//  Created by Thulasi Ram Boddu on 10/9/24.
//

import Foundation
import SwiftUI
import Combine

@Observable
class ImageDownloader {
    var image: UIImage = UIImage(systemName: "sun.max") ?? UIImage()
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private let cache = NSCache<NSString, UIImage>()
    
    func downloadImage(from urlString: String) {
        // Check if the image is already cached
        if let cachedImage = cache.object(forKey: NSString(string: urlString)) {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Cancel any ongoing requests
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Create a data task to download the image
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                // Check for valid response and data
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .tryMap { data in
                // Try to create an image from the data
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                return image
            }
            .catch { error in
                // Handle errors and return the default image
                print("Error downloading image: \(error)")
                return Just(UIImage(systemName: "sun.max") ?? UIImage())
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] newImage in
                // Cache the downloaded image
                self?.cache.setObject(newImage, forKey: NSString(string: urlString))
            })
            .assign(to: \.image, on: self)
            .store(in: &cancellables)
    }
}
