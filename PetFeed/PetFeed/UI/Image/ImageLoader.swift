//
//  ImageLoader.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import UIKit
import Combine

/// Image loader responsible for loading the Image either from Cache or Downloading from the internet
class ImageLoader: ObservableObject {
    private static let imageProcessingQueue = DispatchQueue(label: "ImageProcessing")

    private var cache: ImageCache?
    private var url: URL?
    private var service: PetRepository?
    @Published var image: UIImage?

    private(set) var isLoading = false
    private var cancellable: AnyCancellable?
    init(url: URL?, cache: ImageCache? = nil, service: PetRepository) {
        guard let url = url else {
            return
        }
        self.url = url
        self.service = service
        self.cache = cache
    }

    deinit {
        cancel()
    }

    func load() {
        guard let url = url else {
            return
        }
        guard !isLoading else { return }
        if let image = cache?[url] {
            self.image = image
            return
        }

        cancellable = service?.download(url)
            .subscribe(on: Self.imageProcessingQueue)
            .map { UIImage(data: $0) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)

    }

    private func cache(_ image: UIImage?) {
        guard let url = url else {
            return
        }
        image.map { cache?[url] = $0 }
    }

    func cancel() {
        cancellable?.cancel()
    }

    private func onStart() {
        isLoading = true
    }

    private func onFinish() {
        isLoading = false
    }
}
