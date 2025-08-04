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
                    
                    ThemeSelectionSection()
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
            .background(Color.incidentSand)
        }
        .background(Color.incidentSand)
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
                    Text("Back to dashboard")
                        .font(.incidentTVCaption())
                }
                .foregroundColor(.incidentCharcoal)
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                        .fill(isBackButtonFocused ? Color.incidentAlarmalade : Color.incidentSand.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                .stroke(isBackButtonFocused ? Color.incidentWhite : Color.clear, lineWidth: 4)
                        )
                )
            }
            .buttonStyle(.card)
            .focused($isBackButtonFocused)
            .scaleEffect(isBackButtonFocused ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isBackButtonFocused)
            
            Spacer()
            
            Text("Settings")
                .font(.incidentTVTitle())
                .foregroundColor(.incidentAlarmalade)
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 32)
        .background(Color.incidentSand)
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
                Text("Incident.io API configuration")
                    .font(.incidentTVHeading())
                    .foregroundColor(.incidentCharcoal)
                
                Text("Enter your incident.io API key to connect to your organization's incidents. You can find your API key in the incident.io dashboard under Settings > API Keys.")
                    .font(.incidentTVBody())
                    .foregroundColor(.incidentCharcoal.opacity(0.8))
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
            Text("API key")
                .font(.incidentSansHeading())
                .foregroundColor(.incidentCharcoal)
            
            Text("Navigate to the text field below and press the center button to activate the keyboard. In Simulator: use Hardware > Keyboard > Toggle Software Keyboard or ⌘K")
                .font(.incidentSansCaption())
                .foregroundColor(.incidentCharcoal.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
            
            TextField("Paste your incident.io API key here", text: $apiKey)
                .font(.incidentMono())
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                        .fill(Color.incidentSand.opacity(isTextFieldFocused ? 0.15 : 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                .stroke(isTextFieldFocused ? Color.incidentAlarmalade : Color.incidentWhite.opacity(0.3), lineWidth: isTextFieldFocused ? 4 : 2)
                        )
                )
                .foregroundColor(.incidentCharcoal)
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
                        .foregroundColor(.incidentResolved)
                    Text("API key entered (\(String(apiKey.prefix(8)))...)")
                        .font(.incidentSansBody())
                        .foregroundColor(.incidentResolved)
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
                        Text("Save API key")
                            .font(.incidentSansHeading())
                    }
                    .foregroundColor(.incidentCharcoal)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        isSaveButtonFocused ? Color.incidentAlarmalade : Color.incidentAlarmalade.opacity(0.8),
                                        isSaveButtonFocused ? Color.incidentMajor : Color.incidentMajor.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                    .stroke(isSaveButtonFocused ? Color.incidentWhite : Color.clear, lineWidth: 4)
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
                        Text(isTestingConnection ? "Testing..." : "Test connection")
                            .font(.incidentSansHeading())
                    }
                    .foregroundColor(.incidentCharcoal)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                            .fill(isTestButtonFocused ? Color.incidentMinor : Color.incidentMinor.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                    .stroke(isTestButtonFocused ? Color.incidentWhite : Color.clear, lineWidth: 4)
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
                        .foregroundColor(.incidentResolved)
                    Text("API key saved successfully!")
                        .font(.incidentSansHeading())
                        .foregroundColor(.incidentResolved)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                        .fill(Color.incidentResolved.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                .stroke(Color.incidentResolved.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if showErrorMessage {
                HStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                    Text("Failed to save API key. Please try again.")
                        .font(.incidentSansHeading())
                        .foregroundColor(.red)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                        .fill(Color.red.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        )
                )
            }
            
            if let testResult = connectionTestResult {
                HStack(spacing: 16) {
                    Image(systemName: testResult.contains("Success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(testResult.contains("Success") ? .incidentResolved : .incidentAlarmalade)
                    Text(testResult)
                        .font(.incidentSansHeading())
                        .foregroundColor(testResult.contains("Success") ? .incidentResolved : .incidentAlarmalade)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                        .fill((testResult.contains("Success") ? Color.incidentResolved : Color.incidentAlarmalade).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                                .stroke((testResult.contains("Success") ? Color.incidentResolved : Color.incidentAlarmalade).opacity(0.5), lineWidth: 2)
                        )
                )
            }
        }
    }
}

