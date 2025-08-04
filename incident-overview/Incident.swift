//
//  Incident.swift
//  incident-overview
//
//  Created by Claude Code on 7/30/25.
//

import Foundation

struct IncidentResponse: Codable {
    let incidents: [Incident]
}

struct Incident: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let status: IncidentStatus?
    let createdAt: String
    let updatedAt: String?
    let summary: String?
    let severity: IncidentSeverity?
    let incidentRoleAssignments: [IncidentRoleAssignment]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status = "incident_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case summary
        case severity
        case incidentRoleAssignments = "incident_role_assignments"
    }
    
    // Provide default values for missing data
    var safeStatus: IncidentStatus {
        return status ?? IncidentStatus(category: "unknown", name: "Unknown")
    }
}

struct IncidentStatus: Codable, Hashable {
    let category: String
    let name: String
}

struct IncidentSeverity: Codable, Hashable {
    let name: String
    let rank: Int?
}

struct IncidentRole: Codable, Hashable {
    let user: User?
}

struct IncidentRoleAssignment: Codable, Hashable {
    let role: Role
    let assignee: User?
}

struct Role: Codable, Hashable {
    let id: String
    let name: String
    let shortform: String?
    let roleType: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, shortform
        case roleType = "role_type"
    }
}

struct User: Codable, Hashable {
    let name: String?
    let email: String?
    let id: String
}

// MARK: - String Extension for Sentence Case
extension String {
    /// Converts text to sentence case (first letter capitalized, rest lowercase)
    var sentenceCase: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}

extension Incident {
    var formattedCreatedDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }
    
    var statusColor: String {
        switch safeStatus.category.lowercased() {
        case "triage", "live":
            return "red"
        case "learning":
            return "orange"
        case "closed":
            return "green"
        default:
            return "gray"
        }
    }
    
    // Get the incident lead user for compatibility with existing code
    var incidentRole: IncidentRole? {
        guard let assignments = incidentRoleAssignments else { return nil }
        
        // Find the incident lead role
        let leadAssignment = assignments.first { assignment in
            assignment.role.roleType?.lowercased() == "lead" || 
            assignment.role.name.lowercased().contains("lead")
        }
        
        // Return the assignee wrapped in the old IncidentRole structure
        return leadAssignment?.assignee != nil ? IncidentRole(user: leadAssignment?.assignee) : nil
    }
    
    // MARK: - Sentence Case Properties
    /// Incident name in sentence case
    var displayName: String {
        return name.sentenceCase
    }
    
    /// Summary in sentence case
    var displaySummary: String? {
        return summary?.sentenceCase
    }
}

extension IncidentStatus {
    /// Status name in sentence case
    var displayName: String {
        return name.sentenceCase
    }
}

extension IncidentSeverity {
    /// Severity name in sentence case  
    var displayName: String {
        return name.sentenceCase
    }
}

extension User {
    /// User name in sentence case
    var displayName: String? {
        return name?.sentenceCase
    }
}