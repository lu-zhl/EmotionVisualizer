import SwiftUI

struct BackendTestView: View {
    @State private var email = "test@example.com"
    @State private var password = "Test123!"
    @State private var name = "Test User"
    @State private var situation = "Feeling great today!"
    @State private var selectedEmotions: Set<String> = ["joy", "excitement"]
    @State private var intensity: Double = 0.8
    @State private var statusMessage = ""
    @State private var isConnected = false
    @State private var isLoading = false

    let availableEmotions = ["joy", "sadness", "anger", "fear", "excitement", "anxiety"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Backend Integration Test")
                    .font(.largeTitle)
                    .bold()

                // Connection Status
                HStack {
                    Circle()
                        .fill(isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(isConnected ? "Backend Connected" : "Backend Disconnected")
                        .font(.subheadline)
                }

                // Test Connection Button
                Button(action: testConnection) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Test Connection")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading)

                Divider()

                // Registration/Login Section
                GroupBox(label: Text("Authentication").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        HStack(spacing: 12) {
                            Button("Register") {
                                Task {
                                    await registerUser()
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Login") {
                                Task {
                                    await loginUser()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Divider()

                // Create Entry Section
                GroupBox(label: Text("Create Entry").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Situation", text: $situation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Emotions:")
                            .font(.subheadline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(availableEmotions, id: \.self) { emotion in
                                Toggle(emotion.capitalized, isOn: Binding(
                                    get: { selectedEmotions.contains(emotion) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedEmotions.insert(emotion)
                                        } else {
                                            selectedEmotions.remove(emotion)
                                        }
                                    }
                                ))
                                .toggleStyle(.button)
                            }
                        }

                        VStack(alignment: .leading) {
                            Text("Intensity: \(intensity, specifier: "%.2f")")
                                .font(.subheadline)
                            Slider(value: $intensity, in: 0...1, step: 0.1)
                        }

                        Button("Create Entry") {
                            Task {
                                await createEntry()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }

                // Status Messages
                if !statusMessage.isEmpty {
                    GroupBox {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(isConnected ? .green : .red)
                    }
                }
            }
            .padding()
        }
    }

    func testConnection() {
        isLoading = true
        Task {
            do {
                let connected = try await APIService.shared.testConnection()
                await MainActor.run {
                    isConnected = connected
                    statusMessage = connected ? "✅ Successfully connected to backend!" : "❌ Failed to connect"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isConnected = false
                    statusMessage = "❌ Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    func registerUser() async {
        do {
            let response = try await APIService.shared.register(email: email, password: password, name: name)
            await MainActor.run {
                statusMessage = "✅ Registered successfully! User: \(response.user.name)"
                isConnected = true
            }
        } catch {
            await MainActor.run {
                statusMessage = "❌ Registration failed: \(error.localizedDescription)"
            }
        }
    }

    func loginUser() async {
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            await MainActor.run {
                statusMessage = "✅ Logged in successfully! Welcome \(response.user.name)"
                isConnected = true
            }
        } catch {
            await MainActor.run {
                statusMessage = "❌ Login failed: \(error.localizedDescription)"
            }
        }
    }

    func createEntry() async {
        guard !selectedEmotions.isEmpty else {
            await MainActor.run {
                statusMessage = "❌ Please select at least one emotion"
            }
            return
        }

        do {
            let entry = try await APIService.shared.createEntry(
                situation: situation,
                emotions: Array(selectedEmotions),
                intensity: intensity,
                notes: ""
            )
            await MainActor.run {
                statusMessage = "✅ Entry created successfully! ID: \(entry.id)"
            }
        } catch {
            await MainActor.run {
                statusMessage = "❌ Failed to create entry: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    BackendTestView()
}
