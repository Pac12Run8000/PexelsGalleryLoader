import XCTest
@testable import PexelsGalleryLoader
import SwiftUI

@MainActor
final class PhotoGridViewModelTests: XCTestCase {
    
    var viewModel: PhotoGridViewModel!
    var mockService: MockPexelsService!

    override func setUp() async throws {
        mockService = MockPexelsService()
        viewModel = PhotoGridViewModel(service: mockService)
    }
    
    override func tearDown() async throws {
        mockService = nil
        viewModel = nil
    }

    func testLoadImages_populatesImages() async throws {
        XCTAssertTrue(viewModel.images.isEmpty)
        await viewModel.loadImages(for: "boxing")

        XCTAssertEqual(viewModel.images.count, 5, "Expected 5 images to be loaded from mock service.")
    }

    func testIsLoadingTransitions() async throws {
        XCTAssertFalse(viewModel.isLoading)
        
        let loadTask = Task {
            await viewModel.loadImages(for: "football")
        }
        
        // Yield to allow the loadImages task to start and update `isLoading`
        await Task.yield()
        XCTAssertTrue(viewModel.isLoading, "`isLoading` should be true during fetch")
        
        // Wait for the task to complete
        await loadTask.value
        XCTAssertFalse(viewModel.isLoading, "`isLoading` should be false after fetch")
    }


    func testImagesLoadedFromAsset() async throws {
        await viewModel.loadImages(for: "karate")
        let nonNilImages = viewModel.images.filter { $0 != nil }
        XCTAssertEqual(nonNilImages.count, 5, "All images should load from assets without nil")
    }
}
