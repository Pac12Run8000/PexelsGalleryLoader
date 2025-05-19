import SwiftUI

struct PhotoGridView: View {
    @StateObject private var viewModel = PhotoGridViewModel()
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.images.indices, id: \.self) { index in
                            Image(uiImage: viewModel.images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Pexels Gallery")
            .task {
                await viewModel.loadImages(for: "city")
            }
        }
    }
}
