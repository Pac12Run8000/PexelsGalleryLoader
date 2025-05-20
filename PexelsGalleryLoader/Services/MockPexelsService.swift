import Foundation

struct MockPexelsService: PexelsServiceProtocol {
    func fetchPhotos(for query: String) async throws -> [Photo] {
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let assetNames:[String] = ["boxingImage", "football1", "football2", "football1", "football2"]
        
        return assetNames.enumerated().map { index, name in
            Photo(
                id: index,
                width: 350,
                height: 250,
                url: "",
                photographer: "Mock Photographer",
                photographerURL: "",
                photographerID: 0,
                avgColor: "#000000",
                src: Src(
                    original: name,
                    large2X: name,
                    large: name,
                    medium: name, // This is the one you're using
                    small: name,
                    portrait: name,
                    landscape: name,
                    tiny: name
                ),
                liked: false,
                alt: "Mock image for \(query)"
            )
        }
    }
}
