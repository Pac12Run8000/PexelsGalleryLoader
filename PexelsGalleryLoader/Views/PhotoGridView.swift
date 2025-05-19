import SwiftUI

struct PhotoGridView: View {
    @StateObject private var viewModel: PhotoGridViewModel
    @State private var selectedQuery = "summer"
    @State private var submittedQuery = "summer"

    private let searchOptions = ["summer", "nature", "football", "boxing", "karate"]

    init(viewModel: PhotoGridViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Dropdown and submit button
                HStack {
                    Picker("Search Topic", selection: $selectedQuery) {
                        ForEach(searchOptions, id: \.self) { option in
                            Text(option.capitalized).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button("Submit") {
                        submittedQuery = selectedQuery
                        Task {
                            await viewModel.loadImages(for: submittedQuery)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                // Scrollable image display
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
            }
            .navigationTitle("Pexels Gallery")
        }
    }
}
