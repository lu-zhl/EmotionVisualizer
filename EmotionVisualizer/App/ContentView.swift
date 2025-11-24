import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EmotionViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            JournalView(viewModel: viewModel)
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
