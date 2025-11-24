import SwiftUI

struct JournalView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @State private var selectedEntry: EmotionEntry?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    entriesList
                }
            }
            .navigationTitle("Journal")
            .navigationDestination(item: $selectedEntry) { entry in
                VisualizationView(entry: entry)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No journal entries")
                .font(.headline)
            
            Text("Your emotion entries will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var entriesList: some View {
        List {
            ForEach(groupedEntries.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(dateFormatter.string(from: date))) {
                    ForEach(groupedEntries[date] ?? []) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            JournalEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        deleteEntries(at: indexSet, in: date)
                    }
                }
            }
        }
    }
    
    private var groupedEntries: [Date: [EmotionEntry]] {
        Dictionary(grouping: viewModel.entries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func deleteEntries(at offsets: IndexSet, in date: Date) {
        guard let entries = groupedEntries[date] else { return }
        let entriesToDelete = offsets.map { entries[$0] }
        entriesToDelete.forEach { viewModel.deleteEntry($0) }
    }
}

struct JournalEntryRow: View {
    let entry: EmotionEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.situation)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            HStack {
                ForEach(entry.emotions.prefix(4)) { emotion in
                    Image(systemName: emotion.icon)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if entry.emotions.count > 4 {
                    Text("+\(entry.emotions.count - 4)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption2)
                    Text("\(Int(entry.intensity * 100))%")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    JournalView(viewModel: EmotionViewModel())
}
