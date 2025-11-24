import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 100))
                    .foregroundStyle(.blue)

                Text("EmotionVisualizer")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Ready to start tracking emotions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
