//
//  IncidentDetailView.swift
//  incident-overview
//
//  Created by Claude Code on 7/30/25.
//

import SwiftUI

struct IncidentDetailView: View {
    let incident: Incident
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    Text(incident.displayName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        // Status badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            Text(incident.safeStatus.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(20)
                        
                        // Severity badge
                        if let severity = incident.severity {
                            Text("Priority \(severity.rank ?? 0)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(20)
                        }
                    }
                }
                
                Divider()
                
                // Incident details
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(title: "Incident ID", value: incident.id)
                    
                    if let createdDate = incident.formattedCreatedDate {
                        DetailRow(title: "Created", value: DateFormatter.longStyle.string(from: createdDate))
                    }
                    
                    if let updatedAt = incident.updatedAt,
                       let updatedDate = ISO8601DateFormatter().date(from: updatedAt) {
                        DetailRow(title: "Last Updated", value: DateFormatter.longStyle.string(from: updatedDate))
                    }
                    
                    if let summary = incident.displaySummary, !summary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(summary)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Incident Details")
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "live", "investigating":
            return .red
        case "monitoring":
            return .orange
        case "resolved", "closed":
            return .green
        default:
            return .gray
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
}

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
}