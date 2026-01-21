// LocationSearchView.swift
import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locationService = LocationService(completer: .init())
    @State private var search: String = ""
    @Binding var searchResults: [SearchResult]
    
    var body: some View {
        VStack {
            // MARK: - Search Header
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search for a restaurant", text: $search)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                searchResults = (try? await locationService.search(with: search)) ?? []
                            }
                        }
                }
                .modifier(TextFieldGrayBackgroundColor())
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.blue)
            }
            .padding(.top, 10)
            
            Spacer()
            
            // MARK: - Results List
            List {
                ForEach(locationService.completions) { completion in
                    Button(action: { didTapOnCompletion(completion) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .fontDesign(.rounded)
                                .foregroundStyle(.primary)
                            Text(completion.subTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .onChange(of: search) {
            locationService.update(queryFragment: search)
        }
        .padding()
        .presentationDetents([.medium, .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
    
    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let results = try? await locationService.search(using: completion.result) {
                searchResults = results
            }
        }
    }
}
