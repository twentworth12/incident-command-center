//
//  SettingsView.swift
//  incident-overview
//
//  Created by Claude Code on 7/31/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var apiKey = ""
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isSaveButtonFocused: Bool
    @FocusState private var isTestButtonFocused: Bool
    @FocusState private var isBackButtonFocused: Bool
    
    let onBack: () -> Void
    let onAPISaved: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SettingsHeaderView(
                onBack: onBack
            )
            
            ScrollView {
                VStack(spacing: 60) {
                    APIConfigurationSection(
                        apiKey: $apiKey,
                        isTestingConnection: isTestingConnection,
                        showSuccessMessage: showSuccessMessage,
                        showErrorMessage: showErrorMessage,
                        connectionTestResult: connectionTestResult,
                        onSave: saveAPIKey,
                        onTest: testConnection
                    )
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
            .background(Color.black)
        }
        .background(Color.black)
        .onAppear {
            loadExistingAPIKey()
        }
    }
    
    private func loadExistingAPIKey() {
        if let existingKey = KeychainManager.shared.getAPIKey() {
            apiKey = existingKey
        }
    }
    
    private func saveAPIKey() {
        showSuccessMessage = false
        showErrorMessage = false
        
        let cleanAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let success = KeychainManager.shared.saveAPIKey(cleanAPIKey)
        
        if success {
            apiKey = cleanAPIKey // Update the field with cleaned version
            showSuccessMessage = true
            onAPISaved()
            
            // Hide success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccessMessage = false
            }
        } else {
            showErrorMessage = true
            
            // Hide error message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showErrorMessage = false
            }
        }
    }
    
    private func testConnection() {
        guard !apiKey.isEmpty else { return }
        
        isTestingConnection = true
        connectionTestResult = nil
        
        Task {
            // Use trimmed API key
            let cleanAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
            
            do {
                let url = URL(string: "https://api.incident.io/v2/incidents")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                // Set headers exactly as curl would
                request.setValue("Bearer \(cleanAPIKey)", forHTTPHeaderField: "Authorization")
                request.setValue("*/*", forHTTPHeaderField: "Accept")
                request.setValue("curl/8.4.0", forHTTPHeaderField: "User-Agent")
            
                // Force HTTP/1.1 like curl default
                request.setValue("keep-alive", forHTTPHeaderField: "Connection")
                
                // Create a session that forces HTTP/1.1
                let config = URLSessionConfiguration.ephemeral
                config.httpAdditionalHeaders = [:]
                config.protocolClasses = []
                let session = URLSession(configuration: config)
                
                let (_, response) = try await session.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        await MainActor.run {
                            connectionTestResult = "✅ Success!\n\nAPI key works perfectly"
                            isTestingConnection = false
                        }
                        return
                    }
                }
                
            } catch {
                // Network error - fall back to error message
                await MainActor.run {
                    connectionTestResult = "❌ Connection failed\n\nPlease check your API key and network connection"
                    isTestingConnection = false
                }
            }
            
            // Clear test result after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                connectionTestResult = nil
            }
        }
    }
}

// MARK: - Helper Views

struct SettingsHeaderView: View {
    let onBack: () -> Void
    @FocusState var isBackButtonFocused: Bool
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 16) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 32, weight: .bold))
                    Text("BACK TO DASHBOARD")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isBackButtonFocused ? Color.blue : Color.gray.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isBackButtonFocused ? Color.white : Color.clear, lineWidth: 4)
                        )
                )
            }
            .buttonStyle(.card)
            .focused($isBackButtonFocused)
            .scaleEffect(isBackButtonFocused ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isBackButtonFocused)
            
            Spacer()
            
            Text("SETTINGS")
                .font(.system(size: 64, weight: .black, design: .default))
                .foregroundStyle(Color.incidentGradient)
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 32)
        .background(Color.black)
    }
}

struct APIConfigurationSection: View {
    @Binding var apiKey: String
    let isTestingConnection: Bool
    let showSuccessMessage: Bool
    let showErrorMessage: Bool
    let connectionTestResult: String?
    let onSave: () -> Void
    let onTest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 20) {
                Text("INCIDENT.IO API CONFIGURATION")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("Enter your incident.io API key to connect to your organization's incidents. You can find your API key in the incident.io dashboard under Settings > API Keys.")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            APIKeyInputSection(
                apiKey: $apiKey
            )
            
            APIActionButtons(
                apiKey: $apiKey,
                isTestingConnection: isTestingConnection,
                onSave: onSave,
                onTest: onTest
            )
            
            APIStatusMessages(
                showSuccessMessage: showSuccessMessage,
                showErrorMessage: showErrorMessage,
                connectionTestResult: connectionTestResult
            )
        }
    }
}

struct APIKeyInputSection: View {
    @Binding var apiKey: String
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("API KEY")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Navigate to the text field below and press the center button to activate the keyboard. In Simulator: use Hardware > Keyboard > Toggle Software Keyboard or ⌘K")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("Paste your incident.io API key here", text: $apiKey)
                .font(.system(size: 24, weight: .medium, design: .monospaced))
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(isTextFieldFocused ? 0.15 : 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isTextFieldFocused ? Color.incidentOrange : Color.white.opacity(0.3), lineWidth: isTextFieldFocused ? 4 : 2)
                        )
                )
                .foregroundColor(.white)
                .textFieldStyle(.plain) // Use plain style for tvOS compatibility
                .keyboardType(.asciiCapable) // Better for API keys
                .autocorrectionDisabled(true) // Disable autocorrection for API keys
                .textInputAutocapitalization(.never) // Don't auto-capitalize
                .focused($isTextFieldFocused)
                .scaleEffect(isTextFieldFocused ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                .onSubmit {
                    // Handle when user presses Done/Return
                }
                .onAppear {
                    // Auto-focus the text field when settings opens for better UX
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isTextFieldFocused = true
                    }
                }
            
            if !apiKey.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("API key entered (\(String(apiKey.prefix(8)))...)")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct APIActionButtons: View {
    @Binding var apiKey: String
    @FocusState var isSaveButtonFocused: Bool
    @FocusState var isTestButtonFocused: Bool
    let isTestingConnection: Bool
    let onSave: () -> Void
    let onTest: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 40) {
                Button(action: onSave) {
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                        Text("SAVE API KEY")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        isSaveButtonFocused ? Color.incidentOrange : Color.incidentOrange.opacity(0.8),
                                        isSaveButtonFocused ? Color.incidentYellow : Color.incidentYellow.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSaveButtonFocused ? Color.white : Color.clear, lineWidth: 4)
                            )
                    )
                }
                .buttonStyle(.card)
                .disabled(apiKey.isEmpty)
                .opacity(apiKey.isEmpty ? 0.5 : 1.0)
                .focused($isSaveButtonFocused)
                .scaleEffect(isSaveButtonFocused ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSaveButtonFocused)
            
                Button(action: onTest) {
                    HStack(spacing: 16) {
                        if isTestingConnection {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.white)
                        } else {
                            Image(systemName: "network")
                                .font(.system(size: 28, weight: .bold))
                        }
                        Text(isTestingConnection ? "TESTING..." : "TEST CONNECTION")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isTestButtonFocused ? Color.blue : Color.blue.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isTestButtonFocused ? Color.white : Color.clear, lineWidth: 4)
                            )
                    )
                }
                .buttonStyle(.card)
                .disabled(apiKey.isEmpty || isTestingConnection)
                .opacity(apiKey.isEmpty ? 0.5 : 1.0)
                .focused($isTestButtonFocused)
                .scaleEffect(isTestButtonFocused ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isTestButtonFocused)
            }
        }
    }
}

struct APIStatusMessages: View {
    let showSuccessMessage: Bool
    let showErrorMessage: Bool
    let connectionTestResult: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if showSuccessMessage {
                HStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text("API key saved successfully!")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.green.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if showErrorMessage {
                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                    Text("Failed to save API key. Please try again.")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if let testResult = connectionTestResult {
                HStack(spacing: 16) {
                    Image(systemName: testResult.contains("Success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(testResult.contains("Success") ? .green : .orange)
                    Text(testResult)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(testResult.contains("Success") ? .green : .orange)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill((testResult.contains("Success") ? Color.green : Color.orange).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke((testResult.contains("Success") ? Color.green : Color.orange).opacity(0.5), lineWidth: 2)
                        )
                )
            }
        }
    }
}

