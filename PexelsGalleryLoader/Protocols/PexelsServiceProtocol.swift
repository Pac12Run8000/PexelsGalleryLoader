import Foundation

protocol PexelsServiceProtocol {
    func fetchPhotos(for query: String) async throws -> [Photo]
}

