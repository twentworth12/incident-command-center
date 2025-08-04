//
//  IncidentService.swift
//  incident-overview
//
//  Created by Claude Code on 7/30/25.
//

import Foundation

@MainActor
class IncidentService: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiKey: String
    private let baseURL = "https://api.incident.io"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func fetchRecentIncidents() async {
        isLoading = true
        errorMessage = nil
        
        // For now, use mock data to prevent crashes while we debug
        // TODO: Re-enable API call once we verify the data structure
        await loadMockData()
        
        /*
        guard let url = URL(string: "\(baseURL)/v2/incidents") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    errorMessage = "HTTP Error \(httpResponse.statusCode)"
                    isLoading = false
                    return
                }
            }
            
            
            // Try to decode the response
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let incidentResponse = try decoder.decode(IncidentResponse.self, from: data)
            
            // Sort by created date (most recent first) and take first 10
            incidents = Array(incidentResponse.incidents
                .sorted { first, second in
                    guard let firstDate = first.formattedCreatedDate,
                          let secondDate = second.formattedCreatedDate else {
                        return false
                    }
                    return firstDate > secondDate
                }
                .prefix(10))
            
        } catch let decodingError as DecodingError {
            errorMessage = "Unable to parse response data"
        } catch {
            errorMessage = "Network connection failed"
        }
        */
        
        isLoading = false
    }
    
    private func loadMockData() async {
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let mockIncidents = [
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
                        assignee: User(name: "Sarah Chen", email: "sarah@company.com", id: "u1")
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
                        assignee: User(name: "Mike Rodriguez", email: "mike@company.com", id: "u2")
                    )
                ]
            ),
            Incident(
                id: "3",
                name: "Critical Authentication Service Down",
                status: IncidentStatus(category: "live", name: "Live"),
                createdAt: "2025-07-31T12:00:00Z",
                updatedAt: "2025-07-31T13:30:00Z",
                summary: "Authentication service completely unavailable, users cannot log in",
                severity: IncidentSeverity(name: "Critical", rank: 3),
                incidentRoleAssignments: [
                    IncidentRoleAssignment(
                        role: Role(id: "1", name: "Incident Lead", shortform: "lead", roleType: "lead"),
                        assignee: User(name: "Alex Kim", email: "alex@company.com", id: "u3")
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
                        assignee: User(name: "Emma Wilson", email: "emma@company.com", id: "u4")
                    )
                ]
            )
        ]
        
        incidents = mockIncidents
    }
}