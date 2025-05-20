import SwiftUI

@main
struct PexelsGalleryLoaderApp: App {
    var body: some Scene {
        WindowGroup {
            PhotoGridView(viewModel: PhotoGridViewModel(service: PexelsAPIService()))
        }
    }
}
