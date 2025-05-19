import SwiftUI

struct PhotoGridView: View {
    @StateObject private var viewModel:PhotoGridViewModel
    
    init(viewModel:PhotoGridViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        ForEach(viewModel.images.indices, id: \.self) { index in
                            Image(uiImage: viewModel.images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Pexels Gallery")
            .task {
                await viewModel.loadImages(for: "desert")
            }
        }
    }
}
