import SwiftUI

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var isLoading = false
    let searchOptions: [String]
    
    private let service: PexelsServiceProtocol

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.httpMaximumConnectionsPerHost = 4
        return URLSession(configuration: config)
    }()

    init(service: PexelsServiceProtocol) {
        self.service = service

        // Dynamically assign searchOptions based on service type
        if service is MockPexelsService {
            self.searchOptions = ["boxingImage", "football1", "football2", "football1", "football2"]
        } else {
            self.searchOptions = ["summer", "nature", "football", "boxing", "karate"]
        }
    }

    func loadImages(for query: String) async {
        isLoading = true
        images.removeAll()

        do {
            let photos = try await service.fetchPhotos(for: query)

            await withTaskGroup(of: UIImage?.self) { group in
                for photo in photos.prefix(5) {
                    let path = photo.src.medium
                    group.addTask {
                        if path.hasPrefix("http") {
                            return await self.retryingImageDownload(from: path, retries: 2, delay: 1.0)
                        } else {
                            return UIImage(named: path)
                        }
                    }
                }

                for await image in group {
                    if let image = image {
                        images.append(image)
                    }
                }
            }
        } catch {
            print("Error loading images: \(error)")
        }

        isLoading = false
    }

    private func retryingImageDownload(from urlString: String, retries: Int, delay: TimeInterval) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return nil
        }

        for attempt in 1...retries + 1 {
            do {
                let (data, _) = try await session.data(from: url)
                if let image = UIImage(data: data) {
                    print("✅ Attempt \(attempt): Image created")
                    return image
                }
            } catch {
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
            }

            if attempt <= retries {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        return nil
    }
}
