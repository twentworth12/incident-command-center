//
//  ContentView.swift
//  incident-overview
//
//  Created by Tom Wentworth on 7/30/25.
//

import SwiftUI

// Utility function to check if an incident is active
func isIncidentActive(_ incident: Incident) -> Bool {
    ["triage", "live", "learning"].contains(incident.safeStatus.category.lowercased())
}

// incident.io Brand Colors
extension Color {
    static let incidentOrange = Color(red: 0.949, green: 0.333, blue: 0.2) // #F25533
    static let incidentYellow = Color(red: 0.945, green: 0.804, blue: 0.596) // #F1CD98
    static let incidentGradient = LinearGradient(
        gradient: Gradient(colors: [.incidentOrange, .incidentYellow]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct ContentView: View {
    @State private var incidents: [Incident] = []
    @State private var isLoading = false
    @State private var selectedIncident: Incident?
    @State private var lastUpdated = Date()
    @State private var usingMockData = false
    @State private var showingSettings = false
    @State private var hasAPIKey = false
    
    private let refreshTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            if showingSettings {
                SettingsView(
                    onBack: {
                        showingSettings = false
                    },
                    onAPISaved: {
                        hasAPIKey = KeychainManager.shared.hasAPIKey
                        loadRealData()
                    }
                )
            } else if selectedIncident == nil {
                WarRoomDashboard()
            } else {
                WarRoomIncidentDetail(incident: selectedIncident!) {
                    selectedIncident = nil
                }
            }
        }
        .onAppear {
            hasAPIKey = KeychainManager.shared.hasAPIKey
            loadRealData()
        }
        .onReceive(refreshTimer) { _ in
            if hasAPIKey {
                loadRealData()
            }
        }
        .onPlayPauseCommand {
            // Use Play/Pause button on remote to access settings
            showingSettings = true
        }
        .onMoveCommand { direction in
        }
    }
    
    @ViewBuilder
    private func WarRoomDashboard() -> some View {
        if isLoading && incidents.isEmpty {
            VStack(spacing: 40) {
                ProgressView()
                    .scaleEffect(3.0)
                    .tint(.white)
                
                Text("LOADING INCIDENTS...")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        } else if incidents.isEmpty {
            VStack(spacing: 40) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.green)
                
                Text("ALL CLEAR")
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                Text("NO ACTIVE INCIDENTS")
                    .font(.system(size: 36, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        } else {
            VStack(spacing: 0) {
                // War Room Header
                WarRoomHeader(
                    incidents: incidents, 
                    lastUpdated: lastUpdated, 
                    isLoading: isLoading, 
                    usingMockData: usingMockData,
                    hasAPIKey: hasAPIKey,
                    onSettingsPressed: {
                        showingSettings = true
                    }
                )
                
                // Critical Incidents Grid
                ScrollView {
                    VStack(spacing: 40) {
                        // Settings access button at top of scroll area
                        HStack {
                            Spacer()
                            
                            SettingsAccessButton {
                                showingSettings = true
                            }
                        }
                        .padding(.horizontal, 60)
                        
                        LazyVGrid(columns: gridColumns, spacing: 32) {
                            ForEach(sortedActiveIncidents) { incident in
                                WarRoomIncidentTile(incident: incident)
                                    .onTapGesture {
                                        selectedIncident = incident
                                    }
                                    .focusable()
                            }
                        }
                        .padding(.horizontal, 60)
                    }
                    .padding(.vertical, 40)
                }
                .background(Color.black)
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 32),
            GridItem(.flexible(), spacing: 32),
            GridItem(.flexible(), spacing: 32)
        ]
    }
    
    private var sortedIncidents: [Incident] {
        incidents.sorted { lhs, rhs in
            let lhsPriority = priorityValue(for: lhs)
            let rhsPriority = priorityValue(for: rhs)
            
            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }
            
            // Secondary sort by status urgency
            let lhsUrgency = statusUrgency(for: lhs.safeStatus.category)
            let rhsUrgency = statusUrgency(for: rhs.safeStatus.category)
            
            if lhsUrgency != rhsUrgency {
                return lhsUrgency < rhsUrgency
            }
            
            // Tertiary sort by creation time (newest first)
            guard let lhsDate = lhs.formattedCreatedDate,
                  let rhsDate = rhs.formattedCreatedDate else {
                return false
            }
            return lhsDate > rhsDate
        }
    }
    
    private var sortedActiveIncidents: [Incident] {
        sortedIncidents.filter { isIncidentActive($0) }
    }
    
    private func priorityValue(for incident: Incident) -> Int {
        // API uses rank 1=Minor, 2=Major, 3=Critical
        // Invert so higher rank (Critical) gets lower sort priority (sorts first)
        let rank = incident.severity?.rank ?? 0
        return rank > 0 ? (4 - rank) : 99  // Critical(3)→1, Major(2)→2, Minor(1)→3
    }
    
    private func statusUrgency(for status: String) -> Int {
        switch status.lowercased() {
        case "triage": return 1
        case "live": return 2
        case "learning": return 3
        case "closed": return 4
        default: return 5
        }
    }
    
    private func isActiveIncident(_ incident: Incident) -> Bool {
        isIncidentActive(incident)
    }
    
    private func loadMockData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            incidents = [
                Incident(
                    id: "1",
                    name: "Critical Database Connection Failure",
                    status: IncidentStatus(category: "live", name: "Live"),
                    createdAt: "2025-07-31T14:30:00Z",
                    updatedAt: "2025-07-31T15:00:00Z",
                    summary: "Primary database cluster experiencing connection timeouts affecting 85% of users",
                    severity: IncidentSeverity(name: "Critical", rank: 3),
                    incidentRoleAssignments: [
                        IncidentRoleAssignment(
                            role: Role(id: "1", name: "Incident Lead", shortform: "lead", roleType: "lead"),
                            assignee: User(name: "Sarah Chen", email: "s.chen@company.com", id: "u1")
                        )
                    ]
                ),
                Incident(
                    id: "2", 
                    name: "Payment Gateway API Degradation",
                    status: IncidentStatus(category: "learning", name: "Learning"),
                    createdAt: "2025-07-31T13:15:00Z",
                    updatedAt: "2025-07-31T14:45:00Z",
                    summary: "Payment processing experiencing 15% failure rate due to third-party API issues",
                    severity: IncidentSeverity(name: "Major", rank: 2),
                    incidentRoleAssignments: [
                        IncidentRoleAssignment(
                            role: Role(id: "1", name: "Incident Lead", shortform: "lead", roleType: "lead"),
                            assignee: User(name: "Mike Rodriguez", email: "m.rodriguez@company.com", id: "u2")
                        )
                    ]
                ),
                Incident(
                    id: "3",
                    name: "CDN Performance Issues",
                    status: IncidentStatus(category: "triage", name: "Triage"),
                    createdAt: "2025-07-31T12:00:00Z",
                    updatedAt: "2025-07-31T13:30:00Z",
                    summary: "Slow asset loading in EU regions due to CDN provider issues",
                    severity: IncidentSeverity(name: "Major", rank: 2),
                    incidentRoleAssignments: [
                        IncidentRoleAssignment(
                            role: Role(id: "1", name: "Incident Lead", shortform: "lead", roleType: "lead"),
                            assignee: User(name: "Alex Kim", email: "a.kim@company.com", id: "u3")
                        )
                    ]
                ),
                Incident(
                    id: "4",
                    name: "Email Service Restored",
                    status: IncidentStatus(category: "closed", name: "Closed"),
                    createdAt: "2025-07-31T10:00:00Z",
                    updatedAt: "2025-07-31T11:30:00Z",
                    summary: "Email delivery delays have been resolved after infrastructure update",
                    severity: IncidentSeverity(name: "Minor", rank: 1),
                    incidentRoleAssignments: [
                        IncidentRoleAssignment(
                            role: Role(id: "1", name: "Incident Lead", shortform: "lead", roleType: "lead"),
                            assignee: User(name: "Emma Wilson", email: "e.wilson@company.com", id: "u4")
                        )
                    ]
                )
            ]
            lastUpdated = Date()
            isLoading = false
            usingMockData = true
        })
    }
    
    private func loadRealData() {
        // First try keychain, with detailed debugging, then fallback to mock data
        guard hasAPIKey, let keychainKey = KeychainManager.shared.getAPIKey() else {
            loadMockData()
            return
        }
        
        let cleanKeychainKey = keychainKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        // Use the cleaned keychain key
        let apiKey = cleanKeychainKey
        
        isLoading = true
        
        Task {
            do {
                // Get ALL incidents (including resolved ones for metrics)
                let url = URL(string: "https://api.incident.io/v2/incidents")!
                var request = URLRequest(url: url)
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "GET"
                
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode != 200 {
                        // Fall back to mock data on error
                        await MainActor.run {
                            loadMockData()
                        }
                        return
                    }
                }
                
                let incidentResponse = try JSONDecoder().decode(IncidentResponse.self, from: data)
                
                await MainActor.run {
                    self.incidents = Array(incidentResponse.incidents.prefix(12))
                    self.lastUpdated = Date()
                    self.isLoading = false
                    self.usingMockData = false
                }
                
            } catch {
                // Fall back to mock data on error
                await MainActor.run {
                    loadMockData()
                }
            }
        }
    }
}

struct WarRoomHeader: View {
    let incidents: [Incident]
    let lastUpdated: Date
    let isLoading: Bool
    let usingMockData: Bool
    let hasAPIKey: Bool
    let onSettingsPressed: () -> Void
    
    @FocusState private var isSettingsButtonFocused: Bool
    
    private var criticalCount: Int {
        incidents.filter { ($0.severity?.rank ?? 0) >= 3 }.count
    }
    
    private var activeCount: Int {
        incidents.filter { isIncidentActive($0) }.count
    }
    
    private var resolvedTodayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let count = incidents.filter { incident in
            // Count incidents that are closed or resolved today
            let isResolved = ["closed", "resolved"].contains(incident.safeStatus.category.lowercased())
            guard isResolved,
                  let updatedAt = incident.updatedAt else {
                return false
            }
            
            // Handle ISO8601 dates with fractional seconds
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let updatedDate = formatter.date(from: updatedAt) else {
                return false
            }
            
            return updatedDate >= today
        }.count
        return count
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Title and Status
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("INCIDENT COMMAND CENTER")
                        .font(.system(size: 64, weight: .black, design: .default))
                        .foregroundStyle(Color.incidentGradient)
                        .shadow(color: .black.opacity(0.8), radius: 6, x: 2, y: 2)
                    
                    HStack(spacing: 40) {
                        Text("LAST UPDATED: \(formattedTime)")
                            .font(.system(size: 28, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                        
                        if isLoading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.yellow)
                                Text("REFRESHING...")
                                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        // Show when using mock data or no API key
                        if usingMockData {
                            HStack(spacing: 12) {
                                Image(systemName: hasAPIKey ? "exclamationmark.triangle.fill" : "key.slash.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                Text(hasAPIKey ? "USING MOCK DATA" : "NO API KEY - USING MOCK DATA")
                                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        // Settings access hint
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                            Text("PRESS PLAY/PAUSE FOR SETTINGS")
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                // Settings Button
                Button(action: {
                    onSettingsPressed()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28, weight: .bold))
                        Text("SETTINGS")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSettingsButtonFocused ? Color.blue : Color.gray.opacity(0.8))
                    )
                }
                .buttonStyle(.plain) // Ensure it works on tvOS
                .focusable(true) // Explicitly enable focus
                .focused($isSettingsButtonFocused)
                .scaleEffect(isSettingsButtonFocused ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSettingsButtonFocused)
                .onTapGesture {
                    onSettingsPressed()
                }
                
                Spacer().frame(width: 40)
                
                // System Status Indicator
                VStack(spacing: 16) {
                    if criticalCount > 0 {
                        SystemStatusBadge(
                            status: "CRITICAL",
                            count: criticalCount,
                            color: .incidentOrange,
                            icon: "exclamationmark.triangle.fill",
                            isFlashing: true
                        )
                    } else if activeCount > 0 {
                        SystemStatusBadge(
                            status: "DEGRADED",
                            count: activeCount,
                            color: .incidentYellow,
                            icon: "exclamationmark.circle.fill"
                        )
                    } else {
                        SystemStatusBadge(
                            status: "OPERATIONAL",
                            count: 0,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )
                    }
                }
            }
            
            // Metrics Dashboard
            HStack(spacing: 40) {
                MetricTile(
                    title: "CRITICAL",
                    value: "\(criticalCount)",
                    subtitle: "P1 INCIDENTS",
                    color: criticalCount > 0 ? .incidentOrange : .gray,
                    icon: "exclamationmark.triangle.fill",
                    isAnimated: criticalCount > 0
                )
                
                MetricTile(
                    title: "ACTIVE",
                    value: "\(activeCount)",
                    subtitle: "ONGOING INCIDENTS",
                    color: activeCount > 0 ? .incidentYellow : .gray,
                    icon: "flame.fill",
                    isAnimated: activeCount > 0
                )
                
                MetricTile(
                    title: "RESOLVED TODAY",
                    value: "\(resolvedTodayCount)",
                    subtitle: "INCIDENTS CLOSED",
                    color: .green,
                    icon: "checkmark.circle.fill",
                    isAnimated: false
                )
                
                // Status Distribution Chart
                StatusDistributionChart(incidents: incidents)
                
                // Incident Trend Chart  
                IncidentTrendChart(incidents: incidents)
            }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 48)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.95),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: lastUpdated)
    }
}

struct SystemStatusBadge: View {
    let status: String
    let count: Int
    let color: Color
    let icon: String
    let isFlashing: Bool
    
    init(status: String, count: Int, color: Color, icon: String, isFlashing: Bool = false) {
        self.status = status
        self.count = count
        self.color = color
        self.icon = icon
        self.isFlashing = isFlashing
    }
    
    @State private var isFlashingState = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(color)
                .opacity(isFlashing && isFlashingState ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isFlashingState)
                .onAppear {
                    if isFlashing {
                        isFlashingState = true
                    }
                }
            
            VStack(spacing: 8) {
                Text(status)
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(color)
                
                if count > 0 {
                    Text("\(count) incidents")
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color, lineWidth: 3)
                )
        )
    }
}

struct StatusDistributionChart: View {
    let incidents: [Incident]
    
    private var statusCounts: [(String, Int, Color)] {
        [
            ("LIVE", incidents.filter { $0.safeStatus.category.lowercased() == "live" }.count, .incidentOrange),
            ("TRIAGE", incidents.filter { $0.safeStatus.category.lowercased() == "triage" }.count, .incidentOrange),
            ("LEARNING", incidents.filter { $0.safeStatus.category.lowercased() == "learning" }.count, .incidentYellow),
            ("CLOSED", incidents.filter { $0.safeStatus.category.lowercased() == "closed" }.count, .green)
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("STATUS BREAKDOWN")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(statusCounts, id: \.0) { status, count, color in
                    HStack {
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                        
                        Text(status)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(color)
                    }
                }
            }
        }
        .padding(24)
        .frame(minWidth: 240, minHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct IncidentTrendChart: View {
    let incidents: [Incident]
    
    private var hourlyData: [(String, Int)] {
        let calendar = Calendar.current
        let now = Date()
        
        return (0..<24).reversed().map { hoursAgo in
            let targetHour = calendar.date(byAdding: .hour, value: -hoursAgo, to: now)!
            let hourStart = calendar.dateInterval(of: .hour, for: targetHour)!.start
            let hourEnd = calendar.dateInterval(of: .hour, for: targetHour)!.end
            
            let count = incidents.filter { incident in
                guard let createdDate = incident.formattedCreatedDate else { return false }
                return createdDate >= hourStart && createdDate < hourEnd
            }.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH"
            let hourLabel = formatter.string(from: targetHour)
            
            return (hourLabel, count)
        }
    }
    
    private var maxValue: Int {
        max(hourlyData.map(\.1).max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("24H TREND")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(hourlyData.enumerated()), id: \.offset) { index, data in
                    let (hour, count) = data
                    let height = CGFloat(count) / CGFloat(maxValue) * 80
                    
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        count > 0 ? .incidentOrange : .gray.opacity(0.3),
                                        count > 0 ? .incidentYellow : .gray.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 8, height: max(height, 2))
                            .cornerRadius(2)
                        
                        if index % 6 == 0 {
                            Text(hour)
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
        .padding(24)
        .frame(minWidth: 280, minHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    let isAnimated: Bool
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
                .scaleEffect(isAnimated && pulseAnimation ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
            
            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.5), radius: isAnimated ? 8 : 0, x: 0, y: 0)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(minWidth: 200, minHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.1),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.6), color.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .onAppear {
            if isAnimated {
                pulseAnimation = true
            }
        }
    }
}

struct WarRoomIncidentTile: View {
    let incident: Incident
    @FocusState private var isFocused: Bool
    @State private var pulseAnimation = false
    
    private var isActiveIncident: Bool {
        isIncidentActive(incident)
    }
    
    private var isCritical: Bool {
        (incident.severity?.rank ?? 0) >= 3
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "triage", "live":
            return .incidentOrange
        case "learning":
            return .incidentYellow
        case "closed":
            return .green
        default:
            return .gray
        }
    }
    
    private var priorityColor: Color {
        guard let rank = incident.severity?.rank else { return .gray }
        switch rank {
        case 3: return .incidentOrange  // Critical
        case 2: return .incidentYellow  // Major
        case 1: return .yellow          // Minor
        default: return .blue
        }
    }
    
    private var ageInHours: Int {
        guard let createdDate = incident.formattedCreatedDate else { return 0 }
        return Int(Date().timeIntervalSince(createdDate) / 3600)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with status and priority
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Priority badge
                    HStack(spacing: 8) {
                        Text("P\(incident.severity?.rank ?? 0)")
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(priorityColor)
                            .cornerRadius(12)
                        
                        if ageInHours > 24 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))
                                Text("\(ageInHours)h")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
                
                // Status indicator
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .fill(statusColor)
                        .frame(width: 32, height: 32)
                    
                    if isCritical {
                        Circle()
                            .stroke(statusColor, lineWidth: 4)
                            .frame(width: 60, height: 60)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0.0 : 0.8)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: pulseAnimation)
                    }
                }
                .onAppear {
                    if isCritical {
                        pulseAnimation = true
                    }
                }
            }
            
            // Incident title
            Text(incident.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Status and metadata
            VStack(alignment: .leading, spacing: 12) {
                // Status badge
                HStack(spacing: 8) {
                    Text(incident.safeStatus.name.uppercased())
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(statusColor.opacity(0.2))
                        .cornerRadius(10)
                }
                
                // Owner and time info
                VStack(alignment: .leading, spacing: 6) {
                    if let owner = incident.incidentRole?.user?.name {
                        HStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                            Text(owner)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    if let createdDate = incident.formattedCreatedDate {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            Text(timeAgo(from: createdDate))
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
        }
        .padding(28)
        .frame(minHeight: 280)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isFocused ? Color.white.opacity(0.2) : statusColor.opacity(0.1),
                            isFocused ? statusColor.opacity(0.1) : Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isFocused ? Color.white : statusColor.opacity(isCritical ? 0.9 : 0.6),
                                    isFocused ? statusColor.opacity(0.8) : statusColor.opacity(isCritical ? 0.6 : 0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), 
                            lineWidth: isFocused ? 4 : (isCritical ? 3 : 2)
                        )
                )
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .shadow(color: statusColor.opacity(isCritical ? 0.4 : 0.2), radius: isFocused ? 12 : 6)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .focusable()
        .focused($isFocused)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct TVIncidentRow: View {
    let incident: Incident
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            // Status indicator with pulse animation for active incidents
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.3))
                    .frame(width: 48, height: 48)
                
                Circle()
                    .fill(statusColor)
                    .frame(width: 24, height: 24)
                
                if isActiveIncident {
                    Circle()
                        .stroke(statusColor, lineWidth: 3)
                        .frame(width: 48, height: 48)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0.0 : 0.8)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                }
            }
            .onAppear {
                if isActiveIncident {
                    pulseAnimation = true
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Incident title
                Text(incident.name)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Status and metadata row
                HStack(spacing: 16) {
                    // Status badge
                    HStack(spacing: 8) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 12, height: 12)
                        Text(incident.safeStatus.name.uppercased())
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(statusColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(16)
                    
                    // Priority badge
                    if let severity = incident.severity {
                        HStack(spacing: 6) {
                            Image(systemName: priorityIcon)
                                .font(.system(size: 12, weight: .bold))
                            Text("P\(severity.rank ?? 0)")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(priorityColor)
                        .cornerRadius(14)
                    }
                    
                    Spacer()
                    
                    // Time ago
                    if let createdDate = incident.formattedCreatedDate {
                        Text(timeAgo(from: createdDate))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Owner info
                if let owner = incident.incidentRole?.user?.name {
                    HStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                        Text("Owner: \(owner)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isFocused ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isFocused ? Color.white.opacity(0.8) : statusColor.opacity(0.2), lineWidth: isFocused ? 4 : 2)
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .focusable()
        .focused($isFocused)
    }
    
    @State private var pulseAnimation = false
    
    private var isActiveIncident: Bool {
        isIncidentActive(incident)
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "triage", "live":
            return .incidentOrange
        case "learning":
            return .incidentYellow
        case "closed":
            return .green
        default:
            return .gray
        }
    }
    
    private var priorityColor: Color {
        guard let rank = incident.severity?.rank else { return .gray }
        switch rank {
        case 3: return .incidentOrange  // Critical
        case 2: return .incidentYellow  // Major  
        case 1: return .yellow          // Minor
        default: return .blue
        }
    }
    
    private var priorityIcon: String {
        guard let rank = incident.severity?.rank else { return "exclamationmark.circle.fill" }
        switch rank {
        case 1: return "exclamationmark.triangle.fill"
        case 2: return "exclamationmark.circle.fill"
        case 3: return "info.circle.fill"
        default: return "circle.fill"
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct WarRoomIncidentDetail: View {
    let incident: Incident
    let onBack: () -> Void
    @FocusState private var backButtonFocused: Bool
    @State private var pulseAnimation = false
    
    private var isActiveIncident: Bool {
        isIncidentActive(incident)
    }
    
    private var isCritical: Bool {
        (incident.severity?.rank ?? 0) >= 3
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "triage", "live":
            return .incidentOrange
        case "learning":
            return .incidentYellow
        case "closed":
            return .green
        default:
            return .gray
        }
    }
    
    private var priorityColor: Color {
        guard let rank = incident.severity?.rank else { return .gray }
        switch rank {
        case 3: return .incidentOrange  // Critical
        case 2: return .incidentYellow  // Major  
        case 1: return .yellow          // Minor
        default: return .blue
        }
    }
    
    private var ageInHours: Int {
        guard let createdDate = incident.formattedCreatedDate else { return 0 }
        return Int(Date().timeIntervalSince(createdDate) / 3600)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
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
                            .fill(backButtonFocused ? Color.blue : Color.gray.opacity(0.8))
                    )
                }
                .focusable()
                .focused($backButtonFocused)
                .scaleEffect(backButtonFocused ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: backButtonFocused)
                
                Spacer()
                
                // Incident ID Badge
                Text("ID: \(incident.id)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 32)
            .background(Color.black)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    // Main Incident Header
                    HStack(alignment: .top, spacing: 40) {
                        // Status Indicator
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(statusColor.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 80, height: 80)
                                
                                if isCritical {
                                    Circle()
                                        .stroke(statusColor, lineWidth: 6)
                                        .frame(width: 120, height: 120)
                                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                        .opacity(pulseAnimation ? 0.0 : 0.8)
                                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                                }
                            }
                            .onAppear {
                                if isCritical {
                                    pulseAnimation = true
                                }
                            }
                            
                            VStack(spacing: 12) {
                                Text(incident.safeStatus.name.uppercased())
                                    .font(.system(size: 32, weight: .black, design: .monospaced))
                                    .foregroundColor(statusColor)
                                
                                if let severity = incident.severity {
                                    Text("PRIORITY \(severity.rank ?? 0)")
                                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                                        .foregroundColor(priorityColor)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(priorityColor.opacity(0.2))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        // Incident Details
                        VStack(alignment: .leading, spacing: 20) {
                            Text(incident.name)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Age and timing info
                            VStack(alignment: .leading, spacing: 12) {
                                if ageInHours > 0 {
                                    HStack(spacing: 12) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(ageInHours > 24 ? .red : .orange)
                                        
                                        Text("INCIDENT AGE: \(ageInHours) HOURS")
                                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                                            .foregroundColor(ageInHours > 24 ? .red : .white.opacity(0.9))
                                    }
                                    
                                    if ageInHours > 24 {
                                        Text("⚠️ LONG-RUNNING INCIDENT")
                                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                                
                                if let createdDate = incident.formattedCreatedDate {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 20))
                                            .foregroundColor(.gray)
                                        Text("CREATED: \(fullDateFormatter.string(from: createdDate))")
                                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                    }
                    
                    // Owner Information (if available)
                    if let owner = incident.incidentRole?.user {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("INCIDENT COMMANDER")
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 24) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    if let name = owner.name {
                                        Text(name)
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    if let email = owner.email {
                                        Text(email)
                                            .font(.system(size: 24, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                )
                        )
                    }
                    
                    // Summary (if available)
                    if let summary = incident.summary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 24) {
                            Text("INCIDENT SUMMARY")
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text(summary)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(8)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                        )
                    }
                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
            }
            .background(Color.black)
        }
        .background(Color.black)
    }
    
    private var fullDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
}

struct TVIncidentDetail: View {
    let incident: Incident
    let onBack: () -> Void
    @FocusState private var backButtonFocused: Bool
    @State private var pulseAnimation = false
    
    private var isActiveIncident: Bool {
        isIncidentActive(incident)
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "triage", "live":
            return .incidentOrange
        case "learning":
            return .incidentYellow
        case "closed":
            return .green
        default:
            return .gray
        }
    }
    
    private var priorityColor: Color {
        guard let rank = incident.severity?.rank else { return .gray }
        switch rank {
        case 3: return .incidentOrange  // Critical
        case 2: return .incidentYellow  // Major  
        case 1: return .yellow          // Minor
        default: return .blue
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Back button and header
                VStack(alignment: .leading, spacing: 24) {
                    Button(action: onBack) {
                        HStack(spacing: 12) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 24, weight: .bold))
                            Text("Back to Incidents")
                                .font(.system(size: 24, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(backButtonFocused ? Color.blue : Color.gray)
                        )
                    }
                    .focusable()
                    .focused($backButtonFocused)
                    .scaleEffect(backButtonFocused ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: backButtonFocused)
                    
                    HStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(statusColor.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(statusColor)
                                .frame(width: 40, height: 40)
                            
                            if isActiveIncident {
                                Circle()
                                    .stroke(statusColor, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                    .opacity(pulseAnimation ? 0.0 : 0.8)
                                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: pulseAnimation)
                            }
                        }
                        .onAppear {
                            if isActiveIncident {
                                pulseAnimation = true
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(incident.name)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Status and Priority Cards
                HStack(spacing: 24) {
                    // Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 16, height: 16)
                            Text("STATUS")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(incident.safeStatus.name)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(statusColor)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(statusColor.opacity(0.1))
                    )
                    
                    // Priority Card
                    if let severity = incident.severity {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text("PRIORITY")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("P\(severity.rank ?? 0)")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(priorityColor)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(priorityColor.opacity(0.1))
                        )
                    }
                }
                
                // Timeline Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("TIMELINE")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if let createdDate = incident.formattedCreatedDate {
                            TVTimelineRow(
                                icon: "plus.circle.fill",
                                title: "Incident Created",
                                time: createdDate,
                                color: .blue
                            )
                        }
                        
                        if let updatedAt = incident.updatedAt,
                           let updatedDate = ISO8601DateFormatter().date(from: updatedAt) {
                            TVTimelineRow(
                                icon: "arrow.clockwise.circle.fill",
                                title: "Last Updated",
                                time: updatedDate,
                                color: .orange
                            )
                        }
                    }
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.1))
                        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                )
                
                // Owner Card
                if let owner = incident.incidentRole?.user {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("INCIDENT OWNER")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                if let name = owner.name {
                                    Text(name)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                if let email = owner.email {
                                    Text(email)
                                        .font(.system(size: 18))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.1))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    )
                }
                
                // Summary Card
                if let summary = incident.summary, !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("SUMMARY")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(summary)
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.1))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    )
                }
                
                Spacer(minLength: 60)
            }
            .padding(48)
        }
        .navigationTitle("Incident Details")
        .background(Color.black.opacity(0.05))
    }
}

struct TVTimelineRow: View {
    let icon: String
    let title: String
    let time: Date
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(formattedDate(time))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(timeAgo(from: time))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatusSummary: View {
    let incidents: [Incident]
    let status: String
    let color: Color
    let icon: String
    
    private var count: Int {
        incidents.filter { $0.safeStatus.category.lowercased() == status.lowercased() }.count
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(status.capitalized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct SettingsAccessButton: View {
    let onPressed: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: onPressed) {
            HStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 28, weight: .bold))
                Text("SETTINGS")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFocused ? Color.blue : Color.gray.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFocused ? Color.white : Color.clear, lineWidth: 3)
                    )
            )
        }
        .buttonStyle(.card) // Use tvOS card button style
        .focused($isFocused)
        .scaleEffect(isFocused ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onExitCommand {
            // Handle menu button if needed
        }
    }
}

#Preview {
    ContentView()
}
