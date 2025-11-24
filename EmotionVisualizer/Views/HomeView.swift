import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @State private var showingIntake = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerSection
                
                if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    recentEntriesSection
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("EmotionVisualizer")
            .sheet(isPresented: $showingIntake) {
                IntakeView(viewModel: viewModel, isPresented: $showingIntake)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("How are you feeling?")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Visualize your emotions and gain insights")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingIntake = true }) {
                Label("Start New Session", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No entries yet")
                .font(.headline)
            
            Text("Start by creating your first emotion entry")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.entries.prefix(5)) { entry in
                        EntryCard(entry: entry)
                    }
                }
            }
        }
    }
}

struct EntryCard: View {
    let entry: EmotionEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.situation)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                ForEach(entry.emotions.prefix(3)) { emotion in
                    Label(emotion.displayName, systemImage: emotion.icon)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            ProgressView(value: entry.intensity)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView(viewModel: EmotionViewModel())
}
