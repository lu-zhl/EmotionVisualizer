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

            BackendTestTabView()
                .tabItem {
                    Label("Backend", systemImage: "network")
                }
        }
    }
}

// Inline Backend Test View
struct BackendTestTabView: View {
    @State private var statusMessage = ""
    @State private var isConnected = false
    @State private var email = "test@example.com"
    @State private var password = "Test123!"
    @State private var name = "Test User"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status
                    HStack {
                        Circle()
                            .fill(isConnected ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        Text(isConnected ? "Backend Connected" : "Not Connected")
                            .font(.subheadline)
                    }

                    // Test Connection Button
                    Button(action: testConnection) {
                        Label("Test Connection", systemImage: "wifi")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Divider()

                    // Registration Form
                    GroupBox("Register User") {
                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)

                            SecureField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)

                            TextField("Name", text: $name)
                                .textFieldStyle(.roundedBorder)

                            Button(action: registerUser) {
                                Label("Register", systemImage: "person.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }

                    // Status Message
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
            .navigationTitle("Backend Test")
        }
    }

    func testConnection() {
        Task {
            do {
                let url = URL(string: "http://localhost:8000/health")!
                let (data, response) = try await URLSession.shared.data(from: url)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    await MainActor.run {
                        isConnected = true
                        statusMessage = "✅ Connected! Status: \(json?["status"] as? String ?? "unknown")"
                    }
                } else {
                    await MainActor.run {
                        isConnected = false
                        statusMessage = "❌ Connection failed"
                    }
                }
            } catch {
                await MainActor.run {
                    isConnected = false
                    statusMessage = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }

    func registerUser() {
        Task {
            do {
                let url = URL(string: "http://localhost:8000/api/v1/auth/register")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let body: [String: Any] = [
                    "email": email,
                    "password": password,
                    "name": name
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)

                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        let dataDict = json?["data"] as? [String: Any]
                        let user = dataDict?["user"] as? [String: Any]
                        let userName = user?["name"] as? String ?? "User"

                        await MainActor.run {
                            isConnected = true
                            statusMessage = "✅ Registered successfully! Welcome \(userName)"
                        }
                    } else {
                        await MainActor.run {
                            statusMessage = "❌ Registration failed (status: \(httpResponse.statusCode))"
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    statusMessage = "❌ Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
