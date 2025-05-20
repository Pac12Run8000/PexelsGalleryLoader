import SwiftUI

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var isLoading = false

    private let service: PexelsServiceProtocol

    // Custom session to avoid overloads
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.httpMaximumConnectionsPerHost = 4
        return URLSession(configuration: config)
    }()

    // Inject service through the initializer
    init(service: PexelsServiceProtocol) {
        self.service = service
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
                        // If the path doesn't start with http, assume it's an asset name
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
                } else {
                    print("⚠️ Attempt \(attempt): Couldn't convert data to UIImage")
                }
            } catch {
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
            }

            if attempt <= retries {
                print("⏱️ Waiting \(delay)s before retry...")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        print("💀 All attempts failed: \(urlString)")
        return nil
    }
}
