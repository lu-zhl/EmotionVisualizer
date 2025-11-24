import SwiftUI

struct IntakeView: View {
    @ObservedObject var viewModel: EmotionViewModel
    @Binding var isPresented: Bool
    
    @State private var situation = ""
    @State private var selectedEmotions: Set<Emotion> = []
    @State private var intensity: Double = 0.5
    @State private var notes = ""
    @State private var currentStep = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .padding()
                
                if currentStep == 0 {
                    situationStep
                } else if currentStep == 1 {
                    emotionSelectionStep
                } else {
                    intensityStep
                }
                
                Spacer()
                
                navigationButtons
            }
            .padding()
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var situationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Briefly describe what's bothering you or what you're experiencing.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Type here...", text: $situation, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
        }
    }
    
    private var emotionSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What emotions are you feeling?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select all that apply")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(Emotion.allCases) { emotion in
                        EmotionChip(
                            emotion: emotion,
                            isSelected: selectedEmotions.contains(emotion)
                        ) {
                            if selectedEmotions.contains(emotion) {
                                selectedEmotions.remove(emotion)
                            } else {
                                selectedEmotions.insert(emotion)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var intensityStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How intense are these feelings?")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Mild")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Intense")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $intensity, in: 0...1)
                    .tint(.blue)
                
                Text("\(Int(intensity * 100))%")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            
            Text("Additional notes (optional)")
                .font(.headline)
                .padding(.top)
            
            TextField("Add any additional context...", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...5)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < 2 {
                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            } else {
                Button("Complete") {
                    saveEntry()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
            }
        }
        .padding()
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1:
            return !selectedEmotions.isEmpty
        case 2:
            return true
        default:
            return false
        }
    }
    
    private func saveEntry() {
        let entry = EmotionEntry(
            situation: situation,
            emotions: Array(selectedEmotions),
            intensity: intensity,
            notes: notes
        )
        viewModel.addEntry(entry)
        isPresented = false
    }
}

struct EmotionChip: View {
    let emotion: Emotion
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: emotion.icon)
                    .font(.title2)
                
                Text(emotion.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

#Preview {
    IntakeView(viewModel: EmotionViewModel(), isPresented: .constant(true))
}
