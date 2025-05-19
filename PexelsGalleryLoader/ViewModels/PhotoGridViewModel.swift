import SwiftUI

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var isLoading = false

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.httpMaximumConnectionsPerHost = 3
        return URLSession(configuration: config)
    }()

    func loadImages(for query: String) async {
        print("🔍 Starting load for query: \(query)")
        isLoading = true
        images.removeAll()

        do {
            let photos = try await PexelsAPIService.fetchPhotos(for: query)
            print("✅ Retrieved \(photos.count) photos")

            await withTaskGroup(of: UIImage?.self) { group in
                for photo in photos.prefix(5) { // Reduce during testing
                    group.addTask {
                        await self.retryingImageDownload(from: photo.src.medium, retries: 2, delay: 1.0)
                    }
                }

                for await image in group {
                    if let image = image {
                        images.append(image)
                    }
                }
            }
        } catch {
            print("❌ Error during loadImages: \(error.localizedDescription)")
        }

        isLoading = false
        print("✅ Finished loading images")
    }

    private func retryingImageDownload(from urlString: String, retries: Int, delay: TimeInterval) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            return nil
        }

        print("🔗 Downloading: \(url.absoluteString)")

        for attempt in 1...retries + 1 {
            do {
                let (data, _) = try await session.data(from: url)
                if let image = UIImage(data: data) {
                    print("🖼️ Image success on attempt \(attempt)")
                    return image
                } else {
                    print("⚠️ Attempt \(attempt): Invalid image data")
                }
            } catch {
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
            }

            if attempt <= retries {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        print("💀 All attempts failed: \(url.absoluteString)")
        return nil
    }
}
