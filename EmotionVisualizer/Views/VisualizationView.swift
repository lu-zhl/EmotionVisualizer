import SwiftUI

struct VisualizationView: View {
    let entry: EmotionEntry
    @State private var isGenerating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                situationCard
                
                emotionsCard
                
                if isGenerating {
                    generatingView
                } else {
                    visualizationCard
                }
                
                insightsCard
            }
            .padding()
        }
        .navigationTitle("Visualization")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var situationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Situation", systemImage: "text.bubble")
                .font(.headline)
            
            Text(entry.situation)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var emotionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Emotions", systemImage: "face.smiling")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(entry.emotions) { emotion in
                    HStack {
                        Image(systemName: emotion.icon)
                        Text(emotion.displayName)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Intensity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: entry.intensity)
                    .tint(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var generatingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Generating visualization...")
                .font(.headline)
            
            Text("AI is analyzing your emotional state")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var visualizationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Visual Representation", systemImage: "photo")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 250)
                .overlay(
                    Text("Visualization placeholder")
                        .foregroundColor(.white)
                        .font(.headline)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Insights", systemImage: "lightbulb")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                InsightRow(text: "Your emotions show a complex pattern")
                InsightRow(text: "Multiple feelings are present simultaneously")
                InsightRow(text: "This is a normal response to challenging situations")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InsightRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(.blue)
                .padding(.top, 6)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalHeight += lineHeight
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            subview.place(
                at: CGPoint(x: lineX, y: lineY),
                proposal: ProposedViewSize(size)
            )
            
            lineHeight = max(lineHeight, size.height)
            lineX += size.width + spacing
        }
    }
}

#Preview {
    NavigationStack {
        VisualizationView(entry: EmotionEntry.sampleEntries[0])
    }
}
