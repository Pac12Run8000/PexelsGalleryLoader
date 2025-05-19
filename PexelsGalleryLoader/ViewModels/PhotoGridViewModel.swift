import SwiftUI

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    @Published var isLoading = false

    func loadImages(for query: String) async {
        isLoading = true
        images.removeAll()

        do {
            let photos = try await PexelsAPIService.fetchPhotos(for: query)
            
            await withTaskGroup(of: UIImage?.self) { group in
                for photo in photos {
                    group.addTask {
                        guard let url = URL(string: photo.src.medium),
                              let data = try? Data(contentsOf: url),
                              let image = UIImage(data: data) else { return nil }
                        return image
                    }
                }
                
                for await image in group {
                    if let image = image {
                        images.append(image)
                    }
                }
            }
        } catch {
            print("Failed to load images: \(error)")
        }

        isLoading = false
    }
}
